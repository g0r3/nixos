# nixos/machines/desktop/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
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

  nixpkgs.overlays = [
    (final: prev: {
      mfcl3750cdw = final.callPackage ../../pkgs/mfcl3750cdw/default.nix { };
    })
  ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim
    wget
    jq
    mlocate
    ferdium
    hdparm
    dig
    dmidecode
    git
    unzip
    pyright
    stow
    stylua
    clang
    zsh
    python314
    mfcl3750cdw
    geary
    pciutils
    brave
    spotify
    sublime3
    obsidian
    libreoffice
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

  services.printing.enable = true;
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    brscan4 = {
 	enable = true;
	netDevices = {
	home = { model = "MFC-L3750CDW"; ip = "printer.staudacher.dev"; };
	};
    };
  };
  environment.etc."sane.d/airscan.conf".text = ''
    [devices]
    "Brother MFC-L3750CDW" = http://printer.staudacher.dev:80/WebServices/ScannerService, WSD
  '';
  hardware.printers.drivers = [ 
    pkgs.mfcl3750cdw 
  ];
#   hardware.printers = {
#   ensurePrinters = [
#     {
#       name = "Brother MFC-3750CDW";
#       location = "Living Room";
#       deviceUri = "http:///printers/Dell_1250c";
#       model = "drv:///sample.drv/generic.ppd";
#       ppdOptions = {
#         PageSize = "A4";
#       };
#     }
#   ];
#   ensureDefaultPrinter = "Dell_1250c";
# };
}
