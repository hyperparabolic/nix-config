{
  flake.modules.nixos.audio = {pkgs, ...}: {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.extraConfig = {
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

    environment.systemPackages = with pkgs; [
      qpwgraph
    ];
  };
}
