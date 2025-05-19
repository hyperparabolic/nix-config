{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    yubico-piv-tool
    yubioath-flutter
  ];

  services.pcscd.enable = true;
}
