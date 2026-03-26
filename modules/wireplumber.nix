{ ... }:
{
  services.pipewire.wireplumber.extraConfig = {
    "51-disable-suspension" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "~alsa_input.*"; }
            { "node.name" = "~alsa_output.*"; }
          ];
          actions.update-props."session.suspend-timeout-seconds" = 0;
        }
      ];
      "monitor.bluez.rules" = [
        {
          matches = [
            { "node.name" = "~bluez_input.*"; }
            { "node.name" = "~bluez_output.*"; }
          ];
          actions.update-props."session.suspend-timeout-seconds" = 0;
        }
      ];
    };
    "52-sony-wh1000-xm5" = {
      "monitor.bluez.properties" = {
        "bluez5.dummy-avrcp-player" = true;
      };
    };
    "52-bluetooth-defaults" = {
      "monitor.bluez.properties" = {
        "bluez5.auto-connect" = [ "a2dp_sink" "hfp_hf" ];
        "bluez5.hw-offload-sco" = false;
      };
    };
    "53-disable-ldac" = {
      # LDAC decoder (libldac-dec) fails on PipeWire 1.6.2, breaking the
      # entire LDAC codec including the encoder. Disable until nixpkgs fixes it.
      "monitor.bluez.properties" = {
        "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "aptx" "aptx_hd" "aptx_ll" "aptx_ll_duplex" "msbc" "cvsd" ];
      };
    };
  };
}
