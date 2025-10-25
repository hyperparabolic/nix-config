{
  security.acme = {
    defaults.email = "hi@decent.id";
    acceptTerms = true;
  };

  environment.persistence."/persist".directories = ["/var/lib/acme"];
}
