{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../../modules/lxc-common.nix
  ];

  networking.hostName = "arr";
  networking.hostId = "81e9336e";

  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.1.210";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
}
