{
  flake.modules.nixos.stage1-ssh = {
    config,
    lib,
    ...
  }: {
    # systemd stage1 ssh
    # systemd stage1 networking is configured for the default network
    # interface, and the ssh key below must be provisioned.
    config = {
      boot = {
        kernelModules = ["igb"];
        initrd = {
          kernelModules = ["igb"];
          secrets = {
            "/persist/boot/ssh/ssh_host_ed25519_key" = "/persist/boot/ssh/ssh_host_ed25519_key";
          };
          systemd = {
            enable = lib.mkForce true;
            network = {
              enable = lib.mkDefault false;
              networks."${config.this.networking.defaultNetworkInterface}" = {
                enable = true;
                name = config.this.networking.defaultNetworkInterface;
                DHCP = "yes";
              };
            };
            services.remote-unlock = {
              description = "Prepare for remote drive decryption";
              wantedBy = ["initrd.target"];
              after = ["systemd-networkd.service"];
              serviceConfig.Type = "oneshot";
              script = ''
                echo "systemctl default" >> /var/empty/.profile
              '';
            };
          };
          network = {
            ssh = {
              enable = true;
              port = 2222;
              hostKeys = ["/persist/boot/ssh/ssh_host_ed25519_key"];
              authorizedKeys = config.users.users.spencer.openssh.authorizedKeys.keys;
            };
          };
        };
      };

      assertions = [
        {
          assertion = config.this.networking.defaultNetworkInterface != null;
          message = "stage1-ssh: this.networking.defaultNetworkInterface must be set";
        }
      ];
    };
  };
}
