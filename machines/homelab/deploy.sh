#!/usr/bin/env bash
#
# Deploy or update NixOS LXC containers on Proxmox.
#
# Usage:
#   ./deploy.sh <container-name> [proxmox-host]   Deploy/create a single container
#   ./deploy.sh --update-all [proxmox-host]        Update all existing containers
#
# Each container directory must contain:
#   meta.nix          - Proxmox container attributes (vmid, cores, memory, ip, ...)
#   configuration.nix - NixOS system configuration
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o LogLevel=ERROR"

# --- Helpers ---
pve_ssh() {
  local proxmox="$1"; shift
  ssh $SSH_OPTS "$proxmox" "$@"
}

ct_ssh() {
  local ip="$1"; shift
  ssh $SSH_OPTS "root@${ip}" "$@"
}

eval_meta() {
  nix eval --raw --file "$1" "$2" 2>/dev/null
}

container_exists() {
  pve_ssh "$1" "pct status $2" &>/dev/null
}

container_running() {
  pve_ssh "$1" "pct status $2" 2>/dev/null | grep -q "running"
}

wait_for_ssh() {
  local ip="$1"
  echo "    Waiting for SSH on ${ip}..."
  for _ in $(seq 1 30); do
    if ct_ssh "$ip" true &>/dev/null; then
      echo "    SSH is up."
      return 0
    fi
    sleep 2
  done
  echo "Error: SSH did not come up within 60s."
  return 1
}

# --- Sync config and rebuild a single container ---
# Args: <container-dir> <ip> <proxmox-host> <vmid>
sync_and_rebuild() {
  local container_dir="$1" ip="$2" proxmox="$3" vmid="$4"

  # Snapshot before deploy (ZFS-safe: no --description, alphanumeric name)
  local snap_name="predeploy$(date +%Y%m%d%H%M%S)"
  echo "    Creating snapshot $snap_name..."
  if ! pve_ssh "$proxmox" "pct snapshot $vmid $snap_name" 2>/dev/null; then
    echo "    Warning: snapshot failed, continuing."
  fi

  echo "    Syncing NixOS configuration..."
  ct_ssh "$ip" "mkdir -p /etc/nixos"

  # Sync entire repo so module imports (../../modules/...) resolve
  rsync -az --delete \
    --exclude='.git' \
    --exclude='result' \
    -e "ssh $SSH_OPTS" \
    "$REPO_ROOT/" \
    "root@${ip}:/etc/nixos/"

  # Symlink so nixos-rebuild finds the right configuration.nix
  local relative_config="${container_dir#$REPO_ROOT/}"
  ct_ssh "$ip" "ln -sfn /etc/nixos/${relative_config}/configuration.nix /etc/nixos/configuration.nix"

  echo "    Running nixos-rebuild switch..."
  if ! ct_ssh "$ip" "nixos-rebuild switch"; then
    echo "!!! nixos-rebuild failed on $ip, attempting rollback..."
    ct_ssh "$ip" "nixos-rebuild switch --rollback"
    echo "!!! Rolled back. Fix configuration and redeploy."
    return 1
  fi
}

# --- Deploy a single container (create if needed, then sync+rebuild) ---
deploy_container() {
  local container_dir="$1" proxmox="$2"

  local meta="$container_dir/meta.nix"
  local config="$container_dir/configuration.nix"

  if [[ ! -f "$meta" ]] || [[ ! -f "$config" ]]; then
    echo "Error: $container_dir must contain meta.nix and configuration.nix"
    return 1
  fi

  local vmid hostname cores memory swap disk_size storage bridge
  local ip gateway nameserver template onboot features
  vmid="$(eval_meta "$meta" vmid)"
  hostname="$(eval_meta "$meta" hostname)"
  cores="$(eval_meta "$meta" cores)"
  memory="$(eval_meta "$meta" memory)"
  swap="$(eval_meta "$meta" swap)"
  disk_size="$(eval_meta "$meta" diskSize)"
  storage="$(eval_meta "$meta" storage)"
  bridge="$(eval_meta "$meta" bridge)"
  ip="$(eval_meta "$meta" ip)"
  gateway="$(eval_meta "$meta" gateway)"
  nameserver="$(eval_meta "$meta" nameserver)"
  template="$(eval_meta "$meta" template)"
  onboot="$(eval_meta "$meta" onboot)"
  features="$(eval_meta "$meta" features)"

  local onboot_flag; onboot_flag=$([ "$onboot" = "true" ] && echo 1 || echo 0)
  local ct_description="MANAGED BY NIX - Do not edit in the UI. Changes will be overwritten by deploy.sh."
  local ct_ip="${ip%%/*}"

  echo "==> Deploying $hostname (VMID $vmid, IP $ip)"

  if ! container_exists "$proxmox" "$vmid"; then
    echo "    Creating container $vmid..."
    pve_ssh "$proxmox" "pct create $vmid $template \
      --hostname $hostname \
      --cores $cores \
      --memory $memory \
      --swap $swap \
      --storage $storage \
      --rootfs ${storage}:${disk_size} \
      --net0 name=eth0,bridge=${bridge},ip=${ip},gw=${gateway} \
      --nameserver $nameserver \
      --features $features \
      --onboot $onboot_flag \
      --unprivileged 1 \
      --description '$ct_description' \
      --start 1"

    wait_for_ssh "$ct_ip" || return 1
    echo "    Container created."
  else
    echo "    Container $vmid exists, updating resources..."
    pve_ssh "$proxmox" "pct set $vmid \
      --cores $cores \
      --memory $memory \
      --swap $swap \
      --hostname $hostname \
      --onboot $onboot_flag \
      --description '$ct_description'"

    if ! container_running "$proxmox" "$vmid"; then
      echo "    Starting container..."
      pve_ssh "$proxmox" "pct start $vmid"
    fi

    wait_for_ssh "$ct_ip" || return 1
  fi

  sync_and_rebuild "$container_dir" "$ct_ip" "$proxmox" "$vmid"
}

# --- Update all existing containers (skip create, only sync+rebuild) ---
update_all() {
  local proxmox="$1"
  local failed=0

  for dir in "$SCRIPT_DIR"/*/; do
    [[ -f "$dir/meta.nix" ]] || continue

    local meta="$dir/meta.nix"
    local vmid hostname ip ct_ip
    vmid="$(eval_meta "$meta" vmid)"
    hostname="$(eval_meta "$meta" hostname)"
    ip="$(eval_meta "$meta" ip)"
    ct_ip="${ip%%/*}"

    if ! container_exists "$proxmox" "$vmid"; then
      echo "==> Skipping $hostname (VMID $vmid): container does not exist. Use deploy to create it."
      continue
    fi

    echo ""
    echo "==> Updating $hostname (VMID $vmid, IP $ip)"

    if ! container_running "$proxmox" "$vmid"; then
      echo "    Starting container..."
      pve_ssh "$proxmox" "pct start $vmid"
    fi

    if ! wait_for_ssh "$ct_ip"; then
      echo "!!! Cannot reach $hostname, skipping."
      failed=$((failed + 1))
      continue
    fi

    if ! sync_and_rebuild "$dir" "$ct_ip" "$proxmox" "$vmid"; then
      failed=$((failed + 1))
    fi
  done

  echo ""
  if [[ $failed -gt 0 ]]; then
    echo "==> $failed container(s) failed to update."
    return 1
  else
    echo "==> All containers updated successfully."
  fi
}

# --- Main ---
case "${1:---help}" in
  --update-all)
    PROXMOX="${2:-root@proxmox}"
    update_all "$PROXMOX"
    ;;
  --help|-h)
    echo "Usage:"
    echo "  ./deploy.sh <container-name> [proxmox-host]   Deploy a single container"
    echo "  ./deploy.sh --update-all [proxmox-host]        Update all existing containers"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh arr"
    echo "  ./deploy.sh arr root@192.168.1.100"
    echo "  ./deploy.sh --update-all"
    ;;
  *)
    CONTAINER_NAME="$1"
    PROXMOX="${2:-root@proxmox}"
    CONTAINER_DIR="$SCRIPT_DIR/$CONTAINER_NAME"

    if [[ ! -d "$CONTAINER_DIR" ]]; then
      echo "Error: Container directory '$CONTAINER_DIR' not found."
      echo "Available containers:"
      for dir in "$SCRIPT_DIR"/*/; do
        [[ -f "$dir/meta.nix" ]] && echo "  $(basename "$dir")"
      done
      exit 1
    fi

    deploy_container "$CONTAINER_DIR" "$PROXMOX"
    ;;
esac
