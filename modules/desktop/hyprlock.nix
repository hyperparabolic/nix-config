{
  flake.modules.homeManager.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.hyprlock = {
      enable = true;

      extraConfig = ''
        animations {
          enabled = true;
          bezier = expo, 0.7, 0, 0.84, 0
          animation = fadeIn, 1, 50, expo
          animation = fadeOut, 1, 5, expo
          bezier = linear, 1, 1, 0, 0
          animation = inputFieldColors, 1, 2, linear
          animation = inputFieldDots, 1, 2, linear
          animation = inputFieldFade, 1, 2, linear
          animation = inputFieldWidth, 1, 2, linear
        }
      '';
      settings = with config.lib.stylix.colors; {
        general = {
          grace = 5;
          hide_cursor = true;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 7;
            brightness = 0.5;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            halign = "center";
            valign = "center";
            dots_center = true;
            dots_text_format = "�";
            outline_thickness = 5;
            placeholder_text = "$PAMPROMPT";
            outer_color = "rgb(${base03})";
            inner_color = "rgb(${base00})";
            font_color = "rgb(${base05})";
            fail_color = "rgb(${base08})";
            check_color = "rgb(${base0A})";
            capslock_color = "rgb(${base08})";
            shadow_passes = 2;
          }
        ];

        label = [
          {
            # Time topright
            position = "-30, 0";
            halign = "right";
            valign = "top";
            text = "$TIME12";
            font_size = 90;
            color = "rgb(${base03})";
            shadow_passes = 3;
          }
          {
            # Date topright
            position = "-30, -150";
            halign = "right";
            valign = "top";
            text = "cmd[update:60000] ${lib.getExe' pkgs.coreutils-full "date"} +\"%A, %d %B %Y\"";
            font_size = 25;
            color = "rgb(${base03})";
            shadow_passes = 3;
          }
        ];
      };
    };
  };
}
