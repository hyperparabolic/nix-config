{
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
}
