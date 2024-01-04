{ pkgs, ... }: {
  imports = [
    ./discord.nix
    ./firefox.nix
    ./font.nix
    ./kitty.nix
    ./lutris.nix
    ./slack.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    # wayland xrandr tools
    gnome-randr
    wlr-randr

    vlc
  ];
}
