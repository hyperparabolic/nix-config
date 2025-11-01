{pkgs, ...}: {
  # bootstrapping tooling
  home.packages = with pkgs; [
    sops
    ssh-to-age
    gnupg
    age
  ];
}
