{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nixbuilder;
in
{
  options.modules.nixbuilder.enable = lib.mkEnableOption "Whether to enable the nixbuilder module";

  config = lib.mkIf cfg.enable {
    nix.settings.substituters = [
      "ssh-ng://nixbuilder@nixbld01.qa.ngdev.eu.ad.cuda-inc.com"
      "ssh-ng://nixbuilder@nixbld02.qa.ngdev.eu.ad.cuda-inc.com"
      "ssh-ng://nixbuilder@nixbld03.qa.ngdev.eu.ad.cuda-inc.com"
    ];
    nix.settings.trusted-substituters = [
      "ssh-ng://nixbuilder@nixbld01.qa.ngdev.eu.ad.cuda-inc.com"
      "ssh-ng://nixbuilder@nixbld02.qa.ngdev.eu.ad.cuda-inc.com"
      "ssh-ng://nixbuilder@nixbld03.qa.ngdev.eu.ad.cuda-inc.com"
    ];
  };
}
