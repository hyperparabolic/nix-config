{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
  };

  # bluetooth tui
  environment.systemPackages = with pkgs; [
    bluetuith
  ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/bluetooth"
    ];
  };
}
