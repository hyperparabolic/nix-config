{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./discord.nix
    ./firefox.nix
    ./easyeffects
    ./ghostty.nix
    ./krita.nix
    ./slack.nix
    ./vscode.nix
    ./yubikey-notify.nix
    ./zathura.nix
    ./zoom.nix
  ];

  home.packages = with pkgs;
    [
      # wayland xrandr tools
      gnome-randr
      wlr-randr

      vlc
    ]
    # less frequently used apps are realized lazily
    ++ lib.map lazy-app.override [
      {pkg = d-spy;}
    ];

  stylix.image = pkgs.fetchurl {
    name = "leaves.png";
    url = "https://i.imgur.com/9EAejof.png";
    hash = "sha256-k3nLKUCmjrUAkM7NJev/LNSCC5Kx6jWBXyngAb/MZXU=";
  };
}
