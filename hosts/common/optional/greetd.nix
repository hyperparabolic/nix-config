{
  config,
  lib,
  pkgs,
  ...
}: let
in {
  users.extraUsers.greeter = {
    home = "/tmp/greeter-home";
    createHome = true;
  };

  programs.regreet = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        # hiding startup logs
        command = "Hyprland &> /dev/null";
        user = "spencer";
      };
    };
  };

  # unlock gpg keyring on login
  security.pam.services.greetd.enableGnomeKeyring = true;
}
