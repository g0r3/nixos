{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        mfcl3750cdw_org = final.callPackage ../packages/mfcl3750cdw/package.nix { };
      in
      {
        mfcl3750cdw = mfcl3750cdw_org // {
          cupswrapper = mfcl3750cdw_org.cupswrapper.overrideAttrs (oldAttrs: {
            # This appends your patch command to the build process
            postPatch = (oldAttrs.postPatch or "") + ''
              echo "Applying modules patch to brmfcl3750cdwrc..."
              substituteInPlace 'opt/brother/Printers/mfcl3750cdw/inf/brmfcl3750cdwrc' \
                --replace "PaperType=Letter" "PaperType=A4"
            '';
          });
        };
      }
    )
  ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.mfcl3750cdw.cupswrapper ];
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
