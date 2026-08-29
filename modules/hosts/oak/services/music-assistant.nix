{
  flake.modules.nixos.hosts-oak = {...}: {
    services = {
      music-assistant = {
        enable = true;
        openFirewall = true;
        providers = [
          "airplay"
          "airplay_receiver"
          "bandcamp"
          "coverartarchive"
          "fanarttv"
          "filesystem_local"
          "genius_lyrics"
          "ibroadcast"
          "itunes_artwork"
          "itunes_podcasts"
          "jellyfin"
          "local_audio"
          "loudness_analysis"
          "lrclib"
          "mpd"
          "musicbrainz"
          "radiobrowser"
          "sendspin"
          "sonos"
          "soundcloud"
          "sync_group"
          "theaudiodb"
          "universal_group"
          "universal_player"
          "vban_receiver"
          "wikipedia"
          "ytmusic"
        ];
      };
      nginx.virtualHosts."ma.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          proxyPass = "http://localhost:8095";
          proxyWebsockets = true;
        };
      };
    };

    environment.persistence."/persist".directories = [
      "/var/lib/private/music-assistant"
    ];
  };
}
