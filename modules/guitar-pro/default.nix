{
  /*
  Guitar pro with mimetype and .desktop file.

  This requires some out of band setup. You can't download the installer
  for this without signing in to their website, so there isn't a reasonable
  way to script this up.

  Utilizes bottles for the windows compatibility layer.

  setup:
  bottles-cli new --environment application --bottle-name guitarpro
  bottles-cli run -b guitarpro -e ~/Downloads/guitar-pro-8-setup.exe

  Default fonts look off. Looks better if you just remove the fonts that
  get installed with the application environment:
  rm ~/.local/share/bottles/bottles/guitarpro/drive_c/windows/Fonts/*

  Everything else is good, so this is much easier than making a custom
  environment.
  */
  flake.modules.homeManager.guitar-pro = {
    config,
    lib,
    pkgs,
    ...
  }: let
    gp-arg-wrap = pkgs.writeShellApplication {
      name = "gp-arg-wrap";
      text =
        /*
        bash
        */
        ''
          # This seems to handle reasonable files. If something
          # doesn't work, rename it to something sane.
          convert_path() {
            local uri="$1"

            # Strip file:// if present
            uri="''${uri#file://}"

            # Replace / with \ and prepend Z:
            local win_path="Z:''${uri}"
            echo "''${win_path//\//\\}"  # Replace all / with \
          }

          # Convert and wrap each arg in quotes
          converted_args=()
          for arg in "$@"; do
            path="$(convert_path "$arg")"
            converted_args+=("\"$path\"")
          done

          # Join into a single string
          args_string="''${converted_args[*]}"

          # Run via Bottles
          if [ "$args_string" = "" ];
          then
            # no args, just run how you'd intuitively expect
            bottles-cli run -b guitarpro -p GuitarPro
          else
            # I can't for the life of me figure out how to pass a file
            # arg to the gp executable, but directly opening a file from
            # the wine shell seems to figure out the right executable
            # though.
            bottles-cli shell -b guitarpro -i "$args_string"
          fi
        '';
    };
  in {
    home.packages = with pkgs; [
      bottles
      gp-arg-wrap
    ];

    programs.yazi.settings = lib.mkIf config.programs.yazi.enable {
      opener = {
        guitarpro = [
          {
            desc = "Guitar Pro";
            run = "gp-arg-wrap %S";
            orphan = true;
          }
        ];
      };
      open = {
        prepend_rules = [
          {
            url = "*.gpx";
            use = "guitarpro";
          }
          {
            url = "*.gp";
            use = "guitarpro";
          }
        ];
      };
    };

    xdg = {
      dataFile = {
        # may require `update-mime-database ~/.local/share/mime`
        "mime/packages/guitar-pro.xml" = {
          onChange = "update-mime-database ${config.home.homeDirectory}/.local/share/mime";
          text = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
              <mime-type type="application/x-gtp">
                <comment>Guitar Pro file</comment>
                <glob pattern="*.gtp"/>
                <glob pattern="*.gp3"/>
                <glob pattern="*.gp4"/>
                <glob pattern="*.gp5"/>
                <icon name="emblem-music-symbolic"/>
              </mime-type>
              <mime-type type="application/x-gtp">
                <comment>Guitar Pro file</comment>
                <!-- The file extension gpx is also used for GPX geographic data. Guitar Pro gpx files always begin with "BCFZ" -->
                <magic priority="50">
                  <match value="BCFZ\004" type="string" offset="0" />
                </magic>
                <glob pattern="*.gpx"/>
                <icon name="emblem-music-symbolic"/>
              </mime-type>
              <mime-type type="application/x-gtp">
              <comment>Guitar Pro file</comment>
                <!-- The file extension gp is also used for Gnuplot ASCII data. Guitar Pro gp files are ZIP archives -->
                <sub-class-of type="application/zip"/>
                <glob pattern="*.gp"/>
                <icon name="emblem-music-symbolic"/>
              </mime-type>
            </mime-info>
          '';
        };
      };

      desktopEntries = {
        guitar-pro = {
          name = "GuitarPro";
          exec = "gp-arg-wrap %u";
          terminal = false;
          type = "Application";
          categories = ["Music"];
          mimeType = ["application/x-gtp"];
        };
      };

      mimeApps = {
        associations.added = {
          "application/x-gtp" = "guitar-pro.desktop";
        };
        defaultApplications = {
          "application/x-gtp" = "guitar-pro.desktop";
        };
      };
    };

    home.persistence."/persist".directories = [".local/share/bottles"];
  };
}
