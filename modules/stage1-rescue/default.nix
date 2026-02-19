{
  flake.modules.nixos.stage1-rescue = {...}: {
    # systemd stage1, force system into rescue mode for debugging
    boot = {
      initrd.systemd.emergencyAccess = true;
      kernelParams = ["rd.systemd.unit=rescue.target"];
    };
  };
}
