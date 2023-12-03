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
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/gnome.nix
    ../common/optional/nvidia
    ../common/optional/pipewire.nix
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking.hostName = "oak";
  hardware.system76.enableAll = true;

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

  # TODO: move everything below exepcet state external
  boot = {
    # no swap, disable hibernate
    kernelParams = ["nohibernate"];
    supportedFilesystems = ["zfs"];
    zfs.forceImportRoot = false;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    # rollback root fs to blank snapshot
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/crypt/local/root@blank
    '';
  };

  # use latest kernel packages that are compatible with ZFS
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    zed = {
      # requires recompilation
      enableMail = false;
      # but these still sending messages for simple stdin cli tools
      settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = [ "root" ];
        ZED_EMAIL_PROG = "${pkgs.notify}/bin/notify";
        ZED_EMAIL_OPTS = "-bulk -provider-config /run/secrets/notify-provider-config";

        ZED_NOTIFY_INTERVAL_SECS = 3600;
        ZED_NOTIFY_VERBOSE = true;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
