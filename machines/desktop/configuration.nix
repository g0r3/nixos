# nixos/machines/desktop/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/kde.nix
    ../../modules/user.nix
    ../../dotfiles/zsh/default.nix
  ];
  
  networking.hostName = "desktop";
  system.stateVersion = "25.05";
  nix.settings.trusted-users = [ "root" "@wheel" ];
  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_IE.UTF-8";
  # i18n.extraLocaleSettings = {
  #     LC_ADDRESS = "en_IE.UTF-8";
  #     LC_IDENTIFICATION = "en_IE.UTF-8";
  #     LC_MEASUREMENT = "en_IE.UTF-8";
  #     LC_MONETARY = "en_IE.UTF-8";
  #     LC_NAME = "en_IE.UTF-8";
  #     LC_NUMERIC = "en_IE.UTF-8";
  #     LC_PAPER = "en_IE.UTF-8";
  #     LC_TELEPHONE = "en_IE.UTF-8";
  #     LC_TIME = "en_IE.UTF-8";
  # };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim
    wget
    mlocate
    hdparm
    dmidecode
    git
    zsh
    geary
    brave
    spotify
    sublime3
    obsidian
    nfs-utils
    libreoffice
    prusa-slicer
    kicad
    gnome-disk-utility
    bitwarden
    tree
    sane-airscan
  ];

  # Configure keymap in X11
  services.xserver.enable = true;
  services.xserver.xkb = {
      layout = "us";
      variant = "de_se_fi";
  };
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  security.polkit.enable = true;

  # SSH server
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false; # Recommended for security

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
