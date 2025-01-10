{
  pkgs,
  lib,
  ...
}: {
  programs.helix = {
    extraPackages = with pkgs; [
      blueprint-compiler
      dockerfile-language-server-nodejs
      docker-compose-language-service
      lua-language-server
      marksman
      meson
      openscad-lsp
      taplo
      vala-language-server
      vala-lint
      vscode-langservers-extracted
      yaml-language-server
    ];

    languages = {
      language-server = {
        bash-language-server = {
          command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
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
          command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
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
            command = "${lib.getExe pkgs.vala-lint}";
          };
        }
      ];
    };
  };
}
