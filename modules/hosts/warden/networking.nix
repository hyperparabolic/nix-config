{
  flake.modules.nixos.hosts-warden = {...}: {
    networking = {
      # required for ZFS
      hostId = "59a43ec6";
      hostName = "warden";
      interfaces = {
        enp2s0.useDHCP = true;
        wlp3s0.useDHCP = true;
      };
      nameservers = [
        "127.0.0.1"
      ];
    };

    boot = {
      kernelModules = ["igb"];
      initrd = {
        kernelModules = ["igb"];
        systemd = {
          network = {
            enable = false;
            networks.enp2s0 = {
              enable = true;
              name = "enp2s0";
              DHCP = "yes";
            };
          };
        };
      };
    };
  };
}
