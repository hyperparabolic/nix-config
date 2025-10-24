{
  flake.modules.homeManager.core = {
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
            pkg = dockerfile-language-server;
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

          deno-lsp = {
            command = "${lib.getExe (pkgs.lazy-app.override {pkg = pkgs.deno;})}";
            args = ["lsp"];
            required-root-patterns = ["deno.*"];
            config.deno.enable = true;
            config.deno.suggest = {
              completeFunctionCalls = false;
              imports.hosts."https://deno.land" = true;
            };
          };

          nixd = {
            command = lib.getExe pkgs.nixd;
            args = ["--semantic-tokens=true"];
            config.nixd = let
              myFlake = "(builtins.getFlake (toString /home/spencer/.nix-config))";
              nixosOpts = "${myFlake}.nixosConfigurations.oak.options";
            in {
              nixpkgs.expr = "import ${myFlake}.inputs.nixpkgs { }";
              options = {
                nixos.expr = nixosOpts;
                home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions []";
                flake-parts.expr = "${myFlake}.debug.options";
                flake-parts2.expr = "${myFlake}.currentSystem.options";
              };
            };
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
            required-root-patterns = ["package.json" "tsconfig.json"];
          };
        };

        language = [
          {
            name = "javascript";
            auto-format = true;
            language-servers = ["deno-lsp" "typescript-language-server"];
            file-types = ["js" "jsx"];
            roots = ["deno.json" "deno.jsonc" "package.json" "tsconfig.json"];
          }
          {
            name = "typescript";
            auto-format = true;
            language-servers = ["deno-lsp" "typescript-language-server"];
            file-types = ["ts" "tsx"];
            roots = ["deno.json" "deno.jsonc" "package.json" "tsconfig.json"];
          }
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
  };
}
