{
  self,
  lib,
  ...
}: let
  templatesDir = "${self}/templates";
in {
  flake.templates =
    builtins.readDir templatesDir
    |> lib.filterAttrs (_n: v: v == "directory")
    |> lib.mapAttrs' (
      name: _:
        lib.nameValuePair
        name
        {
          path = "${templatesDir}/${name}";
          description = "${name} flake template";
        }
    );
}
