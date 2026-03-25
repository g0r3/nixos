# NixOS Configuration Repository

## Overview

This repo manages NixOS (and nix-darwin) configurations for multiple machines via a flake.

## Structure

```
flake.nix                        # Entry point — defines all system configurations
modules/                         # Shared NixOS modules
  lxc-common.nix                 # Common config for all homelab LXC containers
  zsh-nixos.nix, maintenance.nix # Used by lxc-common.nix
  ...                            # Other modules (desktop, docker, etc.)
machines/
  desktop/                       # Desktop NixOS machine
  ENG-rstaudacher/               # Work laptop
  macbook/                       # macOS via nix-darwin
  homelab/                       # Proxmox homelab containers
    base-image/lxc-image.nix     # NixOS LXC template (build with nixos-generators)
    deploy.sh                    # Deploy/update script for LXC containers
    <container>/
      meta.nix                   # Proxmox attributes (vmid, cores, memory, ip, ...)
      configuration.nix          # NixOS config (imports modules/lxc-common.nix)
```

## Homelab / LXC Container Deployment

### Architecture

- Proxmox host uses **ZFS** storage backend (`tank` pool)
- Containers are **unprivileged** NixOS LXC containers
- `meta.nix` is the single source of truth for Proxmox-level attributes
- `configuration.nix` is the NixOS config — NixOS owns everything inside the container
- Proxmox UI fields are informational only (description warns "MANAGED BY NIX")
- Deploy script enforces `meta.nix` values on every run (drift correction)

### deploy.sh Usage

```bash
cd machines/homelab

# Deploy (create or update) a single container:
./deploy.sh arr [proxmox-host]

# Update all existing containers (skip create, only sync+rebuild):
./deploy.sh --update-all [proxmox-host]

# Default proxmox-host: root@proxmox
```

### What deploy.sh does

1. Reads container attributes from `meta.nix` via `nix eval`
2. Creates the container if it doesn't exist (`pct create`), or updates resources (`pct set`)
3. Takes a ZFS-safe snapshot before deploying
4. Rsyncs the entire repo to `/etc/nixos/` on the container
5. Symlinks the container's `configuration.nix` to `/etc/nixos/configuration.nix`
6. Runs `nixos-rebuild switch` (with automatic rollback on failure)

### Adding a new container

1. Create `machines/homelab/<name>/meta.nix` (copy from `arr/meta.nix`, adjust values)
2. Create `machines/homelab/<name>/configuration.nix` (import `modules/lxc-common.nix`)
3. Uncomment/add the entry in `flake.nix` under `nixosConfigurations`
4. Run `./deploy.sh <name>`

### Building the base image

```bash
nix run github:nix-community/nixos-generators -- \
  -f lxc -c machines/homelab/base-image/lxc-image.nix -o result
scp result/tarball/nixos-lxc-*.tar.xz root@proxmox:/var/lib/vz/template/cache/nixos-base.tar.xz
```

### Key decisions / gotchas

- **ZFS snapshots**: `pct snapshot` works but `--description` flag may fail on some Proxmox versions; snapshot names are kept alphanumeric
- **Storage ID**: `meta.nix` `storage` must match `pvesm status` output (e.g. `local-zfs`), NOT the ZFS dataset path
- **Proxmox vs NixOS**: NixOS manages all config inside the container. Proxmox `net0` line is informational for the UI
- **pct exec PATH**: `lxc-common.nix` sets up `/etc/profile.d/nix-path.sh` and symlinks (`/sbin/ip`, etc.) so Proxmox tools work
- **nesting=1**: Required in `features` so Nix can build inside the container

## TODOs

- [ ] Verify `storage` value in `meta.nix` with `pvesm status` on the Proxmox host
- [ ] Build and upload the base LXC image (`base-image/lxc-image.nix`)
- [ ] Test deploy of `arr` container end-to-end
- [ ] Consider building NixOS closures locally and copying via `nix copy` for faster deploys
- [ ] Migrate existing manually configured containers to this setup
- [ ] Add `arr` (and future containers) to `flake.nix` `nixosConfigurations`
- [ ] Remove old `machines/homelab/base/`, `container-base/`, `template-configuration.nix` once migrated
