{config, ...}: {
  flake.modules.nixos.hosts-redbud = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      ../../../hosts/redbud/configuration.nix
    ];
  };
}
