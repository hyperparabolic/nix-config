{
  flake.modules.nixos.pipewire-raop = {pkgs, ...}: {
    # raop (airplay) discovery support for pipewire
    services = {
      avahi.enable = true;
      pipewire = {
        package = pkgs.pipewire.override {
          raopSupport = true;
        };
        raopOpenFirewall = true;
        extraConfig.pipewire = {
          "99-raop-discovery" = {
            "context.modules" = [
              {
                name = "libpipewire-module-zeroconf-discover";
                args = {};
              }
              {
                name = "libpipewire-module-raop-discover";
                args = {};
              }
            ];
          };
        };
      };
    };
  };
}
