{
  flake.modules.nixos.hosts-oak = {...}: {
    this.monitors = [
      {
        name = "HDMI-A-1";
        width = 3840;
        height = 2160;
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
        name = "DVI-D-1";
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
  };

  flake.modules.homeManager.hosts-oak = {lib, ...}: {
  };
}
