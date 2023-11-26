
self:
let
  enableWayland = drv: bin: drv.overrideAttrs (
    old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ self.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/${bin} \
          --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations" \
          --add-flags "--ozone-platform=wayland"
      '';
    }
  );
in
super:
  {
    slack = enableWayland super.slack "slack";
    discord = enableWayland super.discord "discord";
    vscode = enableWayland super.vscode "code";
  }
