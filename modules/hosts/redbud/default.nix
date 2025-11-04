{
  flake.modules.homeManager.hosts-redbud = {...}: {
    # mcp client kiosk styling
    stylix.targets.gtk.enable = true;

    home.persistence."/persist".directories = [".local/state/wireplumber"];
  };
}
