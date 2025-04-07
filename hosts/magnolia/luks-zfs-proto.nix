{
  config,
  lib,
  ...
}: let
  zfsPkg = config.boot.zfs.package;
  devNodes = config.boot.zfs.devNodes;
in {
  boot = {
    initrd = {
      supportedFilesystems = ["ext4"];
      # creates systemd-cryptsetup@secretsroot
      luks.devices.secretsroot.device = "/dev/zvol/rpool/volumes/bootsecrets-part1";

      systemd = {
        mounts = [
          {
            # fileSystems.<name> doesn't really support mounting files in initrd that aren't
            # intended for the booted os, so creating this manually.
            description = "Secrets storage for stage 1 boot";
            where = "/bootsecrets";
            what = "/dev/mapper/secretsroot";
            options = "nofail,noauto,noexec,ro";
            bindsTo = [
              "systemd-cryptsetup@secretsroot.service"
            ];
            after = [
              "systemd-cryptsetup@secretsroot.service"
            ];
            wantedBy = ["zfs-import-rpool.service"];
            before = ["zfs-import-rpool.service"];
          }
        ];

        services = {
          zfs-import-rpool-volumes = {
            # Import rpool before cryptsetup.target so its volumes are available.
            # zfs-import-rpool.service tolerates this fine (it isn't aware of hardware
            # and just repeatedly mounts and polls status).
            description = "Import rpool before cryptsetup.target";
            # device dependencies allow us to avoid systemd-udev-settle.service
            # TODO: can I find a udev rule that creates a symlink based on `udevadm info --query env`?
            # it would be nice to not be dependent on hardware slot, but I guess they don't shuffle often
            wants = ["dev-nvme0n1p2.device"];
            after = ["dev-nvme0n1p2.device"];
            wantedBy = [
              "cryptsetup.target"
              ''dev-zvol-rpool-volumes-bootsecrets\x2dpart1.device''
            ];
            before = [
              "cryptsetup.target"
              "shutdown.target"
            ];
            conflicts = ["shutdown.target"];
            unitConfig.DefaultDependencies = "no";
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = "true";
            };
            script = ''
              ${lib.getExe' zfsPkg "zpool"} import -d ${devNodes} rpool
            '';
          };

          mask-bootsecrets = {
            description = "Clean up bootsecrets";
            after = ["zfs-import-rpool.service"];
            wantedBy = ["initrd-switch-root.target"];
            before = ["initrd-switch-root.target"];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              systemctl disable --now bootsecrets.mount
              systemctl mask bootsecrets.mount
            '';
          };

          mask-secretsroot = {
            description = "Clean up secretsroot";
            after = [
              "zfs-import-rpool.service"
              "mask-bootsecrets.service"
            ];
            wantedBy = ["initrd-switch-root.target"];
            before = ["initrd-switch-root.target"];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              systemctl disable --now systemd-cryptsetup@secretsroot.service
              systemctl mask systemd-cryptsetup@secretsroot.service
            '';
          };
        };
      };
    };
  };
}
