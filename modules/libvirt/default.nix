{pkgs, ...}: {
  # This will have to be made a module if I start running VMs
  # on an intel host, too. Fine for now.
  boot.kernelModules = ["kvm-amd"];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      # software TPM for guests
      swtpm.enable = true;
    };
  };

  # polkit is used for libvirt permissions
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  environment.persistence."/persist".directories = ["/var/lib/libvirt/qemu"];
}
