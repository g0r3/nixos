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

  environment.etc."sane.d/airscan.conf".text = ''
    [devices]
    "Brother MFC-L3750CDW" = https://printer.staudacher.dev/eSCL

    [options]
    discovery = disable
  '';
}
