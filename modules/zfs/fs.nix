{
  flake.modules.nixos.zfs = {...}: {
    fileSystems."/" = {
      device = "rpool/crypt/local/root";
      fsType = "zfs";
    };

    fileSystems."/nix" = {
      device = "rpool/crypt/local/nix";
      fsType = "zfs";
    };

    fileSystems."/persist" = {
      device = "rpool/crypt/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
}
