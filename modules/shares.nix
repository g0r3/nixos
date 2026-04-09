{
  config,
  lib,
  isLinux,
  isDarwin,
  ...
}:
let
  cfg = config.modules.shares;

  shares = {
    files = "nas.staudacher.dev:/files";
    media = "nas.staudacher.dev:/media";
    backups = "nas.staudacher.dev:/backups";
    seedbox = "nas.staudacher.dev:/seedbox";
  };
in
{
  options.modules.shares.enable = lib.mkEnableOption "Whether to enable the shares module";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Linux: NFS with systemd automount
    (lib.optionalAttrs isLinux {
      fileSystems = lib.mapAttrs' (name: device:
        lib.nameValuePair "/mnt/${name}" {
          inherit device;
          fsType = "nfs";
          options = [
            "x-systemd.automount"
            "noauto"
            "x-systemd.mount-timeout=10s"
            "timeo=15"
            "soft"
          ];
        }
      ) shares;
    })

    # Darwin: NFS via LaunchDaemon (visible in Finder, bg retries if WiFi isn't ready)
    (lib.optionalAttrs isDarwin {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        # Clean up old autofs config if present
        sed -i '''''' '/auto_nfs/d' /etc/auto_master
        rm -f /etc/auto_nfs
        automount -vc 2>/dev/null || true
      '';

      launchd.daemons.nfs-shares = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: device: ''
              mkdir -p /Volumes/${name}
              mount_nfs -o soft,bg,timeo=15,locallocks,resvport ${device} /Volumes/${name}
            '') shares))
          ];
          RunAtLoad = true;
        };
      };
    })
  ]);
}
