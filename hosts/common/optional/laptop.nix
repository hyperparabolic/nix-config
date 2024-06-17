{pkgs, ...}: {
  services = {
    logind = {
      lidSwitchExternalPower = "lock";
      lidSwitchDocked = "ignore";
    };
    upower.enable = true;
  };

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
  ];

  # persist wifi connections
  environment.persistence = {
    "/persist".directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
