{
  flake.modules.nixos.hosts-oak = {...}: {
    networking = {
      nameservers = [
        "192.168.1.1"
      ];
    };

    this.networking = {
      hostname = "oak";
      hostId = "d86c4730";
      defaultNetworkInterface = "enp73s0f1";
      networkInterfaces = [
        "enp68s0"
        "enp73s0f0"
        "enp73s0f1"
        "wlo2"
      ];
    };
  };
}
