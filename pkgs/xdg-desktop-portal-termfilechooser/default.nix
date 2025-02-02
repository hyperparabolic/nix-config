{
  lib,
  stdenv,
  fetchFromGitHub,
  inih,
  meson,
  ninja,
  pipewire,
  pkg-config,
  scdoc,
  libgbm,
  systemd,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xdg-desktop-portal,
}:
stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal-termfilechooser";
  version = "main-2-1-24";

  src = fetchFromGitHub {
    owner = "hunkyburrito";
    repo = "xdg-desktop-portal-termfilechooser";
    rev = "b7236c65185dee7d3e6d21d0d4313dbe24f51683";
    hash = "sha256-yLzG/6xyjJpldZXi2CX3uoTjqfxwSmH6aVLnBxHhZB8=";
  };

  strictDeps = true;
  depsBuildBuild = [pkg-config];
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];
  buildInputs = [
    xdg-desktop-portal
    inih
    systemd
    pipewire
    wayland
    wayland-protocols
    libgbm
  ];

  mesonFlags = [
    "-Dsd-bus-provider=libsystemd"
  ];

  meta = with lib; {
    homepage = "https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser";
    description = "terminal based file chooser";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
