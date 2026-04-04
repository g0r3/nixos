{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = mkEnableOption "Enable Git configuration";
    userName = mkOption {
      type = types.str;
      description = "Git user name";
    };
    userEmail = mkOption {
      type = types.str;
      description = "Git user email";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."gitconfig".text = ''
      [user]
        name = ${cfg.userName}
        email = ${cfg.userEmail}
      [pull]
        rebase = false
    '';
  };
}
