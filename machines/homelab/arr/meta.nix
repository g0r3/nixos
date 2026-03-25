# Proxmox container attributes for arr.
# These are read by deploy.sh via `nix eval`.
#
# "storage" must match the Proxmox storage ID (check `pvesm status`).
# For ZFS this is typically "local-zfs" or a custom name, NOT the dataset path.
# Proxmox creates subvolumes automatically (e.g. tank/disks/subvol-<vmid>-disk-0).
{
  vmid = 99999;
  hostname = "arr";
  cores = 2;
  memory = 2048;
  swap = 512;
  diskSize = "20";
  storage = "local-zfs";  # TODO: verify with `pvesm status` on Proxmox host
  bridge = "vmbr0";
  ip = "192.168.1.210/24";
  gateway = "192.168.1.1";
  nameserver = "192.168.1.1";
  template = "local:vztmpl/nixos-base.tar.xz";
  onboot = true;
  features = "nesting=1";
}
