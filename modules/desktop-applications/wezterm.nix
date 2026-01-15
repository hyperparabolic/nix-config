{
  flake.modules.homeManager.desktop-applications = {...}: {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
      '';
    };

    stylix.targets.wezterm.enable = true;
  };
}
