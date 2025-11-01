{
  flake.modules.nixos.core = {inputs, ...}: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    users.mutableUsers = false;
  };

  flake.modules.homeManager.core = {lib, ...}: {
    home = {
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
  };
}
