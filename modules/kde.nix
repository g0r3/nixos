{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      shutdown-or-switch = final.callPackage ../packages/shutdown-or-switch/package.nix { };
      window-title-applet = final.callPackage ../packages/window-title-applet/package.nix { };
    })
  ];

  # Enable KDE Plasma 6
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
    kate
  ];

  # KDE-related packages and themes
  environment.systemPackages = with pkgs; [
    shutdown-or-switch
    window-title-applet
    kdePackages.merkuro
    kdePackages.kscreenlocker
    kdePackages.kcalc
    kdePackages.kdeconnect-kde
    kdePackages.print-manager
    simple-scan
    colloid-gtk-theme
    whitesur-kde
    whitesur-cursors
    whitesur-gtk-theme
    (whitesur-icon-theme.override { alternativeIcons = true; })
  ];
}
