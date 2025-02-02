{
  pkgs,
  lib,
  ...
}: {
  xdg.configFile = {
    xdg-desktop-portal-termfilechooser = {
      enable = true;
      force = true;
      target = "xdg-desktop-portal-termfilechooser/config";
      text = ''
        [filechooser]
        cmd=yazi-wrapper.sh
        default_dir=$HOME/Downloads
        env=TERMCMD=${lib.getExe pkgs.ghostty};
      '';
    };
  };
}
