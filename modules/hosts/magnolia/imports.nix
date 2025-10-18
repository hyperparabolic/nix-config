{config, ...}: {
  flake.modules.nixos.hosts-magnolia = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      ../../../hosts/magnolia/configuration.nix
    ];
  };
}
