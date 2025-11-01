{
  flake.modules.nixos.core = {
    inputs,
    outputs,
    pkgs,
    ...
  }: let
    hyperparabolic-bootstrap = pkgs.writeShellApplication {
      name = "hyperparabolic-bootstrap";
      runtimeInputs = with pkgs; [
        rsync

        age
        ssh-to-age
        sops
        yq-go
      ];
      text = builtins.readFile ../../scripts/hyperparabolic-bootstrap.sh;
    };
  in {
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

    environment = {
      enableAllTerminfo = true;
      wordlist.enable = true;
      systemPackages = [
        hyperparabolic-bootstrap
      ];
    };

    services = {
      dbus.implementation = "broker";
      # firmware updates: `fwupdmgr update`
      fwupd.enable = true;
    };

    users.mutableUsers = false;

    environment.persistence."/persist".directories = [
      "/var/lib/systemd"
      "/var/lib/nixos"
      "/var/log"
      "/srv"
    ];
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
