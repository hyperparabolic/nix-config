{
  flake.modules.homeManager.core = {pkgs, ...}: {
    home.packages = with pkgs; [
      yubikey-manager
    ];
  };
}
