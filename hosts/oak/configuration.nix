{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.system76
    ./hardware-configuration.nix
    ./services
    ./virtualization
    ../common/global
    ../common/optional/hyprland.nix
    ../common/optional/libvirt.nix
    ../common/optional/ntfy-client.nix
    ../common/optional/secureboot.nix
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking = {
    # required for ZFS
    hostId = "d86c4730";
    hostName = "oak";
    nameservers = [
      "192.168.1.1"
    ];
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_6_12;
    kernelModules = ["igb"];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    initrd = {
      kernelModules = ["igb"];
      systemd = {
        enable = true;
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

  hyperparabolic = {
    impermanence = {
      enable = true;
      enableRollback = true;
    };
    zfs = {
      enable = true;
      autoSnapshot = true;
      impermanenceRollbackSnapshot = "rpool/crypt/local/root@blank";
      luksOnZfs = {
        enable = true;
        backingDevices = [
          "dev-nvme0n1p1.device"
          "dev-nvme2n1p1.device"
        ];
      };
      zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
      zedMailCommand = "${pkgs.notify}/bin/notify";
      zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
    };
  };

  # there are some issues with non-legacymount datasets imported via boot.zfs.extraPools
  # mainly that pools imported this way mount all datasets including canmount=noauto
  # I don't want these mounted on boot, so this service mounts them instead
  systemd.services.zfs-mount-tank = {
    description = "import tank zfs pool and mount datasets";
    enable = true;
    # early enough in boot, sidesteps issues with hardware being unavailable
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = lib.getExe (
        # ensure pool is not already mounted
        pkgs.writeShellScriptBin "zfs-check-tank-mount" ''
          ! ${config.boot.zfs.package}/bin/zpool status | grep 'pool: tank$'
        ''
      );
      ExecStart = lib.getExe (
        pkgs.writeShellScriptBin "zfs-tank-mount" ''
          ${config.boot.zfs.package}/bin/zpool import tank
          ${config.boot.zfs.package}/bin/zfs mount -a
        ''
      );
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      # hardware accelerated media conversion
      pkgs.vpl-gpu-rt
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
