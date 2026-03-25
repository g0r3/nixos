# Common module for all homelab LXC containers.
# Import this in every container's configuration.nix.
{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./zsh-nixos.nix
    ./maintenance.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "admin"
    "reinhard"
  ];

  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_IE.UTF-8";

  # Users
  users.users = {
    admin = {
      isNormalUser = true;
      description = "Administrator";
      extraGroups = [
        "networkmanager"
        "wheel"
        "mlocate"
      ];
      hashedPassword = "$6$jGapx9ybCE2Tftb3$iwbJqU87HMXKyMSEQrszQxZda4Nzvjnpx/OZdhPIoKUKzhJdiAZXADuNeOA3qBZ7LP6gNGPvbRxM7qHrVGgDH/";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGdZTXoDrg44XRILpY+O1o8UCU6bNMjQpSotNsKmIRdO8kMjls0bgSRUWO9rpxavzHun62DZAecNqF/DzZXTEhM= admin@staudacher.dev"
      ];
    };
    root = {
      shell = pkgs.zsh;
      hashedPassword = "$6$jGapx9ybCE2Tftb3$iwbJqU87HMXKyMSEQrszQxZda4Nzvjnpx/OZdhPIoKUKzhJdiAZXADuNeOA3qBZ7LP6gNGPvbRxM7qHrVGgDH/";
      openssh.authorizedKeys.keys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGdZTXoDrg44XRILpY+O1o8UCU6bNMjQpSotNsKmIRdO8kMjls0bgSRUWO9rpxavzHun62DZAecNqF/DzZXTEhM= admin@staudacher.dev"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Firewall on by default — containers override with allowedTCPPorts
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Symlinks so Proxmox can query container state and pct exec works
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/ip - - - - /run/current-system/sw/bin/ip"
    "L+ /sbin/ip           - - - - /run/current-system/sw/bin/ip"
  ];

  # Fix PATH for pct exec / pct enter (lxc-attach uses minimal PATH)
  environment.etc."profile.d/nix-path.sh".text = ''
    export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
  '';

  environment.systemPackages = with pkgs; [
    vim
    htop
    tmux
    git
    jq
    tree
  ];

  system.stateVersion = lib.mkDefault "25.05";
}
