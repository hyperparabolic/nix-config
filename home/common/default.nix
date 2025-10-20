{lib, ...}: {
  imports = [
    ./cli
    ./dev
    ./helix
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

  dconf.settings = {
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };
    "org/virt-manager/virt-manager/connections" = {
      uris = ["qemu:///system"];
      autoconnect = ["qemu:///system"];
    };
  };
}
