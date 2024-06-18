{config, lib, pkgs, ...}: {
  imports = [
    ./common
  ];

  
  # poke pipewire.service, this makes devices show up over ssh if local session exists
  programs.zsh.loginExtra = ''
    systemctl --user --no-pager status pipewire.service > /dev/null
  '';

}
