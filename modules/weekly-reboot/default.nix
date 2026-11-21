{
  flake.modules.nixos.weekly-reboot = {pkgs, ...}: {
    # Gradient-pull deployments run `nixos-rebuild switch`, which never
    # reboots, so kernel upgrades are only adopted after a reboot.
    # Each deployment advances /nix/var/nix/profiles/system; when it is
    # ahead of /run/booted-system, a reboot switches to the new generation.
    systemd.services.weekly-reboot = {
      description = "Reboot to pending NixOS generation";
      serviceConfig.Type = "oneshot";
      path = with pkgs; [
        coreutils
        util-linux
      ];
      script = ''
        pending="$(readlink -f /nix/var/nix/profiles/system)"
        booted="$(readlink -f /run/booted-system)"
        if [ -e "$pending" ] && [ -e "$booted" ] && [ "$pending" != "$booted" ]; then
          echo "pending NixOS generation: $pending (booted: $booted), rebooting"
          reboot
        else
          echo "no pending NixOS generation, skipping reboot"
        fi
      '';
    };

    systemd.timers.weekly-reboot = {
      description = "Weekly reboot to pending NixOS generation";
      wantedBy = ["timers.target"];
      timerConfig = {
        # Randomly stagger Sunday reboots across 3:30-4:30, Chicago time.
        OnCalendar = "TZ=America/Chicago Sun *-*-* 03:30:00";
        RandomizedDelaySec = "3600";
        # Catch up if a host was down when the timer was due.
        Persistent = true;
      };
    };
  };
}
