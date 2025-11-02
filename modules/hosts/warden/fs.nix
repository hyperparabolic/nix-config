{
  flake.modules.nixos.hosts-warden = {...}: {
    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
    };
  };
}
