# Software every desktop based system should have, no matter the desktop
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv
    gimp
    geary
    brave
    spotify
    sublime3
    obsidian
    # libreoffice-qt-still
    gnome-disk-utility
    system-config-printer
  ];
}
