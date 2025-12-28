{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:

let
  cfg = config.modules.prusa;
in
{
  options = {
    modules = {
      prusa = {
        enable = lib.mkEnableOption "Whether to enable the Prusa module";
      };
    };
  };

  config = lib.mkMerge [
    (lib.optionalAttrs isNixos {
      # Nix-specific
      environment.systemPackages = with pkgs; [
        prusa-slicer
        freecad
      ];
    })

    (lib.optionalAttrs (isDarwin) {
      # Darwin-specific; Both freecad and prusa-slicer are marked as broken packages in nix-darwin
      homebrew = {
        enable = true;
        casks = [
          "prusaslicer"
          "freecad"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };
    })
  ];
}
