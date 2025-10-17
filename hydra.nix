{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs) lib;
in {
  hosts =
    outputs.nixosConfigurations
    # remove iso, I don't need it every build
    |> lib.filterAttrs (n: _v: !builtins.elem n ["iso"])
    # add to my jobs dashboard and set up evaluation error notifications
    |> lib.mapAttrs (
      _: cfg:
        lib.addMetaAttrs {maintainers = ["email@ntfy.decent.id"];} cfg.config.system.build.toplevel
    );
}
