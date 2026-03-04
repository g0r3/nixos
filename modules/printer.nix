{ pkgs, ... }:

{
  services.printing = {
    enable = true;
  };
  hardware = {
    printers = {
      ensureDefaultPrinter = "Brother_MFC_L3750CDW";
      ensurePrinters = [
        {
          name = "Brother_MFC_L3750CDW";
          model = "everywhere";
          location = "Living Room";
          description = "Brother MFC-L3750CDW";
          deviceUri = "ipp://printer.staudacher.dev/ipp/print";
          ppdOptions.PageSize = "A4";
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
    "Brother MFC-L3750CDW" = https://printer.staudacher.dev/eSCL

    [options]
    discovery = disable
  '';
}
