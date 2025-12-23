{
  config,
  pkgs,
  lib,
  self',
  inputs,
  modulesPath,
  ...
}:

let
  id = 99999; # Used only in the deploy script
  ip = "192.168.1.210";
  hostname = "arr";
in
{

  imports = [
    ../../../modules/zsh.nix
    # ../../../modules/maintenance.nix
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
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

  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = ip;
      prefixLength = 24;
    }
  ];

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
    };
  };
  networking.hostName = hostname;
  networking.hostId = "81e9336e";
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  system.stateVersion = "25.05";
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_IE.UTF-8";

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
}
