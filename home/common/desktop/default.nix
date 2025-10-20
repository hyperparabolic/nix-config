{pkgs, ...}: {
  stylix.image = pkgs.fetchurl {
    name = "leaves.png";
    url = "https://i.imgur.com/9EAejof.png";
    hash = "sha256-k3nLKUCmjrUAkM7NJev/LNSCC5Kx6jWBXyngAb/MZXU=";
  };
}
