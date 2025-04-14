{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;

    theme.style = ''
      @define-color foreground #${config.lib.stylix.colors.base08};
      @define-color background #${config.lib.stylix.colors.base00};
      @define-color cursor #${config.lib.stylix.colors.base08};

      @define-color color0 #${config.lib.stylix.colors.base00};
      @define-color color1 #${config.lib.stylix.colors.base01};
      @define-color color2 #${config.lib.stylix.colors.base02};
      @define-color color3 #${config.lib.stylix.colors.base03};
      @define-color color4 #${config.lib.stylix.colors.base04};
      @define-color color5 #${config.lib.stylix.colors.base05};
      @define-color color6 #${config.lib.stylix.colors.base06};
      @define-color color7 #${config.lib.stylix.colors.base07};
      @define-color color8 #${config.lib.stylix.colors.base08};
      @define-color color9 #${config.lib.stylix.colors.base09};
      @define-color color10 #${config.lib.stylix.colors.base10};
      @define-color color11 #${config.lib.stylix.colors.base11};
      @define-color color12 #${config.lib.stylix.colors.base12};
      @define-color color13 #${config.lib.stylix.colors.base13};
      @define-color color14 #${config.lib.stylix.colors.base14};
      @define-color color15 #${config.lib.stylix.colors.base15};

      #window,
      #box,
      #aiScroll,
      #aiList,
      #search,
      #password,
      #input,
      #prompt,
      #clear,
      #typeahead,
      #list,
      child,
      scrollbar,
      slider,
      #item,
      #text,
      #label,
      #bar,
      #sub,
      #activationlabel {
        all: unset;
      }

      #cfgerr {
        background: rgba(255, 0, 0, 0.4);
        margin-top: 20px;
        padding: 8px;
        font-size: 1.2em;
      }

      #window {
        color: @foreground;
      }

      #box {
        border-radius: 2px;
        background: @background;
        padding: 64px;
        border: 1px solid lighter(@background);
        box-shadow:
          0 19px 38px rgba(0, 0, 0, 0.3),
          0 15px 12px rgba(0, 0, 0, 0.22);
      }

      #search {
        box-shadow:
          0 1px 3px rgba(0, 0, 0, 0.1),
          0 1px 2px rgba(0, 0, 0, 0.22);
        background: lighter(@background);
        padding: 8px;
      }

      #prompt {
        margin-left: 4px;
        margin-right: 12px;
        color: @foreground;
        opacity: 0.2;
      }

      #clear {
        color: @foreground;
        opacity: 0.8;
      }

      #password,
      #input,
      #typeahead {
        border-radius: 2px;
      }

      #input {
        background: none;
      }

      #password {
      }

      #spinner {
        padding: 8px;
      }

      #typeahead {
        color: @foreground;
        opacity: 0.8;
      }

      #input placeholder {
        opacity: 0.5;
      }

      #list {
      }

      child {
        padding: 8px;
      }

      child:selected #icon,
      child:hover #icon {
        background: alpha(@color1, 0.2);
      }

      #item {
      }

      #icon {
        padding: 10px;
        border-radius: 50%;
      }

      #text {
      }

      #label {
        font-weight: 500;
      }

      #sub {
        opacity: 0.5;
        font-size: 0.8em;
      }

      #activationlabel {
        opacity: 0;
      }

      #bar {
      }

      .barentry {
      }

      .activation #activationlabel {
        opacity: 1;
      }

      .activation #text,
      .activation #icon,
      .activation #search {
        opacity: 0.5;
      }

      .aiItem {
        padding: 10px;
        border-radius: 2px;
        color: @foreground;
        background: @background;
      }

      .aiItem.user {
        padding-left: 0;
        padding-right: 0;
      }

      .aiItem.assistant {
        background: lighter(@background);
      }
    '';
  };
}
