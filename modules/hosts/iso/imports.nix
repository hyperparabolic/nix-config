{config, ...}: {
  flake.modules.nixos.hosts-iso = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      ../../../hosts/iso/configuration.nix
    ];
  };
}
