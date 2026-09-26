{
  flake.modules.nixos.hosts-redbud = {...}: {
    networking = {
      nameservers = [
        "192.168.1.1"
      ];
    };

    this.networking = {
      hostname = "redbud";
      hostId = "55fbb629";
      defaultNetworkInterface = "wlp1s0";
      networkInterfaces = ["wlp1s0"];
    };
  };
}
