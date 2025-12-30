{
  pkgs,
  inputs,
  config,
  ...
}:
{

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../modules/bitwarden.nix
    # ../../modules/steam.nix
    # ../../modules/shares.nix
    ../../modules/zsh.nix
    # ../../modules/printer.nix
    # ../../modules/maintenance.nix
    ../../modules/ferdium.nix
    # ../../modules/arduino.nix # currently broken on nix-darwin
    ../../modules/kicad.nix
    ../../modules/neovim.nix
    ../../modules/prusa.nix
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
    brave
    spotify
    mas
    stow
    # displaylink
  ];

  # Homebrew for appliactions not available/broken on nix-darwin
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
    pkgs.nerd-fonts.jetbrains-mono
  ];

  system.defaults = {
    dock.autohide = true;
    dock.persistent-apps = [
      # Apps pinned in dock
      "${pkgs.wezterm}/Applications/Wezterm.app"
      "${pkgs.brave}/Applications/Brave Browser.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Contacts.app"
      "/System/Applications/App Store.app"
      "${pkgs.spotify}/Applications/Spotify.app"
      "/System/Applications/System Settings.app"
    ];
    dock.minimize-to-application = true;

    finder.FXPreferredViewStyle = "clmv";

    loginwindow.GuestEnabled = false;
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    controlcenter.Bluetooth = true;
    controlcenter.Sound = true;
    WindowManager.EnableTiledWindowMargins = true;
    WindowManager.StandardHideWidgets = true;
    finder.NewWindowTarget = "Home";
    finder.ShowExternalHardDrivesOnDesktop = true;
    finder.ShowHardDrivesOnDesktop = true;
    finder.ShowMountedServersOnDesktop = true;
    finder._FXSortFoldersFirst = true;
  };
  system.startup.chime = false;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.swapLeftCtrlAndFn = true;
  system.defaults.hitoolbox.AppleFnUsageType = "Do Nothing";

  system.activationScripts.postActivation.text = ''
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
    bitwarden.enable = true;
    ferdium.enable = true;
    prusa.enable = true;
    neovim.enable = true;
    kicad.enable = true;
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
