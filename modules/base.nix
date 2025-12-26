# base shell programs packages every system should have
{ pkgs, ... }:
{
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    jq
    mlocate
    ethtool
    screen
    hdparm
    dig
    dmidecode
    git
    unzip
    zsh
    nurl # generates Nix fetcher calls
    pciutils
    nmap
    usbutils
    tree
  ];
}
