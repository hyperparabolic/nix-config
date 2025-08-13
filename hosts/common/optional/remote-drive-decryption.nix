{config, ...}: {
  # Remote drive decryption and ssh debugging.
  # systemd stage1 networking must be separately configured, and
  # the ssh key below must be provisioned.
  boot = {
    loader = {
      systemd-boot.enable = true;
    };
    initrd = {
      secrets = {
        "/persist/boot/ssh/ssh_host_ed25519_key" = "/persist/boot/ssh/ssh_host_ed25519_key";
      };
      systemd = {
        enable = true;
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
}
