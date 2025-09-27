{
  imports = [
    ./common
  ];

  # poke pipewire.service, this makes devices show up over ssh if local session exists
  programs.zsh.loginExtra = ''
    systemctl --user --no-pager status pipewire.service > /dev/null
    wpctl status > /dev/null
  '';

  # mcp client kiosk styling
  stylix.targets.gtk.enable = true;

  home.persistence."/persist".directories = [".local/state/wireplumber"];
}
