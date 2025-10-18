{config, ...}: {
  flake.modules.nixos.hosts-magnolia = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      laptop
      ../../../hosts/magnolia/configuration.nix
    ];
  };
}
