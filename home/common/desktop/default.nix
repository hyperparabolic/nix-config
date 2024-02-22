{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./discord.nix
    ./firefox.nix
    ./font.nix
    ./krita.nix
    ./kitty.nix
    ./lutris.nix
    ./slack.nix
    ./vscode.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    # wayland xrandr tools
    gnome-randr
    wlr-randr

    vlc
  ];
}
