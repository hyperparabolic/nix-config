{
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/gnome
  ];

  systemd.user.tmpfiles.rules = [
    # format: https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
    "L /home/spencer/src - - - - /tank/src"
  ];
}
