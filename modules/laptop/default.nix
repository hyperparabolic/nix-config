{
  flake.modules.nixos.laptop = {pkgs, ...}: {
    services = {
      logind.settings.Login = {
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
        HandlePowerKey = "suspend";
      };
      upower.enable = true;
    };

    environment.systemPackages = with pkgs; [
      acpi
      brightnessctl
    ];

    environment.persistence."/persist".directories = ["/etc/NetworkManager/system-connections"];
  };
}
