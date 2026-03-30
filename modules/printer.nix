{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:
let
  cfg = config.modules.printer;

  printerName = "Brother_MFC_L3750CDW";
  printerDescription = "Brother MFC-L3750CDW";
  printerLocation = "Living Room";
  printerUri = "ipp://printer.staudacher.dev/ipp/print";
  scannerUri = "https://printer.staudacher.dev/eSCL";
  pageSize = "A4";

  # Patch CUPS to handle Brother's nameWithLanguage/textWithLanguage IPP encoding
  # and emit cupsIPPSupplies in generated PPDs for IPP Everywhere printers.
  cups-patched = pkgs.cups.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../patches/cups-brother-marker-supply-levels.patch
    ];
  });
in
{
  options.modules.printer.enable = lib.mkEnableOption "Whether to enable the printer module";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.optionalAttrs isNixos {
      services.printing = {
        enable = true;
        package = cups-patched;
      };
      hardware = {
        printers = {
          ensureDefaultPrinter = printerName;
          ensurePrinters = [
            {
              name = printerName;
              model = "everywhere";
              location = printerLocation;
              description = printerDescription;
              deviceUri = printerUri;
              ppdOptions.PageSize = pageSize;
            }
          ];
        };
        sane = {
          enable = true;
          extraBackends = [ pkgs.sane-airscan ];
        };
      };

      # ensure-printers.service fails if the printer is not reachable (e.g. network not yet up)
      # This override makes sure it waits for the network and retries on failure
      systemd.services.ensure-printers = {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };

      environment.etc."sane.d/airscan.conf".text = ''
        [devices]
        "${printerDescription}" = ${scannerUri}

        [options]
        discovery = disable
      '';
    })
    (lib.optionalAttrs isDarwin {
      system.activationScripts.printer.text = ''
        if ! /usr/bin/lpstat -p ${printerName} 2>/dev/null; then
          echo "Adding ${printerDescription} printer..." >&2
          /usr/sbin/lpadmin -p ${printerName} \
            -v "${printerUri}" \
            -m everywhere \
            -L "${printerLocation}" \
            -D "${printerDescription}" \
            -o PageSize=${pageSize} \
            -E
          /usr/sbin/lpadmin -d ${printerName}
        fi
      '';
    })
  ]);
}
