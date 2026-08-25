{
  flake.modules.homeManager.pi = {pkgs, ...}: let
  in {
    home.packages = with pkgs; [
      # gondolin image build deps
      cpio
      lz4
      e2fsprogs
    ];

    programs.pi-coding-agent = {
      enable = true;
      extraPackages = [
      ];
      context = ./context.md;
      models = {
        providers = {
          llama-swap = {
            baseUrl = "https://llm.oak.decent.id/v1";
            api = "openai-responses";
            apiKey = "dummy";
            models = [
              {id = "gemma-4:31b-q4";}
              {id = "qwen3.6:27b-q4";}
              {id = "deepseek/deepseek-v4-flash";}
              {id = "nvidia/nemotron-3-ultra-550b-a55b:free";}
              {id = "stealth/ox-alpha";}
              {id = "tencent/hy3";}
              {id = "xiaomi/mimo-v2.5";}
            ];
          };
        };
      };
      settings = {
        defaultModel = "llama-swap/nvidia/nemotron-3-ultra-550b-a55b:free";
        enabledModels = [
          "llama-swap/gemma-4:31b-q4"
          "llama-swap/qwen3.6:27b-q4"
          "llama-swap/deepseek/deepseek-v4-flash"
          "llama-swap/nvidia/nemotron-3-ultra-550b-a55b:free"
          "llama-swap/stealth/ox-alpha"
          "llama-swap/tencent/hy3"
          "llama-swap/xiaomi/mimo-v2.5"
        ];

        skills = [./skills];

        extensions = [
          (pkgs.buildNpmPackage {
            pname = "pi-extensions";
            version = "unstable";
            src = ./extensions;
            # npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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
}
