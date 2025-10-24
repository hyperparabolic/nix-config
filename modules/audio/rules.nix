{
  flake.modules.nixos.audio = {...}: {
    services.pipewire.wireplumber.extraConfig = {
      # prioritize dac if present
      "60-dac-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.HiFi__Mic1__source";
              }
              {
                "node.name" = "alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.HiFi__Line1__sink";
              }
            ];
            actions = {
              update-props = {
                # normal input priority is sequential starting at 2000
                "priority.driver" = "3000";
                "priority.session" = "3000";
              };
            };
          }
        ];
      };
      # De-prioritize devices. Not disabled, but these should never be chosen by default.
      "99-low-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "alsa_output.usb-Sony_Interactive_Entertainment_Wireless_Controller-00.analog-stereo";
              }
              {
                "node.name" = "alsa_input.usb-Sony_Interactive_Entertainment_Wireless_Controller-00.mono-fallback";
              }
            ];
            actions = {
              update-props = {
                "priority.driver" = "1";
                "priority.session" = "1";
              };
            };
          }
        ];
      };
    };
  };
}
