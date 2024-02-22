{
  pkgs,
  lib,
  ...
}: {
  programs.helix.languages = {
    language-server = {
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
    };
  };
}
