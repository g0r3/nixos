# nixos/desktop/kde.nix
{ config, pkgs, ... }:

{
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
  ];

  # KDE-related packages and themes
  environment.systemPackages = with pkgs; [
    kdePackages.merkuro
    kdePackages.kcalc
    kdePackages.print-manager
    simple-scan
    colloid-gtk-theme
    whitesur-kde
    whitesur-cursors
    whitesur-gtk-theme
    (whitesur-icon-theme.override { alternativeIcons = true; })
  ];
}
