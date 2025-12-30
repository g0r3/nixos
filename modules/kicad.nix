{
  config,
  pkgs,
  lib,
  inputs,
  isNixos,
  isDarwin,
  ...
}:

with lib;

let
  cfg = config.modules.kicad;

  KicadModTree = pkgs.python312Packages.buildPythonPackage rec {
    pname = "KicadModTree";
    version = "1.1.2";
    format = "setuptools";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-XdnY9FteJkaw1UEhEbXtEjCPubitSzJkCjq2VF+w7KI=";
    };
    doCheck = false;
  };

  jlc2kicadlib = pkgs.python312Packages.buildPythonApplication rec {
    pname = "jlc2kicad_lib";
    version = "1.0.36";
    format = "setuptools";

    src = pkgs.fetchFromGitHub {
      owner = "TousstNicolas";
      repo = "JLC2KiCad_lib";
      rev = "bb86aece9c8caeb26add8c7f957b948920fede17";
      hash = "sha256-mhZPBG08HDrfs6umXCUUFTW6cpVzz3bo620DCXlURbc=";
    };

    propagatedBuildInputs = with pkgs.python312Packages; [
      beautifulsoup4
      lxml
      requests
      natsort
      KicadModTree
      pyyaml
      tqdm
    ];

    meta = with lib; {
      description = "JLC2KiCad_lib is a python script that generate a KiCad library footprint and symbol from JLCPCB/LCSC components library";
      homepage = "https://github.com/TousstNicolas/JLC2KiCad_lib";
      license = licenses.mit;
      maintainers = [ ];
    };
  };

in
{
  options.modules.kicad.enable = mkEnableOption "Enable KiCad and related tools";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # --- macOS / Darwin Configuration ---
      (lib.optionalAttrs isDarwin {
        homebrew = {
          enable = true;
          casks = [
            "kicad" # broken on nix-darwin
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };
      })

      # --- Linux / Systemd Configuration ---
      (lib.optionalAttrs isNixos {
        environment.systemPackages = with pkgs; [
          kicad
        ];
      })

      # --- Common Configuration ---
      {
        environment.systemPackages = [ jlc2kicadlib ];
      }
    ]
  );

}
