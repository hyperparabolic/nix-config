{
  pkgs,
  config,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Spencer Balogh";
    userEmail = "spbalogh@gmail.com";
    aliases = {
      last = "log -1 HEAD --stat";
    };
    signing = {
      signer = "${config.programs.gpg.package}/bin/gpg2";
      key = "766F3DDF324B5355";
      signByDefault = true;
    };
    ignores = [
      ".direnv"
    ];
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
