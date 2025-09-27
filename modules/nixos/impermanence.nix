{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hyperparabolic.impermanence;
in {
  /*
  Impermanence config. This is a little funky / exceptional.

  This is extremely prescriptive about structure. All persist filesystems are expected
  to be mounted at "/persist", and systems that use impermanence expect home-manager to
  be included. All current usage in home-manager is also nested in the same directory
  at "/perist/home/spencer" and relies on the nixos level for rollbacks and is specific
  to the "spencer" user.

  Nixos without home-manager would likely only be static deployments, and home-manager
  without nixos would likely be darwin based work laptops. I don't think either of these
  use cases would include impermanence.

  Accepting all of this as givens for now, and co-mingling nixos and home-manager
  here.
  */

  options.hyperparabolic.impermanence = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = mdDoc ''
        Enables impermanence.

        This enables impermanence for "/persist" in the nixos module, and
        "/persist/home/spencer" in the home-manager module of impermanence.

        Conditional imports aren't really possible unless the impermanence config
        is completely isolated, and strongly prefer it to be co-mingled with the
        relevant programs / services.

        This mostly just exists to be more prescriptive about structure so that
        the default can be made false, and this can be appled to both nixos and
        home-manager.
      '';
    };
    enableRollback = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = mdDoc ''
        Perform impermance rollback on boot. Useful to disable for debugging.

        Only intended to be consumed by a <fs>.nix module. A zfs or btrfs module
        is expected to implement snapshot rollbacks based on this option. This
        will do nothing if not using a local fs module that supports snapshots.
      '';
    };
  };

  config = {
    environment.persistence."/persist".enable = cfg.enable;
    home-manager.users.spencer.home.persistence."/persist".enable = cfg.enable;
  };
}
