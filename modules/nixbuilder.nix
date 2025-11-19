{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.rstaudacher.nixbuilder;
in
{
  options.rstaudacher.nixbuilder = {
    enable = lib.mkEnableOption "Enable nixbuilder configuration";

    user = lib.mkOption {
      type = lib.types.str;
      default = "rstaudacher";
      description = "The user to own the nixbuilder files.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "rstaudacher";
      description = "The group to own the nixbuilder files.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc =
      let
        machinesFile = pkgs.fetchurl {
          url = "ftp://qa:qa@10.17.6.4/nix/machines";
          sha256 = "1gdsknmd89f20khdjafkxivjwg9ld70wv3kc8js4vabsg4jrwy22";
        };
        nixbuilderFile = pkgs.fetchurl {
          url = "ftp://qa:qa@10.17.6.4/nix/nixbuilder";
          sha256 = "1paql5w00alairg18icym129h60wwfa6lcnr9k3m8lp7zcd2ayb0";
        };
      in
      {
        "nix/machines" = {
          source = machinesFile;
          inherit (cfg) user group;
          mode = "0400";
        };

        "nix/nixbuilder" = {
          source = nixbuilderFile;
          inherit (cfg) user group;
          mode = "0400";
        };
      };

    nix = {
      settings = {
        substituters = [
          "https://cache.nixos.org"
          "http://nixbld01.qa.ngdev.eu.ad.cuda-inc.com"
          "http://nixbld02.qa.ngdev.eu.ad.cuda-inc.com"
          "http://nixbld03.qa.ngdev.eu.ad.cuda-inc.com"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixbld.qa.ngdev.eu.ad.cuda-inc.com:gSZJQ+2fKb4FCoUM6KBFWecAe7hgfEzrPu0TLo2s8q0="
        ];
        "require-sigs" = true;
        "trusted-users" = [ "root" ];
        "allowed-users" = [ "*" ];
        "builders-use-substitutes" = true;
      };
    };
  };
}
