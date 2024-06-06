{
  services.fprintd.enable = true;

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/fprint"
    ];
  };
}
