{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.kde;
in
{
  options.modules.kde.enable = lib.mkEnableOption "Whether to enable the KDE module";

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        shutdown-or-switch = final.callPackage ../packages/shutdown-or-switch/package.nix { };
        plasma6-window-title-applet =
          final.callPackage ../packages/plasma6-window-title-applet/package.nix
            { };
        # Fix oversized microphone tray icon in WhiteSur icon theme.
        # The mic SVGs fill the full canvas while other status icons (e.g. volume)
        # wrap content in a translate(3,3) for internal padding. This applies a
        # scale-down transform to the mic icon content to match the visual weight
        # of other tray icons.
        whitesur-icon-theme = prev.whitesur-icon-theme.overrideAttrs (oldAttrs: {
          postFixup = (oldAttrs.postFixup or "") + ''
            for theme in WhiteSur WhiteSur-dark WhiteSur-light; do
              for size in 16 22 24; do
                dir="$out/share/icons/$theme/status/$size"
                [ -d "$dir" ] || continue
                for svg in "$dir"/microphone-sensitivity-*.svg "$dir"/audio-input-microphone-*.svg; do
                  [ -f "$svg" ] || continue
                  # Scale content to 75% and center it (offset = size * 0.125)
                  offset=$(echo "$size * 0.125" | ${final.bc}/bin/bc)
                  ${final.gnused}/bin/sed -i \
                    "s|<svg \(.*\)>|<svg \1><g transform=\"translate($offset,$offset) scale(0.75)\">|; s|</svg>|</g></svg>|" \
                    "$svg"
                done
              done
            done
          '';
        });
      })
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Enable KDE Plasma 6
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = [ "kde" ];
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      elisa
      kate
    ];

    # KDE-related packages and themes
    environment.systemPackages = with pkgs; [
      shutdown-or-switch
      plasma6-window-title-applet
      kdePackages.merkuro
      kdePackages.sddm-kcm
      kdePackages.kcolorchooser
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
  };
}
