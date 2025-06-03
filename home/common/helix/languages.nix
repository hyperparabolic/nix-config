{
  pkgs,
  lib,
  ...
}: {
  programs.helix = {
    extraPackages = with pkgs;
    # delayed package realization for language servers
      lib.map lazy-app.override [
        # docker / docker compose
        {
          pkg = dockerfile-language-server-nodejs;
          exe = "docker-langserver";
        }
        {
          pkg = docker-compose-language-service;
          exe = "docker-compose-langserver";
        }

        {pkg = lua-language-server;}

        # markup and config
        {pkg = marksman;} # markdown
        {pkg = taplo;} # TOML
        {
          pkg = vscode-langservers-extracted;
          exe = "vscode-css-language-server";
        }
        {
          pkg = vscode-langservers-extracted;
          exe = "vscode-html-language-server";
        }
        {
          pkg = vscode-langservers-extracted;
          exe = "vscode-json-language-server";
        }
        {pkg = yaml-language-server;}

        # vala gui apps
        {pkg = meson;}
        {pkg = blueprint-compiler;}
        {pkg = uncrustify;}
        {pkg = vala-language-server;}
        {
          pkg = vala-lint;
          exe = "io.elementary.vala-lint";
        }

        {pkg = openscad-lsp;}
      ];

    languages = {
      language-server = {
        bash-language-server = {
          command = "${lib.getExe (pkgs.lazy-app.override {pkg = pkgs.nodePackages.bash-language-server;})}";
        };

        nixd = {
          command = lib.getExe pkgs.nixd;
        };

        rust-analyzer = {
          config.rust-analyzer = {
            cargo.loadOutDirsFromCheck = true;
            checkOnSave.command = "clippy";
            procMacro.enable = true;
            lens = {
              references = true;
              methodReferences = true;
            };
            completion.autoimport.enable = true;
            experimental.procAttrMacros = true;
          };
        };

        typescript-language-server = {
          command = "${lib.getExe (pkgs.lazy-app.override {pkg = pkgs.nodePackages.typescript-language-server;})}";
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = ["nixd"];
          formatter = {
            command = "${lib.getExe pkgs.alejandra}";
            args = ["-q"];
          };
        }
        {
          name = "vala";
          auto-format = true;
          language-servers = ["vala-language-server"];
          formatter = {
            command = "${lib.getExe (pkgs.lazy-app.override {pkg = pkgs.uncrustify;})} -c $(${lib.getExe pkgs.git} rev-parse --show-toplevel)/uncrustify.cfg -l VALA";
          };
        }
      ];
    };
  };
}
