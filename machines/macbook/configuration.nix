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

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # The primary user of the package
  system.primaryUser = "reinhard";

  networking.hostName = "macbook-pro";

  environment.systemPackages = with pkgs; [
    mkalias # Needed for adding applications to Apple Spotlight
    mas
    # displaylink
  ];

  # Homebrew for applications not available/broken on nix-darwin
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "reinhard";
  };
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
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.defaults = {
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 2; # full keyboard access
      KeyRepeat = 2;
      "com.apple.swipescrolldirection" = false;
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
        "/System/Applications/System Settings.app"
      ];
    };
    finder = {
      FXPreferredViewStyle = "clmv";
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      _FXSortFoldersFirst = true;
    };
    trackpad = {
      Clicking = true; # tap to click
    };
    controlcenter = {
      Bluetooth = true;
      Sound = true;
    };
    WindowManager = {
      EnableTiledWindowMargins = true;
      StandardHideWidgets = true;
    };
    loginwindow.GuestEnabled = false;
    hitoolbox.AppleFnUsageType = "Do Nothing";
  };

  system.startup.chime = false;
  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCtrlAndFn = false;
  };

  system.activationScripts.postActivation.text = ''
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

  system.activationScripts.keyboard.text = ''
    # Install Custom Keyboard Layout
    echo "Installing Custom Keyboard Layout..."
    mkdir -p "/Library/Keyboard Layouts"
    cp -f "${./us_with_umlauts.keylayout}" "/Library/Keyboard Layouts/EurKEY.keylayout"
  '';

  system.defaults.CustomUserPreferences = {
    "com.apple.widgets" = {
      "widget-style" = 2;
    };
    "com.apple.WindowManager" = {
      "EnableStandardClickToShowDesktop" = 0;
    };
    "com.apple.controlstrip" = {
      MiniCustomized = [
        "com.apple.system.brightness"
        "com.apple.system.volume"
        "com.apple.system.mute"
        "com.apple.system.launchpad"
      ];
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
    "com.apple.assistant.support" = {
      "Assistant Enabled" = false; # disable Siri
    };
    "com.apple.finder" = {
      ShowRecentTags = true;
    };
    "com.apple.sidebarlists" = {
      networkbrowser = {
        CustomListProperties = {
          "com.apple.NetworkBrowser.bonjourEnabled" = false;
        };
      };
    };
    "com.apple.dock" = {
      showDesktopGestureEnabled = false;
    };
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadMomentumScroll = false;
    };
    "com.apple.TextInputMenu" = {
      visible = false; # hide text input menu bar icon
    };
    "com.apple.menuextra.clock" = {
      ShowDate = 0; # hide date in menu bar clock
    };
    NSGlobalDomain = {
      AppleMiniaturizeOnDoubleClick = false;
      "com.apple.mouse.linear" = true; # linear mouse acceleration
      "com.apple.scrollwheel.scaling" = "0.3125";
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
  };

  modules = {
    base-desktop.enable = true;
    zsh.enable = true;
    printer.enable = true;
    bitwarden = {
      enable = true;
      sshAgent.enable = true;
    };
    ferdium.enable = true;
    prusa.enable = true;
    neovim.enable = true;
    kicad.enable = true;
    git = {
      enable = true;
      userName = "g0r3";
      userEmail = "3685646+g0r3@users.noreply.github.com";
    };
  };

  # This script is needed to add all Application to the Spotlight Search
  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = [ "/Applications" ];
      };
    in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';
}
