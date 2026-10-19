{
  flake.modules.nixos.hosts-pando2 = {...}: {
    networking = {
      nameservers = [
        "192.168.1.1"
      ];
    };

    this.networking = {
      hostname = "pando2";
      hostId = "9dd4b677";
      defaultNetworkInterface = "eno2";
      networkInterfaces = [
        "eno2"
        "wlo1"
      ];
    };
  };
}
