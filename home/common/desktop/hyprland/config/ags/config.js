import App from 'resource:///com/github/Aylur/ags/app.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

const workspaceIdToIconProps = {
  1: { icon: 'firefox-symbolic' },
  2: { icon: 'github', size: 16 },
  3: { icon: 'youtube-music-tray' },
  4: { icon: 'discord-tray' },
  5: { icon: 'distribute-randomize' },
  6: { icon: 'vlc-panel' },
  7: { icon: 'notes-panel' },
  8: { icon: 'utilities-system-monitor-symbolic' },
};

const Workspaces = () => Widget.Box({
  class_name: 'workspaces',
  vertical: true,
  children: Hyprland.bind('workspaces').transform(ws => {
    return ws.sort((a,b) => a.id - b.id)
    .map(({ id }) => Widget.Button({
      on_clicked: () => Hyprland.sendMessage(`dispatch workspace ${id}`),
      child: Widget.Icon(workspaceIdToIconProps[id]),
      class_name: Hyprland.active.workspace.bind('id')
        .transform(i => `${i === id ? 'focused' : ''}`),
    }));
  }),
});

const Clock = () => Widget.Label({
  class_name: 'clock logical-grouping',
  justification: 'center',
  setup: self => self
    .poll(1000, self => execAsync(['date', '+%H\n%M'])
    // .poll(1000, self => execAsync(['date', '+%H\n%M\n%a\n%m\n%d'])
      .then(date => self.label = date)),
});

const Media = () => Widget.Button({
  class_name: 'media',
  on_primary_click: () => Mpris.getPlayer('')?.playPause(),
  on_scroll_up: () => Mpris.getPlayer('')?.next(),
  on_scroll_down: () => Mpris.getPlayer('')?.previous(),
  child: Widget.Label('-').hook(Mpris, self => {
    if (Mpris.players[0]) {
      const { track_artists, track_title } = Mpris.players[0];
      self.label = `${track_artists.join(', ')} - ${track_title}`;
    } else {
      self.label = 'Nothing is playing';
    }
  }, 'player-changed'),
});

const openVolumeSlider = Variable(false);
const Volume = () => Widget.EventBox({
  on_hover: () => openVolumeSlider.value = true,
  on_hover_lost: () => openVolumeSlider.value = false,
  child: Widget.Box({
    class_name: 'volume',
    vertical: true,
    children: [
      Widget.Revealer({
        reveal_child: false,
        transition_duration: 500,
        transition: 'slide_up',
        child: Widget.Slider({
          class_name: 'volume-slider',
          hexpand: true,
          vertical: true,
          inverted: true,
          draw_value: false,
          on_change: ({ value }) => Audio.speaker.volume = value,
          setup: self => self.hook(Audio, () => {
            self.value = Audio.speaker?.volume || 0;
          }, 'speaker-changed'),
        }),
        setup: self => self.bind('label', openVolumeSlider, 'value', v => self.reveal_child = v),
      }),
      Widget.Button({
        on_primary_click: () => Audio.speaker['is-muted'] = !Audio.speaker['is-muted'],
        child: Widget.Icon().hook(Audio, self => {
          if (!Audio.speaker)
            return;

          const category = {
            101: 'overamplified',
            67: 'high',
            34: 'medium',
            1: 'low',
            0: 'muted',
          };

          const icon = Audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= Audio.speaker.volume * 100);

          self.icon = `audio-volume-${category[icon]}-symbolic`;
        }, 'speaker-changed'),
      })
    ],
  }),
});

const Power = () => Widget.Button({
  class_name: 'power',
  // just a placeholder for now, expand to power menu on click
  child: Widget.Icon({
    icon: 'system-shutdown-symbolic',
  }),
});


// layout of the bar
const Top = () => Widget.Box({
  class_name: 'bar-segment',
  vertical: true,
  vpack: 'start',
  spacing: 8,
  children: [
    Workspaces(),
  ],
});

const Center = () => Widget.Box({
  class_name: 'bar-segment',
  spacing: 8,
  vertical: true,
  children: [
  ],
});

const Bottom = () => Widget.Box({
  class_name: 'bar-segment',
  vertical: true,
  vpack: 'end',
  spacing: 8,
  children: [
    Volume(openVolumeSlider),
    Clock(),
    Power(),
  ],
});

const Bar = (monitor = 0) => Widget.Window({
  name: `bar-${monitor}`, // name has to be unique
  class_name: 'bar',
  monitor,
  anchor: ['top', 'right', 'bottom'],
  exclusivity: 'exclusive',
  child: Widget.CenterBox({
    class_name: 'center-bar',
    vertical: true,
    start_widget: Top(),
    // center_widget: Center(),
    end_widget: Bottom(),
  }),
});

export default {
  style: App.configDir + '/style.css',
  windows: [
    Bar(0),
  ],
};
