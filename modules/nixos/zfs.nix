{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hyperparabolic.base.zfs;
in {
  /*
  Base system configuration for zfs. I don't want to duplicate this config
  for every machine, but I can already see places I will change it on other
  machines (not every machine needs encryption, libnotify is enough for some
  machines but some are too tucked away, some machines don't have enough state
  to care about snapshots, etc.).

  This plays nicely with systemdboot, boot drives that are NOT zfs, but does
  support a zfs root filesystem supporting ephemeral root.

  This does not recompile zed with mail support, so the provided zedMailCommand
  must be sufficient without that.
  */

  options.hyperparabolic.base.zfs = {
    enable = mkEnableOption "Enable zfs";
    autoSnapshot = mkOption {
      type = types.bool;
      default = true;
      example = false;
    };
    rollbackSnapshot = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "rpool/local/root@empty";
      description = mdDoc ''
        Empty zfs root filesystem dataset@snapshot. If provided, this will
        rollback to that snapshot on boot.
        See grahamc "Erase your darlings".
        Leave this null if you aren't comfy with the idea of an ephemeral
        filesystem from that.
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

  config = mkIf cfg.enable (mkMerge [
    {
      boot = {
        # use latest kernel packages that are compatible with ZFS
        kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
        supportedFilesystems = ["zfs"];

        # does not play nicely with old systems, may require zfs_force=1 kernel parameter
        zfs.forceImportRoot = false;

        # rollback root fs to blank snapshot
        initrd.postDeviceCommands = mkIf (cfg.enable && cfg.rollbackSnapshot != null) (mkAfter ''
          zfs rollback -r ${cfg.rollbackSnapshot}
        '');
      };

      services.zfs = {
        autoScrub.enable = true;
        trim.enable = true;
        autoSnapshot = mkIf (cfg.enable && cfg.autoSnapshot) {
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

    (mkIf (cfg.enable && cfg.zedMailTo != null) {
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
  ]);
}
