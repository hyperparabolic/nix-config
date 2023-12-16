{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/jellyfin"
      "/var/cache/jellyfin"
    ];
  };
}
