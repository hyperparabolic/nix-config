{
  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    openFirewall = true;
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/private/AdGuardHome/"
    ];
  };
}
