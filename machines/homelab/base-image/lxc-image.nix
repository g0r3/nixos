# Base NixOS LXC image for Proxmox.
# Build with: nix run github:nix-community/nixos-generators -- -f lxc -c machines/homelab/base-image/lxc-image.nix -o result
# Upload:     scp result/tarball/nixos-lxc-*.tar.xz root@proxmox:/var/lib/vz/template/cache/nixos-base.tar.xz
{ modulesPath, pkgs, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  # Minimal SSH access so deploy.sh can connect on first boot
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGdZTXoDrg44XRILpY+O1o8UCU6bNMjQpSotNsKmIRdO8kMjls0bgSRUWO9rpxavzHun62DZAecNqF/DzZXTEhM= admin@staudacher.dev"
  ];

  networking.useDHCP = true;

  # Bare minimum packages for bootstrapping
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.05";
}
