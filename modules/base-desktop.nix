# Software every desktop based system should have, no matter the desktop
{
  config,
  lib,
  pkgs,
  isLinux,
  ...
}:
let
  cfg = config.modules.base-desktop;
in
{
  options.modules.base-desktop.enable = lib.mkEnableOption "Whether to enable the base-desktop module";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs isLinux {
        environment.systemPackages = with pkgs; [
          mpv
          gimp
          geary
          # thunderbird
          sublime3
          libreoffice-qt-still
          gnome-disk-utility
          system-config-printer
        ];
      })
      {
        environment.systemPackages = with pkgs; [
          brave
          spotify
          stow
          nurl # generates Nix fetcher calls
          gemini-cli-bin
          claude-code
          obsidian
          ipcalc
        ];
      }
    ]
  );
}
