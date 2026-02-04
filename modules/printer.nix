{ pkgs, ... }:

let
  mfcl3750cdw = pkgs.callPackage ../packages/mfcl3750cdw/package.nix { };
in
{
  services.printing = {
    enable = true;
    drivers = [ mfcl3750cdw.cupswrapper ];
  };
  hardware = {
    printers = {
      ensureDefaultPrinter = "Brother_MFC_L3750CDW";
      ensurePrinters = [
        {
          name = "Brother_MFC_L3750CDW";
          model = "brother_mfcl3750cdw_printer_en.ppd";
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