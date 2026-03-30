{
  pkgs,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    ../../modules
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

  # ZSH env vars (moved from dotfiles .zshenv)
  programs.zsh.shellInit = ''
    export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"
  '';

  environment.systemPackages = with pkgs; [
    android-tools
    pavucontrol
    pamixer
    alsa-utils
    stow
    clang
    gemini-cli-bin
    claude-code
    nurl # generates Nix fetcher calls
    ipcalc
  ];

  modules = {
    base.enable = true;
    base-desktop.enable = true;
    boot.enable = true;
    kde.enable = true;
    zsh.enable = true;
    steam.enable = true;
    shares.enable = true;
    printer.enable = true;
    maintenance.enable = true;
    arduino.enable = true;
    wireplumber.enable = true;
    bitwarden.enable = true;
    bitwarden.sshAgentSocket = "$HOME/.bitwarden-ssh-agent.sock";
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

  zramSwap.enable = true;

  # Rename built-in speakers for Plasma PA
  services.pipewire.wireplumber.extraConfig."00-plasma-pa" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "alsa_output.pci-0000_1a_00.6.analog-stereo";
            "port.monitor" = "!true";
          }
        ];
        actions.update-props = {
          "alsa.card_name" = "Speakers";
          "alsa.long_card_name" = "Speakers";
          "device.description" = "Speakers";
          "device.name" = "Speakers";
          "node.description" = "Speakers";
          "node.nick" = "Speakers";
        };
      }
    ];
  };

  # security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
