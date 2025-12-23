{
  config,
  pkgs,
  lib,
  self',
  inputs,
  ...
}:
{

  imports = [
    ../../../modules/zsh.nix
    ../../../modules/maintenance.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "admin"
  ];
  networking.hostName = "arr";
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_IE.UTF-8";

  # boot.isContainer = true;
  # # Supress systemd units that don't work because of LXC
  # systemd.suppressedSystemUnits = [
  #   "dev-mqueue.mount"
  #   "sys-kernel-debug.mount"
  #   "sys-fs-fuse-connections.mount"
  # ];
  #
  # users.users = {
  #   admin = {
  #     isNormalUser = true;
  #     description = "Administrator";
  #     extraGroups = [ "networkmanager" "wheel" "mlocate" ];
  #     shell = pkgs.zsh;
  #   };
  #   root = {
  #     shell = pkgs.zsh;
  #   };
  # };
  #
  # environment.systemPackages = with pkgs; [
  #   neovim
  #   wget
  #   jq
  #   mlocate
  #   ethtool
  #   hdparm
  #   dig
  #   dmidecode
  #   unzip
  #   zsh
  #   nmap
  #   usbutils
  #   tree
  # ];
  #
  # services.locate = {
  #   enable = true;
  #   package = pkgs.mlocate;
  #   interval = "hourly";
  # };
  #
  # # Configure keymap in X11
  # services.xserver.enable = true;
  # services.xserver.xkb = {
  #     layout = "us";
  #     variant = "de_se_fi";
  # };
  # networking.networkmanager.enable = true;
  # networking.firewall.enable = false;
  #
  # security.polkit.enable = true;

  # SSH server
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
}
