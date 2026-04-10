{
  config,
  pkgs,
  lib,
  isLinux,
  ...
}:
let
  cfg = config.modules.dell-fingerprint;
  libfprint-2-tod1-broadcom-cv3plus =
    pkgs.callPackage ../packages/libfprint-2-tod1-broadcom-cv3plus/package.nix
      { };
in
{
  options = {
    modules.dell-fingerprint.enable = lib.mkEnableOption "Whether to enable the dell-fingerprint module";

    # Override the fprintAuth default from true (when fprintd is enabled) to false.
    # The Broadcom CV3+ driver prints chatty init messages through PAM into
    # terminals and UIs, so we only opt-in for services where it's useful.
    security.pam.services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        config.fprintAuth = lib.mkIf cfg.enable (lib.mkDefault false);
      });
    };
  };

  config = lib.optionalAttrs isLinux (lib.mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod.enable = true;
      # Search for "libfprint" in packages to find other drivers
      tod.driver = libfprint-2-tod1-broadcom-cv3plus;
    };

    # Only enable fingerprint for services where it's useful
    security.pam.services.kscreenlocker.fprintAuth = true;
    security.pam.services.sudo.fprintAuth = true;
    security.pam.services.polkit-1.fprintAuth = true;

    systemd.services.fprintd.serviceConfig = {
      BindReadOnlyPaths = [
        "${libfprint-2-tod1-broadcom-cv3plus}${libfprint-2-tod1-broadcom-cv3plus.passthru.firmwarePath}:/var/lib/fprint/.broadcomCv3plusFW"
      ];
      # Suppress chatty Broadcom driver init messages from leaking through PAM
      StandardOutput = "journal";
      StandardError = "journal";
    };
  });
}
