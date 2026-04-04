{
  config,
  lib,
  isLinux,
  ...
}:
let
  cfg = config.modules.shares;
in
{
  options.modules.shares.enable = lib.mkEnableOption "Whether to enable the shares module";

  config = lib.optionalAttrs isLinux (lib.mkIf cfg.enable {
    fileSystems."/mnt/files" = {
      device = "nas.staudacher.dev:/files";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.mount-timeout=10s"
        "timeo=15"
        "soft"
      ];
    };

    fileSystems."/mnt/media" = {
      device = "nas.staudacher.dev:/media";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.mount-timeout=10s"
        "timeo=15"
        "soft"
      ];
    };

    fileSystems."/mnt/backups" = {
      device = "nas.staudacher.dev:/backups";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.mount-timeout=10s"
        "timeo=15"
        "soft"
      ];
    };

    fileSystems."/mnt/seedbox" = {
      device = "nas.staudacher.dev:/seedbox";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.mount-timeout=10s"
        "timeo=15"
        "soft"
      ];
    };
  });
}
