# nixos/machines/desktop/configuration.nix
{ config, pkgs, lib, self', inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      mfcl3750cdw = final.callPackage ../../packages/mfcl3750cdw/default.nix { };
    })
  ];

  imports = [
    # <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/kde.nix
    ../../modules/shares.nix
    ../../modules/user.nix
    ../../dotfiles/zsh/default.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];  
  networking.hostName = "desktop";
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_IE.UTF-8";

  # nixpkgs.config.packageOverrides = pkgs: {
  #   steam = pkgs.steam.override {
  #     extraPkgs = pkgs: with pkgs; [
  #       xorg.libXcursor
  #       xorg.libXi
  #       xorg.libXinerama
  #       xorg.libXScrnSaver
  #       libpng
  #       libpulseaudio
  #       libvorbis
  #       stdenv.cc.cc.lib
  #       libkrb5
  #       keyutils
  #     ]   };
  # };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim
    wget
    jq
    mlocate
    pavucontrol # PulseAudio Volume Control
    pamixer
    alsa-utils
    ferdium
    ethtool
    hdparm
    dig
    dmidecode
    git
    unzip
    gamescope
    pyright
    stow
    stylua
    wl-clipboard
    clang
    zsh
    python314
    ripgrep
    geary
    pciutils
    nmap
    brave
    spotify
    sublime3
    obsidian
    libreoffice
    usbutils
    prusa-slicer
    kicad
    gnome-disk-utility
    bitwarden
    system-config-printer
    tree
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


  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };



  services.printing = {
    enable = true;
    drivers = [ pkgs.mfcl3750cdw.cupswrapper ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "Brother_MFC_L3750CDW";
    ensurePrinters = [
      {
        name = "Brother_MFC_L3750CDW";
        model = "brother_mfcl3750cdw_printer_en.ppd";
        location = "Living Room";
        description = "Brother MFC-L3750CDW";
        deviceUri = "ipp://printer.staudacher.dev/ipp/print";
        ppdOptions.PageSize = "A4";
      }
    ];
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  environment.etc."sane.d/airscan.conf".text = ''
    [devices]
    "Brother MFC-L3750CDW" = https://printer.staudacher.dev/eSCL

    [options]
    discovery = disable
  '';

}

