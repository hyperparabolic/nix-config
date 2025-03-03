{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.system76
    ./hardware-configuration.nix
    ./services
    ./virtualization
    ../common/global
    ../common/optional/hyprland.nix
    ../common/optional/jellyfin.nix
    ../common/optional/libvirt.nix
    ../common/optional/pipewire.nix
    ../common/optional/pipewire-raop.nix
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

  programs = {
    dconf.enable = true;
  };

  # zram (https://wiki.archlinux.org/title/Zram) creates a RAM block device with
  # zstd compression so the OS can still have swap for memory management purposes,
  # and an extra buffer.
  zramSwap = {
    enable = true;
    # May grow up to 50% of RAM capacity if something insane is happening (increasing
    # capacity by the compression ratio), but doesn't start there.
    memoryPercent = 50;
  };

  boot = {
    kernelModules = ["igb"];
    kernelParams = [
      "nohibernate"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    initrd = {
      kernelModules = ["igb"];
      secrets = {
        "/persist/boot/ssh/ssh_host_ed25519_key" = "/persist/boot/ssh/ssh_host_ed25519_key";
      };
      systemd = {
        enable = true;
        network = {
          enable = true;
          networks.enp68s0 = {
            enable = true;
            name = "enp68s0";
            DHCP = "yes";
          };
        };
        services.zfs-remote-unlock = {
          description = "Prepare for ZFS remote unlock";
          wantedBy = ["initrd.target"];
          after = ["systemd-networkd.service"];
          path = with pkgs; [
            zfs
          ];
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

  hyperparabolic.zfs = {
    enable = true;
    autoSnapshot = true;
    rollbackSnapshot = "rpool/crypt/local/root@blank";
    zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
    zedMailCommand = "${pkgs.notify}/bin/notify";
    zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
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

  # tweak default audio device priority
  services.pipewire = {
    wireplumber.extraConfig = {
      "60-dac-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "node.name" = "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.HiFi__Mic1__source";
              }
            ];
            actions = {
              update-props = {
                # normal input priority is sequential starting at 2000
                "priority.driver" = "3000";
                "priority.session" = "3000";
              };
            };
          }
        ];
      };
    };
  };

  # TODO: temporarily disabled due to build issues
  hardware.system76.power-daemon.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
