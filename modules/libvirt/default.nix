{
  flake.modules.nixos.libvirt = {...}: {
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

    environment.persistence."/persist".directories = ["/var/lib/libvirt/qemu"];
  };

  flake.modules.homeManager.libvirt = {pkgs, ...}: {
    home.packages = with pkgs; [
      virt-manager
    ];

    dconf.settings = {
      "org/virt-manager/virt-manager" = {
        xmleditor-enabled = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        uris = ["qemu:///system"];
        autoconnect = ["qemu:///system"];
      };
    };
  };
}
