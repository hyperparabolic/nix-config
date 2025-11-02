{
  flake.modules.nixos.hosts-redbud = {...}: {
    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
    };
  };
}
