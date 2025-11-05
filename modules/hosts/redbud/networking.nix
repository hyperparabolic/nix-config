{
  flake.modules.nixos.hosts-redbud = {...}: {
    networking = {
      # required for ZFS
      hostId = "55fbb629";
      hostName = "redbud";
      interfaces.wlp1s0.useDHCP = true;
      nameservers = [
        "192.168.1.1"
      ];
    };
  };
}
