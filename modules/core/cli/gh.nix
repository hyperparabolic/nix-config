{pkgs, ...}: {
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-dash
      gh-markdown-preview
    ];
    settings = {
      git_protocol = "ssh";
    };
  };
  home.persistence."/persist".files = [".config/gh/hosts.yml"];
}
