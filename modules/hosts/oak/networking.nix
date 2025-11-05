{
  flake.modules.nixos.hosts-oak = {...}: {
    networking = {
      # required for ZFS
      hostId = "d86c4730";
      hostName = "oak";
      interfaces = {
        enp68s0.useDHCP = true;
        wlo2.useDHCP = true;
      };
      nameservers = [
        "192.168.1.1"
      ];
    };

    boot = {
      kernelModules = ["igb"];
      initrd = {
        kernelModules = ["igb"];
        systemd = {
          network = {
            enable = false;
            networks.enp68s0 = {
              enable = true;
              name = "enp68s0";
              DHCP = "yes";
            };
          };
        };
      };
    };
  };
}
