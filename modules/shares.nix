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
    environment.etc.fstab.text =
      let
        mountOptions = "rw,soft,bg,timeo=15";
        mkEntry = share: "${share.device} ${basePath}${share.mountPoint} nfs ${mountOptions} 0 0";
      in
      lib.concatMapStringsSep "\n" mkEntry shares + "\n";

    system.activationScripts.createMountPoints.text = ''
      echo "Creating mount points..."
      ${lib.concatMapStringsSep "\n" (share: "mkdir -p ${basePath}${share.mountPoint}") shares}
      chown reinhard:staff ${basePath}/*
    '';
  };
in
if isDarwin then darwinConfig else nixosConfig
