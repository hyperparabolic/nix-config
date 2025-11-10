{lib, ...}: {
  flake.templates =
    builtins.readDir ../../templates
    |> lib.filterAttrs (_n: v: v == "directory")
    |> lib.mapAttrs' (
      name: _:
        lib.nameValuePair
        name
        {
          path = ../../templates/${name};
          description = "${name} flake template";
        }
    );
}
