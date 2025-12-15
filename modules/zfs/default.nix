{
  flake.modules.nixos.zfs = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.this.zfs;
      devNodes = config.boot.zfs.devNodes;
      zfsPkg = config.boot.zfs.package;

      # get latest zfs compatible kernel
      latestZfsCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
        builtins.attrValues
        (builtins.filter (
          # fitler packages where
          kPkgs:
          # packages do not throw or assert errors
            (builtins.tryEval kPkgs).success
            # package is a kernel package
            && kPkgs ? kernel
            && kPkgs.kernel.pname == "linux"
            # zfs metadata indicates kernel version is compatible with zfs
            && !kPkgs.${pkgs.zfs.kernelModuleAttribute}.meta.broken
        ))
        # sort oldest -> newest
        (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
        # get last element (newest)
        lib.last
      ];
    in {
      # This implements an opinionated ZFS structure, luksOnZfs. Custom mounting
      # services decrypt a self contained LUKS volume containing native ZFS encryption
      # key files.
      options.this.zfs = {
        autoSnapshot = mkOption {
          type = types.bool;
          default = true;
          example = false;
        };
        backingDevices = mkOption {
          type = types.listOf types.str;
          default = [];
          example = ["dev-nvme0n1p2.device"];
          description = mdDoc ''
            Names of the systemd .device units that back the rpool. These
            units are automatically generated for devices based on their
            names assigned by udev.
          '';
        };
      };

      config = mkMerge [
        # base config
        {
          environment.systemPackages = with pkgs; [
            sanoid
          ];
          boot = {
            kernelPackages = lib.mkDefault latestZfsCompatibleLinuxPackages;
            supportedFilesystems = ["zfs"];

            zfs = {
              # default, but keep even if default changes
              allowHibernation = false;
              # does not play nicely with old systems, may require zfs_force=1 kernel parameter
              forceImportRoot = false;
            };
          };

          services.zfs = {
            autoScrub.enable = true;
            trim.enable = true;
            autoSnapshot = mkIf (cfg.autoSnapshot) {
              enable = true;
              frequent = 12;
              hourly = 24;
              daily = 3;
              weekly = 4;
              monthly = 6;
              flags = "-k -p --utc";
            };
          };
        }

        # luksOnZfs mounting services
        {
          boot.initrd = {
            # /bootsecrets is an ext4 filesystem
            supportedFilesystems = ["ext4"];

            # creates systemd-cryptsetup@secretsroot
            luks.devices.secretsroot = {
              crypttabExtraOpts = ["nofail" "noauto" "readonly" "x-initrd.attach"];
              device = "/dev/zvol/rpool/volumes/bootsecrets-part1";
            };
            systemd = {
              enable = lib.mkForce true;
              mounts = [
                {
                  # fileSystems.<name> doesn't really support mounting files in initrd that aren't
                  # intended for the booted os, so creating this manually.
                  description = "Secrets storage for stage 1 boot";
                  where = "/bootsecrets";
                  what = "/dev/mapper/secretsroot";
                  options = "nofail,noauto,noexec,ro,x-initrd.mount";
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
                  wants = cfg.backingDevices;
                  after = cfg.backingDevices;
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
              };
            };
          };
          systemd.services = {
            stop-secretsroot = {
              description = "Clean up secretsroot";
              wantedBy = ["sysinit.target"];
              before = ["sysinit.target"];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                systemd-cryptsetup detach secretsroot
              '';
            };
          };
        }
      ];
    };
}
