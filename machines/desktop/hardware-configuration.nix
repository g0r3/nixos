{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ 
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/373cd691-d7fe-4e39-bdbd-532fc739ad40";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "compress=zstd" "ssd" "discard=async" "space_cache=v2" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/373cd691-d7fe-4e39-bdbd-532fc739ad40";
      fsType = "btrfs";
      options = [ "subvol=@home" "noatime" "compress=zstd" "ssd" "discard=async" "space_cache=v2"  ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/373cd691-d7fe-4e39-bdbd-532fc739ad40";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd" "ssd" "discard=async" "space_cache=v2"  ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/373cd691-d7fe-4e39-bdbd-532fc739ad40";
      fsType = "btrfs";
      options = [ "subvol=@log" "noatime" "compress=zstd" "ssd" "discard=async" "space_cache=v2"  ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3BE9-F6B0";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

}
