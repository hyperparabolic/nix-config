{
  flake.modules.homeManager.dev-js = {pkgs, ...}: {
    home.packages = with pkgs; [
      bun
      nodejs
    ];
    home.persistence."/persist" = {
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
