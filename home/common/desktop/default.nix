{ pkgs, ... }: {
  imports = [
    ./discord.nix
    ./firefox.nix
    ./slack.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    # wayland xrandr tools
    gnome-randr
    wlr-randr
  ];
}
