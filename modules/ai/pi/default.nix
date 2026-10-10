{
  flake.modules.homeManager.ai-pi = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.this.pi;
    llamaSwapModels = [
      # Locally hosted first, so defaultModel lands on one.
      "qwen3.8:27b-q4"
      "deepseek/deepseek-v4.1-flash"
      "openai/gpt-6-luna"
      "stealth/space-bunny-alpha"
      "xiaomi/mimo-v2.6-flash"
      "z-ai/glm-5.3-flash"
    ];
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
              models = llamaSwapModels |> map (id: {inherit id;});
            };
          };
        };
        settings = {
          defaultModel = "llama-swap/${builtins.head llamaSwapModels}";
          enabledModels = llamaSwapModels |> map (id: "llama-swap/${id}");

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
