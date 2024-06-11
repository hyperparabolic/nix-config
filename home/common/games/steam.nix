{
  config,
  lib,
  pkgs,
  ...
}: let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        gamescope
        mangohud
      ];
  };

  primaryMonitor = lib.head (lib.filter (m: m.primary) config.monitors);

  # runs steam as a standalone wayland session
  steam-session = let
    gamescope = lib.concatStringsSep " " [
      (lib.getExe pkgs.gamescope)
      "--output-width ${toString primaryMonitor.width}"
      "--output-height ${toString primaryMonitor.height}"
      "--framerate-limit ${toString primaryMonitor.refreshRate}"
      "--prefer-output ${primaryMonitor.name}"
      # adaptive sync and hdr flags do nothing if hardware doesn't support them
      "--adaptive-sync"
      "--hdr-enabled"
      "--expose-wayland"
      "--steam"
    ];
    steam = lib.concatStringsSep " " [
      "steam"
      "steam://open/bigpicture"
    ];
  in
    pkgs.writeTextDir "share/wayland-sessions/steam-session.desktop"
    ''
      [Desktop Entry]
      Name=Steam
      Exec=${pkgs.gamemode}/bin/gamemoderun ${gamescope} -- ${steam}
      Type=Application
    '';
in {
  home.packages = [
    steam-with-pkgs
    steam-session
    pkgs.gamescope
  ];

  home.persistence = {
    "/persist/home/spencer" = {
      directories = [
        ".factorio"
        ".local/share/Steam"
        ".local/share/Tabletop Simulator"
      ];
    };
  };
}
