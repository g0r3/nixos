{
  config,
  lib,
  pkgs,
  isLinux,
  isDarwin,
  ...
}:
let
  cfg = config.modules.steam;
in
{
  options.modules.steam.enable = lib.mkEnableOption "Whether to enable the Steam module";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs isLinux {
        programs = {
          gamemode.enable = true;
          gamescope = {
            enable = true;
            capSysNice = true;
          };
          steam = {
            enable = true;
            gamescopeSession.enable = true;
          };
        };

        services.displayManager.gdm.wayland = true;
        systemd.user.services.steam = {
          description = "Start Steam after graphical login";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Environment = [
              "PATH=/run/current-system/sw/bin"
            ];
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
            ExecStart = "${pkgs.steam}/bin/steam -nochatui -nofriendsui -silent %U";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })
      (lib.optionalAttrs isDarwin {
        homebrew = {
          enable = true;
          casks = [
            "steam" # not yet supported on nix-darwin as of now
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };
      })
    ]
  );
}
