{
  flake.modules.nixos.core = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.this.secureboot = {
      enable = lib.options.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable boot image signing.";
      };
    };

    config = let
      cfg = config.this.secureboot;
    in {
      environment.systemPackages = [
        pkgs.sbctl
      ];

      # replaces systemd-boot
      boot.loader.systemd-boot.enable = lib.mkForce (! cfg.enable);

      boot.lanzaboote = {
        enable = cfg.enable;
        pkiBundle = "/var/lib/sbctl";
      };

      environment.persistence."/persist".directories = ["/var/lib/sbctl"];
    };
  };
}
