{
  config,
  pkgs,
  lib,
  isNixos,
  isDarwin,
  ...
}:
let
  cfg = config.modules.displaylink;
in
{

  options.modules.displaylink.enable = lib.mkEnableOption "Whether to enable the Displaylink module";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs isDarwin {
        # --- macOS / Darwin Configuration ---
      })
      (lib.optionalAttrs isNixos {
        # --- Linux / Systemd Configuration ---
        environment.systemPackages = [ pkgs.displaylink ];

        systemd.services.displaylink = {
          description = "DisplayLink Manager Service";
          after = [ "display-manager.service" ];
          wantedBy = [ "graphical.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
            Restart = "always";
          };
        };

        boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
        boot.kernelModules = [ "evdi" ];

        nixpkgs.config.allowUnfree = true;
      })
      {
        # --- Common Configuration ---
      }
    ]
  );
}
