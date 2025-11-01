{
  flake.modules.homeManager.dev-js = {
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
