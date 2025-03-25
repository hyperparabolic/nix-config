{pkgs, ...}: {
  imports = [
    ./common
  ];

  # bootstrapping tooling
  home.packages = with pkgs; [
    sops
    ssh-to-age
    gnupg
    age
  ];
}
