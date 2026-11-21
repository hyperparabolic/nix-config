{
  flake.modules.homeManager.ai-omp = {
    config,
    pkgs,
    ...
  }: let
    ompDir = "/home/spencer/.nix-config/modules/ai/omp";
    mkNixConfigSymlink = fileName: config.lib.file.mkOutOfStoreSymlink "${ompDir}/${fileName}";

    ompWrapped = pkgs.symlinkJoin {
      name = "omp-with-python";
      paths = [pkgs.omp pkgs.python3];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        mv $out/bin/omp $out/bin/.omp
        makeWrapper $out/bin/.omp $out/bin/omp --prefix PATH : "$out/bin"
      '';
    };
  in {
    home.packages = [
      ompWrapped
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
