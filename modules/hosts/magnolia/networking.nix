{
  flake.modules.nixos.hosts-magnolia = {...}: {
    networking = {
      nameservers = [
        "9.9.9.9"
        "149.112.112.112"
      ];
    };

    this.networking = {
      hostname = "magnolia";
      hostId = "15e99f7b";
      defaultNetworkInterface = "wlp1s0";
      networkInterfaces = ["wlp1s0"];
    };
  };
}
