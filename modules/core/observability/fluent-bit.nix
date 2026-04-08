{
  flake.modules.nixos.core = {...}: {
    services.fluent-bit = {
      enable = true;
      settings = {
        pipeline = {
          inputs = [
            {
              name = "systemd";
            }
          ];
          outputs = [
            {
              name = "loki";
              match = "*";

              host = "logs.redbud.decent.id";
              uri = "/loki/api/v1/push";
              port = 443;
              tls = true;

              labels = "job=fluentbit";
              label_keys = "$sub['stream']";
            }
          ];
        };
      };
    };
  };
}
