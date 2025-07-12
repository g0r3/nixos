# nixos/desktop/boot.nix
{ config, pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"; # Use stable ID
    useOSProber = true;
    timeout = 0;
  };

  # Enable "Silent boot"
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "splash" "boot.shell_on_fail" "udev.log_priority=3" "rd.systemd.show_status=auto" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Plymouth theme
  boot.plymouth = {
    enable = true;
    theme = "rings";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "rings" ];
      })
    ];
  };
}
