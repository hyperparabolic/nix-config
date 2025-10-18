{
  flake.modules.nixos.core = {lib, ...}: {
    time.timeZone = lib.mkDefault "America/Chicago";
  };
}
