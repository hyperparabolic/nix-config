{
  flake.modules.nixos.hosts-pando1 = {...}: {
    networking = {
      nameservers = [
        "192.168.1.1"
      ];
    };

    this.networking = {
      hostname = "pando1";
      hostId = "8a2bcdd2";
      defaultNetworkInterface = "eno2";
      networkInterfaces = [
        "eno2"
        "wlo1"
      ];
    };
  };
}
