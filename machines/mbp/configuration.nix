{
  pkgs,
  inputs,
  config,
  ...
}:
{

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../modules
  ];

  environment.systemPackages = with pkgs; [
    mas
    # displaylink
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  homebrew = {
    enable = true;
    brews = [
      # Add your CLI-apps here
      # Only for those that are not worth their own module
    ];
    casks = [
      # Add your GUI-apps here
      # Only for those that are not worth their own module
    ];
    masApps = {
      # You need to be logged in to the App Store and own the application
      # Get the ID by searching with 'mas search <appname>'
      # "Yoink" = 457622435;
      # Netflix
      # Amazon Prime Video
      # Plex
    };
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };

  # Homebrew for applications not available/broken on nix-darwin
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "reinhard";
  };

  modules = {
    base-desktop.enable = true;
    bitwarden = {
      enable = true;
      sshAgent.enable = true;
    };
    ferdium.enable = true;
    git = {
      enable = true;
      userEmail = "3685646+g0r3@users.noreply.github.com";
      userName = "g0r3";
    };
    kicad.enable = true;
    neovim.enable = true;
    printer.enable = true;
    prusa.enable = true;
    shares.enable = true;
    steam.enable = true;
    zsh.enable = true;
  };

  networking.hostName = "mbp";

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    activationScripts = {
      keyboard.text = ''
        # Install Custom Keyboard Layout
        echo "Installing Custom Keyboard Layout..."
        mkdir -p "/Library/Keyboard Layouts"
        cp -f "${./us_with_umlauts.keylayout}" "/Library/Keyboard Layouts/EurKEY.keylayout"
      '';
      postActivation.text = ''
        pmset -b lessbright 0  # do NOT dim display on battery (differs from default of 1)

        # Set Finder sidebar favorites
        sudo -u reinhard ${pkgs.mysides}/bin/mysides remove all 2>/dev/null || true
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Applications file:///Applications/
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Desktop file:///Users/reinhard/Desktop/
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Documents file:///Users/reinhard/Documents/
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Downloads file:///Users/reinhard/Downloads/
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Movies file:///Users/reinhard/Movies/
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Music file:///Users/reinhard/Music/
        sudo -u reinhard ${pkgs.mysides}/bin/mysides add Pictures file:///Users/reinhard/Pictures/
      '';
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    defaults = {
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 2; # full keyboard access
        KeyRepeat = 2;
        "com.apple.swipescrolldirection" = false;
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleActionOnDoubleClick = "None";
          "com.apple.mouse.linear" = true; # linear mouse acceleration
          "com.apple.scrollwheel.scaling" = "0.3125";
        };
        "com.apple.AppleMultitouchTrackpad" = {
          TrackpadMomentumScroll = false;
        };
        "com.apple.HIToolbox" = {
          # The currently selected layout
          AppleCurrentKeyboardLayoutInputSourceID = "org.unknown.keylayout.USwithgermanUmlauts";

          # The list of layouts available in the menu bar
          AppleEnabledInputSources = [
            {
              InputSourceKind = "Keyboard Layout";
              "KeyboardLayout ID" = -14519;
              "KeyboardLayout Name" = "US with german Umlauts";
            }
          ];

          # The layout that is actively being used
          AppleSelectedInputSources = [
            {
              InputSourceKind = "Keyboard Layout";
              "KeyboardLayout ID" = -14519;
              "KeyboardLayout Name" = "US with german Umlauts";
            }
          ];
        };
        "com.apple.TextInputMenu" = {
          visible = false; # hide text input menu bar icon
        };
        "com.apple.WindowManager" = {
          "EnableStandardClickToShowDesktop" = 0;
        };
        "com.apple.assistant.support" = {
          "Assistant Enabled" = false; # disable Siri
        };
        "com.apple.controlstrip" = {
          MiniCustomized = [
            "com.apple.system.brightness"
            "com.apple.system.volume"
            "com.apple.system.mute"
            "com.apple.system.launchpad"
          ];
        };
        "com.apple.dock" = {
          showDesktopGestureEnabled = false;
        };
        "com.apple.finder" = {
          ShowRecentTags = true;
        };
        "com.apple.menuextra.clock" = {
          ShowDate = 0; # hide date in menu bar clock
        };
        "com.apple.sidebarlists" = {
          networkbrowser = {
            CustomListProperties = {
              "com.apple.NetworkBrowser.bonjourEnabled" = false;
            };
          };
        };
        "com.apple.touchbar.agent" = {
          PresentationModeGlobal = "app";
          PresentationModeFnModes = {
            appWithControlStrip = "functionKeys";
          };
          PresentationModePerApp = {
            "com.github.wez.wezterm" = "functionKeys";
          };
        };
        "com.apple.widgets" = {
          "widget-style" = 2;
        };
      };
      WindowManager = {
        EnableTiledWindowMargins = true;
        StandardHideWidgets = true;
      };
      controlcenter = {
        Bluetooth = true;
        Sound = true;
      };
      dock = {
        autohide = true;
        minimize-to-application = true;
        persistent-apps = [
          "${pkgs.wezterm}/Applications/Wezterm.app"
          "${pkgs.brave}/Applications/Brave Browser.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Contacts.app"
          "/System/Applications/App Store.app"
          "${pkgs.spotify}/Applications/Spotify.app"
          "/Applications/KiCad/KiCad.app"
          "/Applications/FreeCAD.app"
          "/System/Applications/System Settings.app"
        ];
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
        NewWindowTarget = "Home";
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
        _FXSortFoldersFirst = true;
      };
      hitoolbox.AppleFnUsageType = "Do Nothing";
      loginwindow.GuestEnabled = false;
      trackpad = {
        Clicking = true; # tap to click
      };
    };

    keyboard = {
      enableKeyMapping = true;
      swapLeftCtrlAndFn = false;
    };

    primaryUser = "reinhard";

    startup.chime = false;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;
  };
}
