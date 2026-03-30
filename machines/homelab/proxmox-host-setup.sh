#!/usr/bin/env bash
#
# Proxmox host setup script.
# Idempotent — safe to re-run after changes.
#
# Usage:
#   ssh root@proxmox < proxmox-host-setup.sh       # pipe directly
#   scp proxmox-host-setup.sh root@proxmox: && \
#     ssh root@proxmox bash proxmox-host-setup.sh   # copy and run
#
set -euo pipefail

echo "==> Proxmox host setup starting..."

# =============================================================================
# Repositories
# =============================================================================

# Use the no-subscription repo (comment out enterprise)
if [[ -f /etc/apt/sources.list.d/pve-enterprise.list ]]; then
  sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
  echo "    Disabled enterprise repo."
fi

# Proxmox no-subscription repo
PVE_REPO="/etc/apt/sources.list.d/pve-no-subscription.list"
PVE_REPO_LINE="deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription"
if ! grep -qF "$PVE_REPO_LINE" "$PVE_REPO" 2>/dev/null; then
  echo "$PVE_REPO_LINE" > "$PVE_REPO"
  echo "    Added no-subscription repo."
fi

# Ceph repo (if needed — comment out if you don't use Ceph)
# CEPH_REPO="/etc/apt/sources.list.d/ceph.list"
# if [[ -f "$CEPH_REPO" ]]; then
#   sed -i 's/^deb/#deb/' "$CEPH_REPO"
# fi

# =============================================================================
# Packages
# =============================================================================

apt-get update -qq
apt-get install -y -qq \
  vim \
  htop \
  tmux \
  tree \
  iotop \
  rsync \
  curl \
  jq \
  lm-sensors \
  smartmontools \
  > /dev/null

echo "    Packages installed."

# =============================================================================
# ZFS tuning
# =============================================================================

# TODO: Adjust zfs_arc_max to your RAM. Rule of thumb: ~50% of total RAM.
# Example: 16 GB = 8589934592 bytes
ZFS_CONF="/etc/modprobe.d/zfs.conf"
cat > "$ZFS_CONF" <<'EOF'
# Limit ARC to 8 GB (adjust to ~50% of host RAM)
options zfs zfs_arc_max=8589934592
EOF
echo "    ZFS tuning written to $ZFS_CONF."

# =============================================================================
# Storage
# =============================================================================

# Ensure local-zfs accepts container rootdirs and disk images
# TODO: Adjust the storage name to match your setup (check `pvesm status`)
pvesm set local-zfs --content images,rootdir 2>/dev/null || true

echo "    Storage configured."

# =============================================================================
# Networking
# =============================================================================

# Network config lives in /etc/network/interfaces and is usually set up during
# install. Only add overrides here if needed.
#
# Example: enable IP forwarding for containers
SYSCTL_CONF="/etc/sysctl.d/99-proxmox.conf"
cat > "$SYSCTL_CONF" <<'EOF'
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --system > /dev/null 2>&1
echo "    Sysctl configured."

# =============================================================================
# SSH hardening
# =============================================================================

SSHD_CONF="/etc/ssh/sshd_config.d/hardening.conf"
cat > "$SSHD_CONF" <<'EOF'
PermitRootLogin prohibit-password
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF

# Ensure your SSH key is present
ROOT_AUTHORIZED="/root/.ssh/authorized_keys"
SSH_KEY="ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGdZTXoDrg44XRILpY+O1o8UCU6bNMjQpSotNsKmIRdO8kMjls0bgSRUWO9rpxavzHun62DZAecNqF/DzZXTEhM= admin@staudacher.dev"
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if ! grep -qF "$SSH_KEY" "$ROOT_AUTHORIZED" 2>/dev/null; then
  echo "$SSH_KEY" >> "$ROOT_AUTHORIZED"
  echo "    SSH key added."
fi
chmod 600 "$ROOT_AUTHORIZED"

systemctl reload sshd 2>/dev/null || true
echo "    SSH hardened."

# =============================================================================
# Remove subscription nag (optional)
# =============================================================================

# Patches the Proxmox web UI to remove the "No valid subscription" popup.
# This gets overwritten on Proxmox upgrades, so re-run this script after updates.
JS_FILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
if [[ -f "$JS_FILE" ]] && grep -q "data.status.toLowerCase() !== 'active'" "$JS_FILE"; then
  sed -i.bak "s/data.status.toLowerCase() !== 'active'/false/g" "$JS_FILE"
  systemctl restart pveproxy 2>/dev/null || true
  echo "    Subscription nag removed."
else
  echo "    Subscription nag already patched or file not found."
fi

# =============================================================================
# Scheduled tasks
# =============================================================================

# Example: weekly ZFS scrub (adjust pool name)
# CRON_ZFS="/etc/cron.d/zfs-scrub"
# cat > "$CRON_ZFS" <<'EOF'
# # Weekly ZFS scrub on Sunday at 2 AM
# 0 2 * * 0 root /sbin/zpool scrub tank
# EOF

# Example: prune old container snapshots (keep last 5 per container)
# Add your own pruning logic here if needed.

# =============================================================================
# Firewall (optional — Proxmox has its own firewall)
# =============================================================================

# If you use Proxmox's built-in firewall, configure it via /etc/pve/firewall/
# rather than iptables directly. Example:
#
# cat > /etc/pve/firewall/cluster.fw <<'EOF'
# [OPTIONS]
# enable: 1
# policy_in: DROP
# policy_out: ACCEPT
#
# [RULES]
# IN ACCEPT -p tcp -dport 22
# IN ACCEPT -p tcp -dport 8006
# EOF

# =============================================================================
# Done
# =============================================================================

echo ""
echo "==> Proxmox host setup complete."
echo "    Review TODOs in this script and adjust values for your hardware."
echo "    Re-run after Proxmox upgrades to reapply patches."
