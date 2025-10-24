{
  flake.modules.nixos.core = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [helix];
  };

  flake.modules.homeManager.core = {lib, ...}: {
    home.sessionVariables.EDITOR = lib.mkForce "hx";

    programs.helix = {
      enable = true;

      settings = {
        theme = "catppuccin_macchiato";

        editor = {
          bufferline = "always";
          cursorline = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          gutters = ["diff" "diagnostics" "spacer" "line-numbers"];
          indent-guides = {
            render = true;
          };
          line-number = "relative";
          lsp = {
            display-inlay-hints = true;
            display-messages = true;
          };
          soft-wrap.enable = true;
          statusline = {
            left = ["mode" "selections" "file-name" "total-line-numbers"];
            center = [];
            right = ["diagnostics" "file-encoding" "file-type" "version-control" "spinner" "file-modification-indicator" "position-percentage" "position"];
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };
          true-color = true;
          whitespace = {
            characters = {
              space = "·";
              nbsp = "⍽";
              tab = "→";
              newline = "⤶";
            };
            render = "all";
          };
        };

        keys.normal = {
          tab = ["goto_next_buffer"];
          S-tab = ["goto_previous_buffer"];

          space = {
            x = ":buffer-close";
            u = {
              f = ":format";
              w = ":set whitespace.render all";
              W = ":set whitespace.render none";
            };
          };
        };
      };
    };
  };
}
