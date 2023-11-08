{
  programs.ssh.enable = true;

  # TODO: utilize matchBlocks to set up forwardAgent for trusted hosts

  home.persistence = {
    "/persist/home/spencer".directories = [ ".ssh" ];
  };
}
