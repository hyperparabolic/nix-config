{
  flake.modules.nixos.core = {...}: {
    programs.dconf.enable = true;
  };
}
