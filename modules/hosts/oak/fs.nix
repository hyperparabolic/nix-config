{
  flake.modules.nixos.hosts-oak = {...}: {
    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
    };
  };
}
