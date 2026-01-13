{
  flake.modules.homeManager.desktop-applications = {config, ...}: {
    xdg.configFile.easyeffects_input_filter = {
      enable = true;
      force = true;
      target = "easyeffects/input/input_filter.json";
      text = builtins.readFile ./input_filter.json;
    };
    # https://gist.github.com/jtrv/47542c8be6345951802eebcf9dc7da31
    xdg.configFile.easyeffects_input_filter_voice = {
      enable = true;
      force = true;
      target = "easyeffects/input/input_filter_voice.json";
      text = builtins.readFile ./input_filter_voice.json;
    };
    services.easyeffects = {
      enable = true;
    };
    systemd.user.services.easyeffects = {
      Unit = {
        X-X-Restart-Triggers = [
          config.xdg.configFile.easyeffects_input_filter.source
          config.xdg.configFile.easyeffects_input_filter_voice.source
        ];
      };
    };
  };
}
