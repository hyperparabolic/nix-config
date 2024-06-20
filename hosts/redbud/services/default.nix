{
  imports = [
    ../../common/optional/nginx.nix
    ./acme.nix
    ./grafana
    ./loki.nix
    ./prometheus.nix
  ];
}
