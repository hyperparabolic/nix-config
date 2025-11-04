{
  flake.modules.nixos.zfs = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      impermanenceRollbackSnapshot = "rpool/crypt/local/root@blank";

      cfg = config.this.zfs;
      devNodes = config.boot.zfs.devNodes;
      enableImpermanenceRollback = config.this.impermanence.enableRollback;
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
        zedMailTo = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "me@example.com";
          description = mdDoc ''
            Mail recipient for zed mail notifications. Even if your program is
            not an email requirement this is required, as zed will not send send
            mail notifications without it being configured. Leave null to skip
            mail notifications.
          '';
        };
        zedMailCommand = mkOption {
          type = types.str;
          default = "mail";
          example = "mail";
          description = mdDoc ''
            Executable zed will use to send zfs health notifications.
            This executable must accept input from stdin.
          '';
        };
        zedMailCommandOptions = mkOption {
          type = types.str;
          default = "";
          example = "'@SUBJECT@' @ADDRESS@";
          description = mdDoc ''
            CLI args for the zedMailCommand.
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

        (mkIf enableImpermanenceRollback {
          # rollback root fs to blank snapshot
          boot.initrd.systemd = {
            enable = lib.mkForce true;
            services.zfs-rollback = {
              description = "Rollback ZFS root dataset to blank snapshot";
              wantedBy = [
                "initrd.target"
              ];
              after = [
                "zfs-import-rpool.service"
              ];
              before = [
                "sysroot.mount"
              ];
              path = with pkgs; [
                zfs
              ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                zfs rollback -r ${impermanenceRollbackSnapshot} && echo "zfs rollback complete"
              '';
            };
          };
        })

        (mkIf (cfg.zedMailTo != null) {
          services.zfs = {
            zed = {
              # Bit of a misnomer I think? I believe this enables linux local mail
              # (think /var/spool/mail). zed will still send email with this false,
              # and does not require recompilation.
              enableMail = false;

              settings = {
                ZED_DEBUG_LOG = "/tmp/zed.debug.log";
                ZED_EMAIL_ADDR = [cfg.zedMailTo];
                ZED_EMAIL_PROG = cfg.zedMailCommand;
                ZED_EMAIL_OPTS = cfg.zedMailCommandOptions;

                ZED_NOTIFY_INTERVAL_SECS = 3600;
                ZED_NOTIFY_VERBOSE = true;

                ZED_USE_ENCLOSURE_LEDS = true;
                ZED_SCRUB_AFTER_RESILVER = true;
              };
            };
          };
        })

        # mounting services
        {
          boot.initrd = {
            # /bootsecrets is an ext4 filesystem
            supportedFilesystems = ["ext4"];

            # creates systemd-cryptsetup@secretsroot
            luks.devices.secretsroot.device = "/dev/zvol/rpool/volumes/bootsecrets-part1";
            systemd = {
              enable = lib.mkForce true;
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
                    systemd-cryptsetup detach secretsroot
                    systemctl mask systemd-cryptsetup@secretsroot.service
                  '';
                };
              };
            };
          };
        }
      ];
    };
}
