{
  flake.modules.nixos.fingerprint = {...}: {
    services.fprintd.enable = true;

    # an older version is needed specifically for downgrading the fingerprint sensor
    # all set up with fingers enrolled now, shouldn't be needed, but here for documentation
    # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd#getting-the-fingerprint-sensor-to-work
    # services.fwupd.package = (import (builtins.fetchTarball {
    #   url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
    #   sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
    # }) {
    #   inherit (pkgs) system;
    # }).fwupd;

    environment.persistence."/persist".directories = ["/var/lib/fprint"];
  };
}
