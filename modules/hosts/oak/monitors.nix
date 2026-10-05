{
  flake.modules.nixos.hosts-oak = {pkgs, ...}: {
    boot = {
      kernelModules = [
        "amdgpu"
      ];
      kernelParams = [
        "video=DP-1:d"
        "video=DP-2:1920x1080,rotate=270"
      ];
    };

    systemd.services = {
      # Readable boot logs workaround:
      # This is jank as hell, but multiple monitors with different resolutions
      # in ttys is also jank as hell. DP-1 is 4k and extremely slow switching modes.
      # Logs aren't visible for almost the entire boot if switched to 1080p to get
      # a full monitor of logs. Instead, so just disable it until greetd.service
      # so DP-2 gets treated as primary and is legible while rotated. This needs
      # to be run as root, so unfortunately it can't be linked to user session
      # services.
      enable-dp-1 = {
        description = "Ensure monitor DP-1 is enabled";
        wantedBy = ["greetd.service"];
        before = ["greetd.service"];
        path = with pkgs; [
          coreutils-full
        ];
        serviceConfig.Type = "oneshot";
        script =
          /*
          bash
          */
          ''
            echo on > /sys/kernel/debug/dri/1/DP-1/force
            echo 1 > /sys/kernel/debug/dri/1/DP-1/trigger_hotplug
          '';
      };
    };

    this = {
      monitors = [
        {
          name = "DP-1";
          width = 3840;
          height = 2160;
          refreshRate = 120;
          x = 0;
          primary = true;
          workspaces = [
            "1"
            "2"
            "5"
            "6"
          ];
        }
        {
          name = "DP-2";
          width = 1920;
          height = 1080;
          x = 3840;
          # vertical orientation
          transform = 3;
          workspaces = [
            "3"
            "4"
            "7"
            "8"
          ];
        }
      ];
      tuigreet.settings = {
        outputs = [
          {
            connector = "DP-1";
            enabled = false;
          }
          {
            connector = "DP-2";
            primary = true;
          }
        ];
      };
    };
  };
}
