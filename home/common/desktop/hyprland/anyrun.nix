{ pkgs, inputs, ... }: {
  programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        anyrun-with-all-plugins
      ];
      closeOnClick = true;
    };
    # TODO: decide on position, and add styling
  };
}
