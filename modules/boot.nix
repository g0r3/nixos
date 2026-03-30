{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.boot;
in
{
  options.modules.boot.enable = lib.mkEnableOption "Whether to enable the boot module";

  config = lib.mkIf cfg.enable {
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.configurationLimit = 30;
    boot.loader.systemd-boot.editor = false;
    boot.kernelParams = [
      "quiet"
      "loglevel=3"
      "amd_pstate=active"
    ];
    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernelModules = [ ];
  };
}
