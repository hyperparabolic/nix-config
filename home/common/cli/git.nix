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
      gpgPath = "${config.programs.gpg.package}/bin/gpg2";
      key = "E393262B7CD2FD5F";
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
