{
  config,
  lib,
  pkgs,
  isLinux,
  isDarwin,
  ...
}:

let
  cfg = config.modules.bitwarden;
in
{
  options.modules.bitwarden = {
    enable = lib.mkEnableOption "Whether to enable the Bitwarden module";
    sshAgentSocket = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "$HOME/.bitwarden-ssh-agent.sock";
      description = "Path to the Bitwarden SSH agent socket. Sets SSH_AUTH_SOCK when non-null.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs isDarwin {
        system.activationScripts.postActivation.text = ''
          appPath="${pkgs.bitwarden-desktop}/Applications/Bitwarden.app"
          osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$appPath\", hidden:false}"
          printf "Bitwarden added to login items.\n"
        '';
      })
      (lib.optionalAttrs isLinux {
        systemd.user.services.bitwarden = {
          description = "Start Bitwarden after graphical login";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Environment = [
              "PATH=/run/current-system/sw/bin"
            ];
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
            ExecStart = "${pkgs.bitwarden-desktop}/bin/bitwarden";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })
      {
        environment.systemPackages = [ pkgs.bitwarden-desktop ];
      }
      (lib.mkIf (cfg.sshAgentSocket != null) {
        programs.zsh.shellInit = ''
          export SSH_AUTH_SOCK="${cfg.sshAgentSocket}"
        '';
      })
    ]
  );
}
