{
  flake.modules.nixos.hosts-oak = {
    pkgs,
    lib,
    ...
  }: let
    llama-server = lib.getExe' pkgs.llama-cpp "llama-server";
    port = 55262;
    # generate cmd, mapping attribute set to CLI flags
    server-attr-flags = attr-args: "${llama-server} --port ''\${PORT} ${
      attr-args
      |> lib.mapAttrs (arg: value: "--${arg} ${value}")
      |> lib.attrValues
      |> lib.strings.join " "
    }";
  in {
    environment.systemPackages = with pkgs; [
      llama-cpp
    ];

    users = {
      groups.llama-swap = {};
      users.llama-swap = {
        isSystemUser = true;
        group = "llama-swap";
      };
    };

    services = {
      llama-swap = {
        inherit port;
        enable = true;
        settings = {
          healthCheckTimeout = 28800;
          ttl = 300;
          models = {
            "gemma-4:31b-q4" = {
              cmd = server-attr-flags {
                hf-repo = "unsloth/gemma-4-31B-it-GGUF:UD-Q4_K_XL";
                n-gpu-layers = "48";
                parallel = "1";
                threads = "8";
                flash-attn = "on";
                cache-type-k = "q8_0";
                cache-type-v = "q8_0";
                temperature = "1.0";
                top-p = "0.95";
                top-k = "64";
              };
            };
            "qwen3.6:27b-q4" = {
              cmd = server-attr-flags {
                hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF";
                n-gpu-layers = "48";
                parallel = "1";
                threads = "8";
                flash-attn = "on";
                cache-type-k = "q8_0";
                cache-type-v = "q8_0";
                temperature = "1.0";
                top-p = "0.95";
                top-k = "20";
                min-p = "0.00";
                chat-template-kwargs = "'{\"preserve_thinking\":true}'";
              };
            };
          };
        };
      };
      nginx.virtualHosts."llm.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          # port gets configured via web ui during setup
          proxyPass = "http://localhost:${toString port}";
        };
      };
    };

    systemd.services.llama-swap = {
      environment.XDG_CACHE_HOME = "/var/cache/llama-swap";
      serviceConfig.CacheDirectory = "llama-swap";
    };

    environment.persistence."/persist".directories = ["/var/cache/private/llama-swap"];
  };
}
