{
  flake.modules.nixos.hosts-magnolia = {...}: {
    this.monitors = [
      {
        name = "eDP-1";
        width = 2256;
        height = 1504;
        primary = true;
        workspaces = [
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
        ];
      }
    ];
  };
}
