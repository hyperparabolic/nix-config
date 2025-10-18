{
  flake.modules.nixos.hosts-magnolia = {...}: {
    networking = {
      hostId = "15e99f7b";
      hostName = "magnolia";
      nameservers = [
        "9.9.9.9"
        "149.112.112.112"
      ];
      interfaces.wlp1s0.useDHCP = true;
    };
  };
}
