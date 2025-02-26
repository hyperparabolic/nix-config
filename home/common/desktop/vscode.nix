{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
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
