{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs) lib;
in {
  hosts = lib.pipe outputs.nixosConfigurations [
    # remove t iso, I don't need it every build
    (lib.filterAttrs
      (n: _v: !builtins.elem n ["iso"]))
    (lib.mapAttrs
      (_: cfg: (
        # add to my jobs dashboard and set up evaluation error notifications
        lib.addMetaAttrs {maintainers = ["email@ntfy.decent.id"];}
        cfg.config.system.build.toplevel
      )))
  ];
}
