{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    yubico-piv-tool
    yubioath-flutter
  ];

  services.pcscd.enable = true;
}
