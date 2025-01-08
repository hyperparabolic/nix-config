{pkgs, ...}: {
  imports = [
    ./js.nix
  ];

  home.packages = with pkgs; [
    justbuild
  ];
}
