{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./ssh.nix
    ./starship.nix
    ./yazi.nix
    ./zoxide.nix
    ./zsh.nix
  ];
  # zero config packages
  home.packages = with pkgs;
    [
      bat # cat alternative with auto pager
      du-dust # du alternative
      eza # ls alternative
      fselect # file finder with sql-ish syntax
      glances # system monitor
      jq # json parsing
      ouch # file compression / decompression
      ripgrep # grep alternative
      yq-go # yaml parsing / editing

      alejandra # nix formatter
      nixd # nix lsp
    ]
    ++ lib.map lazy-app.override [
      {pkg = dmidecode;}
      {
        pkg = pciutils;
        exe = "lspci";
      }
      {
        pkg = usbutils;
        exe = "lsusb";
      }
    ];
}
