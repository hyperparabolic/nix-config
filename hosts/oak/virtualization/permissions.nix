{
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
  # usb rules area maybe unnecessary with input group? These are not working, as is, end result is all of the usb
  # devices in input are owned by the "input" group rather than kvm
  #  SUBSYSTEM=="input", SUBSYSTEMS=="usb", ATTR{idVendor}=="2ea8", ATTR{idProduct}=="2203" OWNER="root", GROUP="kvm"
  #  SUBSYSTEM=="input", SUBSYSTEMS=="usb", ATTR{idVendor}=="04d9", ATTR{idProduct}=="0171" OWNER="root", GROUP="kvm"
  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
  '';

  # use system level pipewire service to share audio devices between users
  services.pipewire.systemWide = true;

  security = {
    pam.loginLimits = [
      {
        domain = "qemu_user";
        type = "soft";
        item = "memlock";
        value = "20000000"; # 20GB
      }{
        domain = "qemu_user";
        type = "hard";
        item = "memlock";
        value = "20000000"; # 20GB
      }
    ];

    sudo = {
      extraRules = [
        {
          users = [ "spencer" ];
          runAs = "qemu_user";
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
