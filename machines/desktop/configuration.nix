{
  config,
  pkgs,
  lib,
  self',
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/bitwarden.nix
    ../../modules/base-desktop.nix
    ../../modules/kde.nix
    ../../modules/steam.nix
    ../../modules/shares.nix
    ../../modules/zsh.nix
    ../../modules/printer.nix
    ../../modules/maintenance.nix
    ../../modules/ferdium.nix
    ../../modules/arduino.nix
    ../../modules/kicad.nix
    ../../modules/neovim.nix
    ../../modules/base.nix
    ../../modules/prusa.nix
  ];

  networking.hostName = "desktop";
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_IE.UTF-8";

  users.users = {
    reinhard = {
      isNormalUser = true;
      description = "Reinhard Staudacher";
      extraGroups = [
        "audio"
        "networkmanager"
        "wheel"
        "dialout" # platformio development
        "scanner"
        "lp"
        "mlocate"
      ];
      shell = pkgs.zsh;
    };
    root = {
      shell = pkgs.zsh;
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
    pavucontrol
    pamixer
    alsa-utils
    neofetch
    stow
    clang
    gemini-cli-bin
    nurl # generates Nix fetcher calls
    ipcalc
  ];

  modules = {
    bitwarden.enable = true;
    ferdium.enable = true;
    prusa.enable = true;
    neovim.enable = true;
    kicad.enable = true;
  };

  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
  };

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
  services.openssh.settings.PasswordAuthentication = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
