{ config, pkgs, lib, self', inputs, ... }:{
  imports = [
    ../base/base.nix
  ];
  networking.hostName = "arr";

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
}

