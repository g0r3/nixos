{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:

let
  cfg = config.modules.ferdium;
in
{
  options.modules.ferdium.enable = lib.mkEnableOption "Whether to enable the Ferdium module";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # --- macOS / Darwin Configuration ---
      (lib.optionalAttrs isDarwin {
        homebrew = {
          enable = true;
          casks = [
            "ferdium"
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };
        system.activationScripts.postActivation.text = ''
          osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/Ferdium.app\", hidden:false}"
          printf "Ferdium added to login items.\n"
        '';
      })
      # --- Linux / Systemd Configuration ---
      (lib.optionalAttrs isNixos {
        environment.systemPackages = [ pkgs.ferdium ];
        systemd.user.services.ferdium = {
          description = "Start Ferdium after graphical login";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Environment = [
              "PATH=/run/current-system/sw/bin"
            ];
            ExecStart = "${pkgs.ferdium}/bin/ferdium";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })
    ]
  );
}
