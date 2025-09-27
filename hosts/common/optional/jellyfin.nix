{pkgs, ...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    package = pkgs.stable.jellyfin;
  };

  environment.persistence."/persist".directories = [
    "/var/lib/jellyfin"
    "/var/cache/jellyfin"
  ];
}
