{
  flake.modules.nixos.desktop = {...}: {
    services.geoclue2 = {
      enable = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
    };
  };
}
