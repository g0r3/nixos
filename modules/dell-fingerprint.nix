{
  config,
  pkgs,
  lib,
  isNixos,
  isDarwin,
  ...
}:
let
  cfg = config.modules.dell-fingerprint;
  libfprint-2-tod1-broadcom-cv3plus =
    pkgs.callPackage ../packages/libfprint-2-tod1-broadcom-cv3plus/package.nix
      { };

in
{

  options.modules.dell-fingerprint.enable = lib.mkEnableOption "Whether to enable the dell-fingerprint module";

  config = lib.mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod.enable = true;
      # Search for "libfprint" in packages to find other drivers
      tod.driver = libfprint-2-tod1-broadcom-cv3plus;
    };
    # Disable fingerprint auth for SDDM and KDE/login to prevent the 30s hang
    security.pam.services.sddm.fprintAuth = false;

    # If you are using KDE Plasma, also add:
    security.pam.services.kde.fprintAuth = false;
    security.pam.services.login.fprintAuth = false;

    systemd.services.fprintd.serviceConfig = {
      BindReadOnlyPaths = [
        "${libfprint-2-tod1-broadcom-cv3plus}${libfprint-2-tod1-broadcom-cv3plus.passthru.firmwarePath}:/var/lib/fprint/.broadcomCv3plusFW"
      ];
    };
  };
}
