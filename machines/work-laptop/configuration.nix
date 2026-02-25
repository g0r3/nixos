{
  config,
  pkgs,
  lib,
  self',
  inputs,
  ...
}:
let
  barracudavpn = pkgs.callPackage ../../packages/barracudavpn/default.nix { };
  libfprint-2-tod1-broadcom-cv3plus =
    pkgs.callPackage ../../packages/libfprint-2-tod1-broadcom-cv3plus/package.nix
      { };
in
{

  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/base.nix
    ../../modules/base-desktop.nix
    ../../modules/kde.nix
    ../../modules/bitwarden.nix
    ../../modules/zsh.nix
    ../../modules/maintenance.nix
    ../../modules/neovim.nix
    ../../modules/vscode.nix
    ../../modules/nixbuilder.nix
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
    bitwarden.enable = true;
    neovim.enable = true;
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

  # fingerprint reader
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod.enable = true;
    # Search for "libfprint" in packages to find other drivers
    tod.driver = libfprint-2-tod1-broadcom-cv3plus;
  };
  security.pam.services.sddm.fprintAuth = true;

  systemd.services.fprintd.serviceConfig = {
    BindReadOnlyPaths = [
      "${libfprint-2-tod1-broadcom-cv3plus}${libfprint-2-tod1-broadcom-cv3plus.passthru.firmwarePath}:/var/lib/fprint/.broadcomCv3plusFW"
    ];
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    zoom-us
    teams-for-linux
    displaylink
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
    neofetch
    stow
    clang
    gemini-cli-bin
    barracudavpn
    nurl # generates Nix fetcher calls
    python314
    ipcalc
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
    "displaylink"
    "modesetting"
  ];
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  security.polkit.enable = true;
  security.pki.certificateFiles = [
    ./folsom.crt
    ./idefix.crt
    ./INN-DEV.crt
    ./ip-vix.crt
    ./qdaca.crt
    ./ssl_inspection.pem
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
