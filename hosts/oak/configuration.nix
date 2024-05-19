{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    # inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
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

  networking.hostName = "oak";

  # required for ZFS
  networking.hostId = "d86c4730";

  programs = {
    dconf.enable = true;
  };

  # I have no intent to ever try to hibernate this host for now (nvidia, bleh).
  # It also should never run out of RAM, but I still want swap for OS optimization.
  # zram (https://wiki.archlinux.org/title/Zram) creates a RAM block device with
  # zstd compression so the OS can still have swap for memory management purposes.
  zramSwap = {
    enable = true;
    # May grow up to 50% of RAM capacity if something insane is happening (increasing
    # capacity by the compression ratio), but doesn't start there.
    memoryPercent = 50;
  };

  # disable gdm suspend
  services.xserver.displayManager.gdm.autoSuspend = false;
  boot = {
    kernelParams = [
      "nohibernate"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  hyperparabolic.base.zfs = {
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

  # intel discrete graphics with hardware acceleration tweaks
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
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
                "node.name" = "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.HiFi__scarlett2i_mono_in_USB_0_0__source";
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
