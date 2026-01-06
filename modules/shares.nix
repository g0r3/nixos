{
  config,
  lib,
  pkgs,
  modulesPath,
  isDarwin ? false,
  ...
}:
let
  shares = [
    {
      mountPoint = "/files";
      device = "nas.staudacher.dev:/files";
    }
    {
      mountPoint = "/media";
      device = "nas.staudacher.dev:/media";
    }
    {
      mountPoint = "/backups";
      device = "nas.staudacher.dev:/backups";
    }
    {
      mountPoint = "/seedbox";
      device = "nas.staudacher.dev:/seedbox";
    }
  ];

  basePath = if isDarwin then "/Users/reinhard/mnt" else "/mnt";

  # NixOS Configuration
  nixosConfig = {
    fileSystems = lib.listToAttrs (
      map (share: {
        name = "${basePath}${share.mountPoint}";
        value = {
          device = share.device;
          fsType = "nfs";
          options = [
            "x-systemd.automount"
            "noauto"
            "x-systemd.mount-timeout=10s"
            "timeo=15"
            "soft"
          ];
        };
      }) shares
    );
  };

  # Darwin Configuration
  darwinConfig = {
    system.activationScripts.createMountPoints.text = ''
      echo "Creating mount points..."
      ${lib.concatMapStringsSep "\n" (share: "mkdir -p ${basePath}${share.mountPoint}") shares}
      chown reinhard:staff ${basePath}/*
    '';

    launchd.daemons.nfs-mounts = {
      serviceConfig = {
        Label = "net.staudacher.nfs-mounts";
        RunAtLoad = true;
        KeepAlive = {
          NetworkState = true;
        };
      };
      script = ''
        ${lib.concatMapStringsSep "\n" (share: ''
          if ! mount | grep -q "${basePath}${share.mountPoint}"; then
            echo "Mounting ${share.mountPoint}..."
            mount -t nfs -o rw,soft,bg,timeo=15 ${share.device} ${basePath}${share.mountPoint}
          else
            echo "${share.mountPoint} is already mounted."
          fi
        '') shares}
      '';
    };
  };
in
if isDarwin then darwinConfig else nixosConfig
