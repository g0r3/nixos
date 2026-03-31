# Software every desktop based system should have, no matter the desktop
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.base-desktop;
in
{
  options.modules.base-desktop.enable = lib.mkEnableOption "Whether to enable the base-desktop module";

  config = lib.mkIf cfg.enable {
    programs.nix-index.enable = true;

    environment.systemPackages = with pkgs; [
      mpv
      gimp
      geary
      brave
      spotify
      sublime3
      obsidian
      libreoffice-qt-still
      gnome-disk-utility
      system-config-printer
    ];
  };
}
