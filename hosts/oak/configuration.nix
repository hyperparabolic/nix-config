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
    ./virtualization
    ../common/global
    ../common/optional/gnome.nix
    ../common/optional/jellyfin.nix
    ../common/optional/libvirt.nix
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

  boot = {
    kernelParams = [
      # no swap, disable hibernate
      "nohibernate"
      # load graphics driver earlier on wake from suspend
      "i915.force_probe=56a5"
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

  # intel discrete graphics with hardware acceleration tweaks
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
