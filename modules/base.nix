# base shell programs packages every NixOS system should have
{
  config,
  pkgs,
  lib,
  isNixos,
  isDarwin,
  ...
}:
let
  cfg = config.modules.base;
in
{
  options.modules.base.enable = lib.mkEnableOption "Whether to enable the base module";

  config = lib.mkIf cfg.enable {
    services.fwupd.enable = lib.mkIf isNixos true;

    environment.systemPackages =
      with pkgs;
      [
        # Cross-platform packages
        wget
        jq
        gnumake
        screen
        dig
        git
        git-lfs
        unzip
        zsh
        openssl
        nurl
        nmap
        file
        tree
        python314
      ]
      ++ lib.optionals isNixos [
        # Linux-only tools
        mlocate
        ethtool
        hdparm
        dmidecode
        pciutils
        usbutils
      ];
  };
}
