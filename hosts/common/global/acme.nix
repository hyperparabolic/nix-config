{
  security.acme = {
    defaults.email = "spbalogh@gmail.com";
    acceptTerms = true;
  };

  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/acme"
      ];
    };
  };
}
