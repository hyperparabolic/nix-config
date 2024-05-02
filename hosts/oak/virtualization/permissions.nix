{
  lib,
  pkgs,
  config,
  ...
}: {
  /*
  Permissions tweaks to enable vfio passthrough as a non-root user
  */
  # provision additional user to run qemu as
  users = {
    groups.qemu_user = {
      gid = 988;
    };
    users = {
      qemu_user = {
        uid = 1001;
        # needed permissions
        extraGroups = [
          "audio"
          "input"
          "kvm"
          "pipewire"
        ];
        # need to be able to act as user
        isNormalUser = true;
        # but undo all of the extras
        group = "qemu_user";
        createHome = false;
      };
    };
  };

  # change owner of vfio subsystem, mouse and keyboard to kvm group
  # mouse: 2ea8:2203
  # keyboard: 04d9:0171
  # bluetooth: 8087:0029
  # usb rules area maybe unnecessary with input group? These are not working, as is, end result is all of the usb
  # devices in input are owned by the "input" group rather than kvm
  #  SUBSYSTEM=="input", SUBSYSTEMS=="usb", ATTR{idVendor}=="2ea8", ATTR{idProduct}=="2203" OWNER="root", GROUP="kvm"
  #  SUBSYSTEM=="input", SUBSYSTEMS=="usb", ATTR{idVendor}=="04d9", ATTR{idProduct}=="0171" OWNER="root", GROUP="kvm"
  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0029" OWNER="root", GROUP="kvm"
  '';

  systemd.services.zfs-file-owners = {
    description = "change owner of zvols to kvm";
    enable = true;
    # early enough in boot, sidesteps issues with hardware being unavailable
    wantedBy = ["multi-user.target"];
    partOf = ["zfs-mount-tank.service"];
    after = ["zfs-mount-tank.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (
        pkgs.writeShellScriptBin "zfs-set-zvol-owners" ''
          chown root:kvm /dev/zvol/rpool/crypt/virt/win10
        ''
      );
    };
  };

  security = {
    pam.loginLimits = [
      {
        domain = "qemu_user";
        type = "soft";
        item = "memlock";
        value = "20000000"; # 20GB
      }
      {
        domain = "qemu_user";
        type = "hard";
        item = "memlock";
        value = "20000000"; # 20GB
      }
    ];

    sudo = {
      extraRules = [
        {
          users = ["spencer"];
          runAs = "qemu_user";
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
