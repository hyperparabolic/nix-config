{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = let
    qrencode = lib.getExe pkgs.qrencode;
    wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
    wlPaste = lib.getExe' pkgs.wl-clipboard "wl-paste";
    zbarimg = lib.getExe' pkgs.zbar "zbarimg";
  in [
    # helpers for encoding and decoding otp qrs from clipboard for backup
    (pkgs.writeShellScriptBin "otpauth-decode-clipboard" ''
      ${wlPaste} | ${zbarimg} -q --raw -
      ${wlCopy} --clear
    '')
    (pkgs.writeShellScriptBin "otpauth-encode-clipboard" ''
      ${wlPaste} | ${qrencode} -m 2 -t utf8
      ${wlCopy} --clear
    '')
  ];
  programs.password-store = {
    enable = true;
    package = pkgs.pass;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      PASSWORD_STORE_KEY = "37CE23CFC62D8A49";
    };
  };

  home.persistence."/persist".directories = [".password-store"];
}
