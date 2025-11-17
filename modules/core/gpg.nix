{
  flake.modules.nixos.core = {...}: {
    services.pcscd.enable = true;
  };

  flake.modules.homeManager.core = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      enableSshSupport = true;
      enableFishIntegration = true;
      maxCacheTtl = 120;
      pinentry.package = lib.mkDefault pkgs.pinentry-curses;
      sshKeys = [
        "3E59A131928FD9DC54EA050B6B97EC8F3B199A2C"
      ];
    };

    programs = let
      launchGpg =
        /*
        bash
        */
        ''
          gpgconf --launch gpg-agent > /dev/null
          gpg --card-status > /dev/null
          export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        '';
    in {
      # ensure gpg is running and card aware in .bashrc / .zlogin, sometimes it isn't on ssh or boot.
      bash.profileExtra = launchGpg;
      fish.loginShellInit = launchGpg;

      gpg = {
        enable = true;
        publicKeys = [
          {
            source = ../../secrets/gpg-0x37CE23CFC62D8A49-2025-05-19.asc;
            trust = 5;
          }
        ];
        scdaemonSettings = {
          disable-ccid = true;
        };
        settings = {
          # mostly lifted from:
          # https://github.com/drduh/config/blob/master/gpg.conf
          # https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration-Options.html
          # https://www.gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html

          # Use AES256, 192, or 128 as cipher
          personal-cipher-preferences = "AES256 AES192 AES";
          # Use SHA512, 384, or 256 as digest
          personal-digest-preferences = "SHA512 SHA384 SHA256";
          # Use ZLIB, BZIP2, ZIP, or no compression
          personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
          # Default preferences for new keys
          default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
          # SHA512 as digest to sign keys
          cert-digest-algo = "SHA512";
          # SHA512 as digest for symmetric ops
          s2k-digest-algo = "SHA512";
          # AES256 as cipher for symmetric ops
          s2k-cipher-algo = "AES256";
          # UTF-8 support for compatibility
          charset = "utf-8";
          # Show Unix timestamps
          fixed-list-mode = true;
          # No comments in signature
          no-comments = true;
          # No version in output
          no-emit-version = true;
          # Disable banner
          no-greeting = true;
          # Long hexidecimal key format
          keyid-format = "0xlong";
          # Display UID validity
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
          # Display all keys and their fingerprints
          with-fingerprint = true;
          # Cross-certify subkeys are present and valid
          require-cross-certification = true;
          # Disable caching of passphrase for symmetrical ops
          no-symkey-cache = true;
          # Enable smartcard
          use-agent = true;
          # Disable recipient key ID in messages
          throw-keyids = true;
        };
      };
    };

    # link gpg socket to predictable location at ~/.gpupg-sockets
    # this makes ssh hosts config more resilient to user changes
    systemd.user.services = {
      link-gnupg-sockets = {
        Unit = {
          Description = "link gnupg sockets from /run to /home";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
          ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
          RemainAfterExit = true;
        };
        Install.WantedBy = ["default.target"];
      };
    };
  };
}
