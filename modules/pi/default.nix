{
  flake.modules.homeManager.pi = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.this.pi;
  in {
    options.this.pi = {
      sandbox = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the sandbox extensions, context, and skills.";
      };
    };

    config = {
      home.packages = with pkgs; [
        # gondolin image build deps
        cpio
        lz4
        e2fsprogs
      ];

      programs.pi-coding-agent = {
        enable = true;
        extraPackages = with pkgs; [
          (python3.withPackages (ps:
            with ps; [
              html2text
            ]))
        ];
        models = {
          providers = {
            llama-swap = {
              baseUrl = "https://llm.oak.decent.id/v1";
              api = "openai-responses";
              apiKey = "dummy";
              models = [
                {id = "qwen3.8:27b-q4";}
                {id = "deepseek/deepseek-v4-flash-0731";}
                {id = "minimax/minimax-m3:free";}
                {id = "nvidia/nemotron-3-ultra-550b-a55b:free";}
                {id = "xiaomi/mimo-v2.5";}
                {id = "z-ai/glm-5.3-flash";}
              ];
            };
          };
        };
        settings = {
          defaultModel = "llama-swap/qwen3.8:27b-q4";
          enabledModels = [
            "llama-swap/deepseek/deepseek-v4.1-flash"
            "llama-swap/openai/gpt-6-luna"
            "llama-swap/stealth/space-bunny-alpha"
            "llama-swap/xiaomi/mimo-v2.6-flash"
            "llama-swap/z-ai/glm-5.3-flash"
          ];

          skills = [./skills];

          extensions =
            [
              (pkgs.buildNpmPackage {
                pname = "pi-extensions-main";
                version = "unstable";
                src = ./extensions/main;
                npmDepsHash = "sha256-5eMwGOLbqUyRWxOwZ8tZ2uFabE8y1fs3X4f7HTd2+9w=";
                dontNpmBuild = true;
                installPhase = ''
                  mkdir -p $out
                  cp -r . $out
                '';
              })
            ]
            ++ lib.optionals cfg.sandbox [
              (pkgs.buildNpmPackage {
                pname = "pi-extensions-sandbox";
                version = "unstable";
                src = ./extensions/sandbox;
                npmDepsHash = "sha256-5eMwGOLbqUyRWxOwZ8tZ2uFabE8y1fs3X4f7HTd2+9w=";
                dontNpmBuild = true;
                installPhase = ''
                  mkdir -p $out
                  cp -r . $out
                '';
              })
            ];
        };
      };
    };
  };
}
