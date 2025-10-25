{lib, ...}: {
  imports = [
    ./cli
    ./dev
    ./stylix.nix
  ];

  home = {
    username = "spencer";
    homeDirectory = "/home/spencer";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];

    persistence."/persist".directories = [
      "Documents"
      "Downloads"
      "Pictures"
      "Videos"
      ".local/bin"
    ];
  };

  programs.home-manager.enable = true;
}
