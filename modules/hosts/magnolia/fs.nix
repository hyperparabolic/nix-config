{
  flake.modules.nixos.hosts-magnolia = {...}: {
    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
    };
  };
}
