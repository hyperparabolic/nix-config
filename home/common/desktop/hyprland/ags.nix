{ inputs, pkgs, ... }: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = {
    enable = true;
    configDir = ./config/ags;
    package = inputs.ags.packages.x86_64-linux.agsWithTypes;
  };

  systemd.user.services = {
    ags = {
      Unit = {
        Description = "ags desktop widgets";
        PartOf = "graphical-session.target";
      };
      Service = {
        Environment = "PATH=/run/current-system/sw/bin/";
        ExecStart = "${inputs.ags.packages.x86_64-linux.agsWithTypes}/bin/ags -b hypr";
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };
  };
}
