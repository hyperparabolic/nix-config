{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./discord.nix
    ./firefox.nix
    ./easyeffects
    ./ghostty.nix
    ./krita.nix
    ./kitty.nix
    ./slack.nix
    ./vscode.nix
    ./zathura.nix
    ./zoom.nix
  ];

  home.packages = with pkgs; [
    # wayland xrandr tools
    gnome-randr
    wlr-randr

    vlc
  ];
}
