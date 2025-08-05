{
  imports = [
    ../../common/optional/nginx.nix
    ./acme.nix
    ./grafana
    ./loki.nix
    ./mpd-spencer.nix
    ./prometheus.nix
  ];
}
