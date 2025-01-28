let
  input_filter = {
    "input" = {
      "blocklist" = [];
      "compressor#0" = {
        "attack" = 20.0;
        "boost-amount" = 6.0;
        "boost-threshold" = -72.0;
        "bypass" = false;
        "dry" = -100.0;
        "hpf-frequency" = 10.0;
        "hpf-mode" = "off";
        "input-gain" = 0.0;
        "knee" = -6.0;
        "lpf-frequency" = 20000.0;
        "lpf-mode" = "off";
        "makeup" = 0.0;
        "mode" = "Downward";
        "output-gain" = 0.0;
        "ratio" = 4.0;
        "release" = 100.0;
        "release-threshold" = -100.0;
        "sidechain" = {
          "lookahead" = 0.0;
          "mode" = "RMS";
          "preamp" = 0.0;
          "reactivity" = 10.0;
          "source" = "Middle";
          "stereo-split-source" = "Left/Right";
          "type" = "Feed-forward";
        };
        "stereo-split" = false;
        "threshold" = -12.0;
        "wet" = 0.0;
      };
      "plugins_order" = [
        "compressor#0"
        "rnnoise#0"
      ];
      "rnnoise#0" = {
        "bypass" = false;
        "enable-vad" = true;
        "input-gain" = 0.0;
        "model-name" = "";
        "output-gain" = 0.0;
        "release" = 20.0;
        "vad-thres" = 50.0;
        "wet" = 0.0;
      };
    };
  };
in {
  xdg.configFile.easyeffects_input_filter = {
    enable = true;
    force = true;
    target = "easyeffects/input/input_filter.json";
    text = builtins.toJSON input_filter;
  };
  services.easyeffects = {
    enable = true;
    preset = "input_filter";
  };
}
