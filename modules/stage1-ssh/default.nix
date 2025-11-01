{
  flake.modules.nixos.stage1-ssh = {
    config,
    lib,
    ...
  }: {
    # systemd stage1 ssh
    # systemd stage1 networking must be separately configured, and
    # the ssh key below must be provisioned.
    boot = {
      initrd = {
        secrets = {
          "/persist/boot/ssh/ssh_host_ed25519_key" = "/persist/boot/ssh/ssh_host_ed25519_key";
        };
        systemd = {
          enable = lib.mkForce true;
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
  };
}
