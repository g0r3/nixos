{ config, pkgs, ... }:

{
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.systemd-boot.editor = false;
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
  ];
  boot.kernelModules = [ ];
}
