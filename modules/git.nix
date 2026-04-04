{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user email";
    };
  };

  config = {
    environment.etc."gitconfig".text = ''
      [user]
        name = ${cfg.userName}
        email = ${cfg.userEmail}
    '';
  };
}
