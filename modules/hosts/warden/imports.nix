{config, ...}: {
  flake.modules.nixos.hosts-warden = {...}: {
    imports = with config.flake.modules.nixos; [
      core
      ../../../hosts/warden/configuration.nix
    ];
  };
}
