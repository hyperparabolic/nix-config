{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/hyprland.nix
    ../common/optional/notify.nix
    ../common/optional/ntfy-client.nix
    ../common/optional/steam.nix
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  hyperparabolic = {
    impermanence = {
      enable = true;
      enableRollback = true;
    };
    zfs = {
      enable = true;
      autoSnapshot = true;
      impermanenceRollbackSnapshot = "rpool/crypt/local/root@blank";
      luksOnZfs = {
        enable = true;
        backingDevices = ["dev-nvme0n1p2.device"];
      };
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam.gamescopeSession.args = [
    "--output-width 2256"
    "--output-height 1504"
    "--prefer-output eDP-1"
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
