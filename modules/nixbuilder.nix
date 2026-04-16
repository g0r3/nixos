{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixbuilder;

  servers = [
    "nixbld01.qa.ngdev.eu.ad.cuda-inc.com"
    "nixbld02.qa.ngdev.eu.ad.cuda-inc.com"
    "nixbld03.qa.ngdev.eu.ad.cuda-inc.com"
  ];

  mkSubstituter = host: "ssh-ng://nixbuilder@${host}";
in
{
  options.modules.nixbuilder.enable = lib.mkEnableOption "Whether to enable the nixbuilder module";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = map mkSubstituter servers;
      trusted-substituters = map mkSubstituter servers;
      connect-timeout = 5;
    };

    programs.ssh.extraConfig = ''
      Host ${lib.concatStringsSep " " servers}
        IdentityFile /home/rstaudacher/.ssh/nixbuilder
        User nixbuilder
    '';
  };
}
