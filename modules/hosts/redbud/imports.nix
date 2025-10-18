{config, ...}: {
  flake.modules.nixos.hosts-redbud = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      laptop
      ../../../hosts/redbud/configuration.nix
    ];
  };
}
