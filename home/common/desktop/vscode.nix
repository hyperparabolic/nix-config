{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      eamodio.gitlens
      jnoortheen.nix-ide
      vscodevim.vim
    ];
  };

  home.persistence = {
    "/persist/home/spencer" = {
      directories = [
        ".vscode"
      ];
    };
  };
 }
