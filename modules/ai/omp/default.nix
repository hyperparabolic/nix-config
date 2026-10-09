{
  flake.modules.homeManager.omp = {
    config,
    pkgs,
    ...
  }: let
    ompDir = "/home/spencer/.nix-config/modules/ai/omp";
    mkNixConfigSymlink = fileName: config.lib.file.mkOutOfStoreSymlink "${ompDir}/${fileName}";
  in {
    home.packages = with pkgs; [
      omp
    ];
    home.file = {
      ".omp/agent/config.yml".source = mkNixConfigSymlink "config.yml";
      ".omp/agent/models.yml".source = mkNixConfigSymlink "models.yml";
    };

    home.persistence."/persist".directories = [
      ".omp"
    ];
  };
}
