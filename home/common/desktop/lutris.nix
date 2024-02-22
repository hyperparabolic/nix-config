{pkgs, ...}: {
  home.packages = with pkgs; [
    (lutris.override {
      extraPkgs = p: [
        p.wineWowPackages.wayland
      ];
    })
  ];

  home.persistence = {
    "/persist/home/spencer" = {
      allowOther = true;
      directories = [
        ".config/lutris"
        ".local/share/lutris"
      ];
    };
  };
}
