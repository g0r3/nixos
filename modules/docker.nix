{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:

let
  cfg = config.modules.docker;
in
{
  options.modules.docker.enable = lib.mkEnableOption "Whether to enable the Docker module";

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
        virtualisation.docker.enable = true;
        users.users.rstaudacher.extraGroups = [ "docker" ];
      })
      {
        # Common packages
      }
    ]
  );
}
