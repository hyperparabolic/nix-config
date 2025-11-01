{
  flake.modules.nixos.core = {
    inputs,
    outputs,
    ...
  }: {
    imports =
      [
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-hydra-upgrade.nixosModules.nixos-hydra-upgrade
      ]
      ++ (builtins.attrValues outputs.nixosModules);

    home-manager = {
      extraSpecialArgs = {inherit inputs outputs;};
      sharedModules =
        [
          inputs.impermanence.homeManagerModules.impermanence
          inputs.stylix.homeModules.stylix
          inputs.walker.homeManagerModules.default
        ]
        ++ (builtins.attrValues outputs.homeManagerModules);
    };

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
