{
  flake.modules.nixos.core = {
    config,
    lib,
    ...
  }: {
    config = {
      environment.persistence = lib.mkIf (config.this.impermanence.enable == false) (lib.mkForce {});
    };
  };

  flake.modules.homeManager.core = {
    config,
    lib,
    ...
  }: {
    config = {
      home.persistence = lib.mkIf (config.this.impermanence.enable == false) (lib.mkForce {});
    };
  };
}
