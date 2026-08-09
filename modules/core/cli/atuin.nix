{
  flake.modules.homeManager.core = {...}: {
    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        auto_sync = true;
        sync_address = "https://atuin.oak.decent.id";
        sync_frequency = "0";
        update_check = false;
        workspaces = true;
      };
    };
  };
}
