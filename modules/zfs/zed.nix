{
  flake.modules.nixos.zfs = {
    config,
    lib,
    ...
  }: {
    services.zfs = lib.mkIf config.hyperparabolic.ntfy-client.enable {
      zed = {
        # Bit of a misnomer I think? I believe this enables linux local mail
        # (think /var/spool/mail). zed will still send email with this false,
        # and does not require recompilation.
        enableMail = false;

        settings = {
          # value doesn't matter, not using email, just needs to not be null
          ZED_EMAIL_ADDR = ["root"];
          ZED_EMAIL_PROG = lib.getExe config.hyperparabolic.ntfy-client.package-notify;
          ZED_EMAIL_OPTS = "-";

          ZED_NOTIFY_INTERVAL_SECS = 3600;
          ZED_NOTIFY_VERBOSE = true;

          ZED_USE_ENCLOSURE_LEDS = true;
          ZED_SCRUB_AFTER_RESILVER = true;
        };
      };
    };
  };
}
