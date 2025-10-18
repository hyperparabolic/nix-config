{inputs, ...}: {
  # expose flake-parts options for nixd and nix repl
  debug = true;

  imports = [
    inputs.flake-parts.flakeModules.modules
  ];
}
