import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

class BrightnessService extends Service {
  // every subclass of GObject.Object has to register itself
  static {
    // takes three arguments
    // the class itself
    // an object defining the signals
    // an object defining its properties
    Service.register(
      this,
      {
        // 'name-of-signal': [type as a string from GObject.TYPE_<type>],
        'screen-changed': ['float'],
      },
      {
        // 'kebab-cased-name': [type as a string from GObject.TYPE_<type>, 'r' | 'w' | 'rw']
        // 'r' means readable
        // 'w' means writable
        // guess what 'rw' means
        'available': ['boolean', 'r'],
        'screen-value': ['float', 'rw'],
      },
    );
  }

  // this Service assumes only one device with backlight
  #interface = Utils.exec("sh -c 'ls -w1 /sys/class/backlight | head -1'");

  // # prefix means private in JS
  #screenValue = 0;
  #available = !Utils.exec('which brightnessctl').startsWith('which: no brightnessctl in');
  #max = this.#available ? Number(Utils.exec('brightnessctl max')) : 0;

  get available() {
    return this.#available;
  }

  // the getter has to be in snake_case
  get screen_value() {
    return this.#screenValue;
  }

  // the setter has to be in snake_case too
  set screen_value(percent) {
    if (!this.#available) {
      return;
    }

    if (percent < 0)
        percent = 0;

    if (percent > 1)
        percent = 1;

    Utils.execAsync(`brightnessctl set ${percent * 100}% -q`);
    // the file monitor will handle the rest
  }

  constructor() {
    super();

    // setup monitor
    const brightness = `/sys/class/backlight/${this.#interface}/brightness`;
    Utils.monitorFile(brightness, () => this.#onChange());

    // initialize
    this.#onChange();
  }

  #onChange() {
    if (!this.#available) {
      return;
    }

    this.#screenValue = Number(Utils.exec('brightnessctl get')) / this.#max;

    // signals have to be explicity emitted
    this.emit('changed'); // emits "changed"
    this.notify('screen-value'); // emits "notify::screen-value"

    // or use Service.changed(propName: string) which does the above two
    // this.changed('screen-value');

    // emit screen-changed with the percent as a parameter
    this.emit('screen-changed', this.#screenValue);
  }

  // overwriting the connect method, let's you
  // change the default event that widgets connect to
  connect(event = 'screen-changed', callback) {
    return super.connect(event, callback);
  }
}

// the singleton instance
const service = new BrightnessService;

// export to use in other modules
export default service;

