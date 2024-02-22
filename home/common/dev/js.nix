{pkgs, ...}: {
  home.packages = with pkgs; [
    bun
    corepack
    deno
    nodejs_20
  ];

  home.persistence = {
    "/persist/home/spencer" = {
      directories = [
        ".bun"
        ".cache/deno"
        ".npm"
        ".yarn"
      ];
      files = [
        ".npmrc"
        ".yarnrc.yml"
      ];
    };
  };
}
