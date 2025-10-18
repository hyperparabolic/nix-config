{config, ...}: {
  flake.modules.nixos.hosts-oak = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      ../../../hosts/oak/configuration.nix
    ];
  };
}
