{
  pkgs,
  config,
  ...
}: {
  # Just u2f auth here for now.
  # No management tools included here. I do all of that airgapped.
  environment.systemPackages = with pkgs; [
    pam_u2f
  ];

  security.pam = {
    u2f = {
      enable = true;
      # required in addition to password
      control = "required";
      settings = {
        cue = true;
        authfile = config.sops.secrets.u2f-mappings.path;
        # physical touch required
        userpresence = 1;
      };
    };
    services = {
      # TODO: "required" for login, but "sufficient" elsewhere
      # TODO: swaylock failing on mfa. Needs another lock solution.
      # - loginctl enable-linger and just lock to greetd? I think this
      # would behave better with UWSM
      # - some other lock screen?
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
  };

  sops.secrets.u2f-mappings = {
    sopsFile = ../secrets.yaml;
    path = "/etc/u2f_mappings";
  };
}
