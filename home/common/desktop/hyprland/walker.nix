{config, ...}: {
  programs = {
    elephant = {
      enable = true;
      installService = true;
      settings = {
        # explicit default to validate upstream module changes, TODO: delete me
        auth_detect_launch_prefix = true;
      };
      providerSettings = [
        {
          name = "websearch";
          settings = {
            entries = [
              {
                default = true;
                name = "DuckDuckGo";
                url = "https://duckduckgo.com/?q=%TERM%";
              }
              {
                name = "NixOS Options";
                url = "https://search.nixos.org/options?channel=unstable&query=%TERM%";
              }
              {
                name = "NixOS Packages";
                url = "https://search.nixos.org/packages?channel=unstable&query=%TERM%";
              }
              {
                name = "Home Manager Options";
                url = "https://home-manager-options.extranix.com/?release=master&query=%TERM%";
              }
              {
                name = "Google";
                url = "https://www.google.com/search?q=%TERM%";
              }
            ];
          };
        }
      ];
    };
    walker = {
      enable = true;
      runAsService = true;
      config = {
        theme = "nixos";
        providers = {
          default = [
            "desktopapplications"
            "calc"
            "menus"
          ];
          prefixes = [
            {
              provider = "bluetooth";
              prefix = "&";
            }
            {
              provider = "files";
              prefix = "/";
            }
            {
              provider = "providerlist";
              prefix = "_";
            }
            {
              provider = "runner";
              prefix = "$";
            }
            {
              provider = "symbols";
              prefix = ":";
            }
            {
              provider = "todo";
              prefix = "!";
            }
            {
              provider = "unicode";
              prefix = "%";
            }
            {
              provider = "websearch";
              prefix = "@";
            }
          ];
        };
      };
      elephant = {
        installService = true;
      };

      themes."nixos" = {
        style = ''
          @define-color foreground #${config.lib.stylix.colors.base08};
          @define-color background #${config.lib.stylix.colors.base00};
          @define-color cursor #${config.lib.stylix.colors.base08};

          @define-color color0 #${config.lib.stylix.colors.base00};
          @define-color color1 #${config.lib.stylix.colors.base01};
          @define-color color2 #${config.lib.stylix.colors.base02};
          @define-color color3 #${config.lib.stylix.colors.base03};
          @define-color color4 #${config.lib.stylix.colors.base04};
          @define-color color5 #${config.lib.stylix.colors.base05};
          @define-color color6 #${config.lib.stylix.colors.base06};
          @define-color color7 #${config.lib.stylix.colors.base07};
          @define-color color8 #${config.lib.stylix.colors.base08};
          @define-color color9 #${config.lib.stylix.colors.base09};
          @define-color color10 #${config.lib.stylix.colors.base10};
          @define-color color11 #${config.lib.stylix.colors.base11};
          @define-color color12 #${config.lib.stylix.colors.base12};
          @define-color color13 #${config.lib.stylix.colors.base13};
          @define-color color14 #${config.lib.stylix.colors.base14};
          @define-color color15 #${config.lib.stylix.colors.base15};

          * {
            all: unset;
          }

          .normal-icons {
            -gtk-icon-size: 16px;
          }

          .large-icons {
            -gtk-icon-size: 32px;
          }

          scrollbar {
            opacity: 0;
          }

          .box-wrapper {
            box-shadow:
              0 19px 38px rgba(0, 0, 0, 0.3),
              0 15px 12px rgba(0, 0, 0, 0.22);
            background: @window_bg_color;
            padding: 20px;
            border-radius: 20px;
            border: 1px solid darker(@accent_bg_color);
          }

          .preview-box,
          .elephant-hint,
          .placeholder {
            color: @theme_fg_color;
          }

          .box {
          }

          .search-container {
            border-radius: 10px;
          }

          .input placeholder {
            opacity: 0.5;
          }

          .input {
            caret-color: @theme_fg_color;
            background: lighter(@window_bg_color);
            padding: 10px;
            color: @theme_fg_color;
          }

          .input:focus,
          .input:active {
          }

          .content-container {
          }

          .placeholder {
          }

          .scroll {
          }

          .list {
            color: @theme_fg_color;
          }

          child {
          }

          .item-box {
            border-radius: 10px;
            padding: 10px;
          }

          .item-quick-activation {
            margin-left: 10px;
            background: alpha(@accent_bg_color, 0.25);
            border-radius: 5px;
            padding: 10px;
          }

          child:hover .item-box,
          child:selected .item-box {
            background: alpha(@accent_bg_color, 0.25);
          }

          .item-text-box {
          }

          .item-text {
          }

          .item-subtext {
            font-size: 12px;
            opacity: 0.5;
          }

          .item-image {
            margin-right: 10px;
          }

          .keybind-hints {
            font-size: 12px;
            opacity: 0.5;
            color: @theme_fg_color;
          }

          .preview {
            border: 1px solid alpha(@accent_bg_color, 0.25);
            padding: 10px;
            border-radius: 10px;
            color: @theme_fg_color;
          }

          .calc .item-text {
            font-size: 24px;
          }

          .calc .item-subtext {
          }

          .symbols .item-image {
            font-size: 24px;
          }

          .todo.done .item-text-box {
            opacity: 0.25;
          }

          .todo.urgent {
            font-size: 24px;
          }

          .todo.active {
            font-weight: bold;
          }

          .preview .large-icons {
            -gtk-icon-size: 64px;
          }
        '';
      };
    };
  };

  home.persistence."/persist".directories = [".cache/elephant/"];
}
