{
  home.persistence."/persist/home/spencer" = {
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
