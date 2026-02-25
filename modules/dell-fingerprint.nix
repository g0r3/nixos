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
    security.pam.services.sddm.fprintAuth = true;

    systemd.services.fprintd.serviceConfig = {
      BindReadOnlyPaths = [
        "${libfprint-2-tod1-broadcom-cv3plus}${libfprint-2-tod1-broadcom-cv3plus.passthru.firmwarePath}:/var/lib/fprint/.broadcomCv3plusFW"
      ];
    };
  };
}
