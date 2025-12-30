{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:

let
  cfg = config.modules.bitwarden;
in
{
  options.modules.bitwarden.enable = lib.mkEnableOption "Whether to enable the Bitwarden module";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs isDarwin {
        system.activationScripts.postActivation.text = ''
          appPath="${pkgs.bitwarden-desktop}/Applications/Bitwarden.app"
          osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$appPath\", hidden:false}"
          printf "Bitwarden added to login items.\n"
        '';
      })
      (lib.optionalAttrs isNixos {
        systemd.user.services.bitwarden = {
          description = "Start Bitwarden after graphical login";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Environment = [
              "GTK_USE_PORTAL=0"
              "PATH=/run/current-system/sw/bin"
            ];
            ExecStart = "${pkgs.bitwarden-desktop}/bin/bitwarden";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })
      {
        environment.systemPackages = [ pkgs.bitwarden-desktop ];
      }
    ]
  );
}
