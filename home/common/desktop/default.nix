{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./discord.nix
    ./firefox.nix
    ./easyeffects
    ./ghostty.nix
    ./krita.nix
    ./slack.nix
    ./stylix.nix
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
}
