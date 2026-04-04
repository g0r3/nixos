{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # rstaudacher.nixbuilder.enable = true;
  nix.settings.trusted-users = [
    "rstaudacher"
    "root"
  ];
  networking.hostName = "ENG-rstaudacher";
  system.stateVersion = "25.05";
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_IE.UTF-8";

  users.users = {
    rstaudacher = {
      isNormalUser = true;
      description = "Reinhard Staudacher";
      extraGroups = [
        "audio"
        "networkmanager"
        "wheel"
        "scanner"
        "rstaudacher"
        "lp"
        "mlocate"
      ];
      shell = pkgs.zsh;
    };
    root = {
      shell = pkgs.zsh;
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Required for modern Intel GPUs
      libvdpau-va-gl
    ];
  };

  modules = {
    base.enable = true;
    base-desktop.enable = true;
    boot.enable = true;
    kde.enable = true;
    zsh.enable = true;
    maintenance.enable = true;
    wireplumber.enable = true;
    vscode.enable = true;
    nixbuilder.enable = true;
    bitwarden.enable = true;
    bitwarden.sshAgent.enable = true;
    neovim.enable = true;
    displaylink.enable = true;
    dell-fingerprint.enable = true;
    docker.enable = true;
    barracudavpn.enable = true;
    secureedge.enable = true;
    git = {
      enable = true;
      userName = "rstaudacher";
      userEmail = "rstaudacher@barracuda.com";
    };
  };

  boot.blacklistedKernelModules = [
    # disable integrated webcam
    "intel_ipu6"
    "intel_ipu6_isys"
    "intel_ipu6_psys"
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # ZSH env vars (moved from dotfiles .zshenv/.zshrc)
  programs.zsh.shellInit = ''
    export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin:$HOME/dev/repos/mystuff/bin"
  '';

  environment.variables = {
    VAULT_ADDR = "https://qda-vault.qa.ngdev.eu.ad.cuda-inc.com:8200";
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    zoom-us
    slack
    freerdp
    realvnc-vnc-viewer
    pamixer
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf" ''
      [General]
      type=color
      color=#505050
    '')
    alsa-utils
    clang
    python314
  ];

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
  services.xserver.videoDrivers = [
    "modesetting"
  ];
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  security.polkit.enable = true;
  security.pki.certificateFiles = [
    ./certs/idefix.crt
    ./certs/INN-DEV.crt
    ./certs/qdaca.crt
    ./certs/ssl_inspection.crt
  ];

  fileSystems."/mnt/qarepo" = {
    device = "10.17.6.4:/home/qa";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.mount-timeout=10s"
      "timeo=15"
      "soft"
    ];
  };

  # SSH server
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
