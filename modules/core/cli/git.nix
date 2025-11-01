{
  flake.modules.homeManager.core = {
    pkgs,
    config,
    ...
  }: {
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      settings = {
        alias = {
          last = "log -1 HEAD --stat";
        };
        init.defaultBranch = "main";
        user = {
          name = "Spencer Balogh";
          email = "spbalogh@gmail.com";
        };
      };
      signing = {
        signer = "${config.programs.gpg.package}/bin/gpg2";
        key = "766F3DDF324B5355";
        signByDefault = true;
      };
      ignores = [
        ".direnv"
      ];
    };
  };
}
