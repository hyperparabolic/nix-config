{
  config,
  lib,
  pkgs,
  ...
}: {
  # This is mostly being used as remote management for pipewire.
  # Pipewire is intended to be a user service first and foremost.
  # Rather than trying to fight pw to fit into a system level
  # service, just run mpd as a "normal" user.
  services = {
    mpd = {
      enable = true;
      user = "spencer";
      network = {
        # mpd module does not open firewall ports. Listen on any interface,
        # but only open vpn interface ports below
        listenAddress = "any";
        port = 6600;
      };
      extraConfig = ''
        default_permissions "read,add,control"
        restore_paused "yes"
        input {
          plugin "curl"
        }
        input {
          plugin "alsa"
          default_device "hw:1,0"
        }
        audio_output {
          type "pipewire"
          name "pipewire output"
        }
      '';
    };
    # caged mpd client kiosk on tty1 for local control
    cage = {
      enable = true;
      user = "spencer";
      extraArguments = [
        # no decorations
        "-d"
        # allow tty switching
        "-s"
      ];
      program = "${lib.getExe pkgs.ymuse}";
    };
  };

  # ensure easy remote maintenance even if jailed login fails
  users.users.spencer = {
    # mpd starts without logged in user
    linger = true;
    # enable access to alsa devices via ssh without local login
    extraGroups = ["audio"];
  };

  systemd.services.mpd.environment = {
    # share environment for pipewire socket
    XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.spencer.uid}";
  };

  # remote access only permitted via vpn
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [config.services.mpd.network.port];
  };

  services.pipewire = {
    wireplumber.extraConfig = {
      # disable audio devices,
      "50-disable-audio-device" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                # disable internal audio devices to prevent feedback potential
                "device.name" = "alsa_card.pci-0000_00_1f.3";
              }
              {
                # raop video output, behaves poorly
                "node.name" = "raop_sink.Ego*";
              }
            ];
            actions = {
              update-props = {
                "device.disabled" = true;
              };
            };
          }
        ];
      };
      "60-out-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "raop_sink.Sonos-542A1B89DEA5*";
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
    };
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/mpd"
    ];
  };
}
