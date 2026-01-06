{ config, pkgs, lib, ... }:

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

  systemd.tmpfiles.rules = lib.mkIf (config.networking.hostName == "desktop") [
    "f /var/lib/sddm/.config/kwinoutputconfig.json 0600 sddm sddm - ${
      builtins.toJSON [
        {
          data = [
            {
              allowDdcCi = true;
              allowSdrSoftwareBrightness = true;
              autoRotation = "InTabletMode";
              brightness = 1;
              colorPowerTradeoff = "PreferEfficiency";
              colorProfileSource = "sRGB";
              connectorName = "DP-1";
              detectedDdcCi = false;
              edidHash = "94b7af4319b4e04e1453c1c1d998619d";
              edidIdentifier = "HWV 28194 3229677090 36 2021 0";
              edrPolicy = "always";
              highDynamicRange = false;
              iccProfilePath = "";
              maxBitsPerColor = 0;
              mode = {
                height = 2560;
                refreshRate = 59984;
                width = 3840;
              };
              overscan = 0;
              rgbRange = "Automatic";
              scale = 1.5;
              sdrBrightness = 496;
              sdrGamutWideness = 1;
              transform = "Normal";
              uuid = "636bebfa-73dd-4579-bc6c-974b25b9374d";
              vrrPolicy = "Never";
              wideColorGamut = false;
            }
            {
              allowDdcCi = true;
              allowSdrSoftwareBrightness = true;
              autoRotation = "InTabletMode";
              brightness = 1;
              colorPowerTradeoff = "PreferEfficiency";
              colorProfileSource = "sRGB";
              connectorName = "DP-2";
              detectedDdcCi = false;
              edidHash = "a3b6116671b7575b7d5395f4f73cd19b";
              edidIdentifier = "HWV 28194 3229677090 25 2021 0";
              edrPolicy = "always";
              highDynamicRange = false;
              iccProfilePath = "";
              maxBitsPerColor = 0;
              mode = {
                height = 2560;
                refreshRate = 59984;
                width = 3840;
              };
              overscan = 0;
              rgbRange = "Automatic";
              scale = 1.5;
              sdrBrightness = 496;
              sdrGamutWideness = 0;
              transform = "Normal";
              uuid = "6ddfea38-da49-49a7-9afb-91c32426fb90";
              vrrPolicy = "Never";
              wideColorGamut = false;
            }
          ];
          name = "outputs";
        }
        {
          data = [
            {
              lidClosed = false;
              outputs = [
                {
                  enabled = true;
                  outputIndex = 0;
                  position = {
                    x = 0;
                    y = 0;
                  };
                  priority = 0;
                  replicationSource = "";
                }
                {
                  enabled = false;
                  outputIndex = 1;
                  position = {
                    x = 2560;
                    y = 0;
                  };
                  priority = 1;
                  replicationSource = "";
                }
              ];
            }
          ];
          name = "setups";
        }
      ]
    }"
  ];
}
