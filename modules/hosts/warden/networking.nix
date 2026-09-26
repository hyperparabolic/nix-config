{
  flake.modules.nixos.hosts-warden = {...}: {
    networking = {
      nameservers = [
        "127.0.0.1"
      ];
    };

    this.networking = {
      hostname = "warden";
      hostId = "59a43ec6";
      defaultNetworkInterface = "enp2s0";
      networkInterfaces = [
        "enp2s0"
        "wlp3s0"
      ];
    };
  };
}
