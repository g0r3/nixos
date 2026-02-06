# base shell programs packages every NixOS system should have
{
  pkgs,
  lib,
  isNixos,
  ...
}:
{
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
      nurl
      nmap
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
}

