{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pam_u2f
  ];

  security.pam = {
    u2f = {
      enable = true;
      settings = {
        authfile = config.sops.secrets.u2f-mappings.path;
        cue = true;
        appid = "pam://u2f.decent.id";
        origin = "pam://u2f.decent.id";
      };
    };
    services = {
      # "rules" config below is experimental and may change. See:
      # https://github.com/NixOS/nixpkgs/pull/255547
      hyprlock.u2fAuth = true;
      login.u2fAuth = true;
      login.rules.auth.u2f = {
        control = lib.mkForce "required";
      };
      greetd.u2fAuth = true;
      greetd.rules.auth.u2f = {
        control = lib.mkForce "required";
      };
      sudo.u2fAuth = true;
      # prefer u2f over rssh for machines with direct usb access
      sudo.rules.auth.u2f.order = config.security.pam.services.sudo.rules.auth.rssh.order - 10;
    };
  };

  sops.secrets.u2f-mappings = {
    sopsFile = ../../../secrets/common/secrets-u2f-mappings.yaml;
    path = "/etc/u2f_mappings";
    mode = "0444";
  };
}
