{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.arduino;
in
{
  options.modules.arduino.enable = lib.mkEnableOption "Whether to enable the Arduino module";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      arduino
    ];
  };
}
