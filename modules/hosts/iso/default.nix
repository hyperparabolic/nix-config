{
  flake.modules.nixos.hosts-iso = {
    lib,
    pkgs,
    ...
  }: let
    hyperparabolic-export = pkgs.writeShellApplication {
      name = "hyperparabolic-export";
      runtimeInputs = [];
      text = builtins.readFile ../../scripts/hyperparabolic-export.sh;
    };
    hyperparabolic-import = pkgs.writeShellApplication {
      name = "hyperparabolic-import";
      runtimeInputs = [];
      text = builtins.readFile ../../scripts/hyperparabolic-import.sh;
    };
    hyperparabolic-install = pkgs.writeShellApplication {
      name = "hyperparabolic-install";
      runtimeInputs = [
        hyperparabolic-export
      ];
      text = builtins.readFile ../../scripts/hyperparabolic-install.sh;
    };
  in {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    isoImage = {
      makeEfiBootable = true;
      makeUsbBootable = true;
      squashfsCompression = "zstd -Xcompression-level 3";
    };

    systemd = {
      services.sshd.wantedBy = lib.mkForce ["multi-user.target"];
      targets = {
        sleep.enable = false;
        suspend.enable = false;
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };
    };

    users.users.spencer = {
      # This is fine. Only included for sudo operations, and is not included
      # in final install.  Still requires physical access or yubikey during
      # install
      initialPassword = "bootstrap";
      # initialPassword is higher priority, but unset this anyway just to be
      # sure that sops secrets are not required.
      hashedPasswordFile = lib.mkForce null;
    };

    services.getty.autologinUser = lib.mkForce "spencer";

    networking = {
      hostName = "iso";
      nameservers = [
        "192.168.1.1"
      ];
      wireless.enable = false;
    };
    services.resolved.fallbackDns = ["9.9.9.9" "2620:fe::fe"];

    environment.systemPackages = with pkgs; [
      hyperparabolic-export
      hyperparabolic-import
      hyperparabolic-install

      age
      gnupg
      sops
      ssh-to-age
      yq-go
      sbctl
      sanoid
    ];
  };
}
