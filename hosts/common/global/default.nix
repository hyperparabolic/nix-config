{pkgs, ...}: let
  hyperparabolic-bootstrap = pkgs.writeShellApplication {
    name = "hyperparabolic-bootstrap";
    runtimeInputs = with pkgs; [
      rsync

      age
      ssh-to-age
      sops
      yq-go
    ];
    text = builtins.readFile ../../../scripts/hyperparabolic-bootstrap.sh;
  };
in {
  environment = {
    enableAllTerminfo = true;
    wordlist.enable = true;
    systemPackages = [
      hyperparabolic-bootstrap
    ];
  };

  services = {
    dbus.implementation = "broker";
    # firmware updates: `fwupdmgr update`
    fwupd.enable = true;
  };

  environment.persistence."/persist".directories = [
    "/var/lib/systemd"
    "/var/lib/nixos"
    "/var/log"
    "/srv"
  ];
}
