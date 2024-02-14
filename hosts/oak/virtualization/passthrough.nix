{ pkgs, lib, config, ... }:
let
  pciIds = [
    # 3090 graphics
    "10de:2204"
    # 3090 audio
    "10de:1aef"
    # nvme drive
    "144d:a804"
  ];
in
{
  /*
    PCI devices specified in pciIds get stubbed with the vfio_pci driver,
    preventing linux from loading its drivers. This ensures they are "clean"
    when they get passed through to a VM and behave well there. This is
    mostly only necessary for GPUs.
  */
  environment.systemPackages = with pkgs; [
    pciutils # pci querying tooling
    usbutils # usb querying tooling
  ];

  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelParams = [
      "amd_iommu=on"
      ("vfio-pci.ids=" + lib.concatStringsSep "," pciIds)
    ];
  };

  # vm utilizes pipewire to share system audio, initialize dummy sink / source
  services.pipewire = {
    # use system level pipewire service to share audio devices between users
    systemWide = true;
    extraConfig.pipewire = {
      "10-vm-shared-audio" = {
        "context.objects" = [
          # initialize null sources / sinks
          {
            "factory" = "adapter";
            "args" = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "win10-out";
              "media.class" = "Audio/Sink";
              "linger" = true;
              "audio.position" = [ "FL" "FR" ];
            };
          }
          {
            "factory" = "adapter";
            "args" = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "win10-in";
              "media.class" = "Audio/Source/Virtual";
              "linger" = true;
              "audio.position" = [ "FL" "FR" ];
            };
          }
        ];
      };
    };
  };

  # links cannot be created directly, create using oneshot service
  systemd.services.pipewire-link-vm-audio = {
    description = "Create pipewire links between null devices and hardware";
    enable = true;
    wantedBy = [ "multi-user.target" ];
    partOf = [ "pipewire.service" ];
    after = [ "pipewire.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = lib.getExe (
        # ensure links are not already created
        pkgs.writeShellScriptBin "pw-check-win-links" ''
          ! ${config.services.pipewire.package}/bin/pw-link -l | grep 'win'
        ''
      );
      ExecStart = lib.getExe (
        pkgs.writeShellScriptBin "pw-create-win-links" ''
          ${config.services.pipewire.package}/bin/pw-link "win10-out:monitor_FL" "alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:playback_FL"
          ${config.services.pipewire.package}/bin/pw-link "win10-out:monitor_FR" "alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:playback_FR"
          ${config.services.pipewire.package}/bin/pw-link "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:capture_FL" "win10-in:input_FL"
          ${config.services.pipewire.package}/bin/pw-link "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:capture_FR" "win10-in:input_FR"
        ''
      );
      # alsa devices take a moment to settle, retry until success
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
