{
  config,
  pkgs,
  ...
}: {
  # https://nixos.wiki/wiki/Nvidia
  # system level config for nvidia graphics
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    graphics = {
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        egl-wayland
      ];
    };
  };

  # https://wiki.hyprland.org/Nvidia/
  # wayland / hyprland required kernel modules
  # some of these may be deftault already, expliticlt opting in
  # to avoid regressions
  boot.kernelModules = [
    "nvidia"
    "nvidia_drm"
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "nvidia_modeset"
    "nvidia_uvm"
  ];

  # hyprland session variables
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    WLR_NO_HARDWARE_CURSORS = "1";
    __GL_GSYNC_ALLOWED = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
