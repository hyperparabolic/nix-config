{
  pkgs,
  lib,
  ...
}: {
  programs.helix = {
    extraPackages = with pkgs; [
      dockerfile-language-server-nodejs
      docker-compose-language-service
      lua-language-server
      marksman
      openscad-lsp
      vscode-langservers-extracted
      yaml-language-server
    ];

    languages = {
      language-server = {
        bash-language-server = {
          command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
        };

        nil = {
          command = lib.getExe pkgs.nil;
          config.nil.formatting.command = ["${lib.getExe pkgs.alejandra}" "-q"];
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
    };
  };
}
