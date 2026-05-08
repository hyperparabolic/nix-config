{
  flake.modules.nixos.hosts-oak = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
    };
    environment.persistence."/persist".directories = ["/var/lib/private/ollama"];
  };
}
