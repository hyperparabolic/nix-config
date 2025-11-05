{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.system76
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_6_12;

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
