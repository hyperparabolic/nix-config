import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

import GLib from 'gi://GLib';
const HOME = GLib.getenv('HOME');

/**
 * Manages stopping and starting swayidle.service, additionally listens to
 * ~/.local/share/swayidle-status for changes to that service's status
 * (populated by swayidle-status.service)
 */
class SwayidleStatus extends Service {
  static {
    Service.register(
      this,
      {
        'status-changed': ['boolean'],
      },
      {
        'status': ['boolean', 'rw'],
      },
    );
  }

  // assume it's running to start, since it's the default
  #status = true;
  #statusFile = `${HOME}/.local/share/swayidle-status`;

  get status() {
    return this.#status;
  }

  set status(b) {
    const subCommand = b ? 'restart' : 'stop';
    Utils.execAsync(`systemctl --user ${subCommand} swayidle.service`);
  }

  constructor() {
    super();

    Utils.monitorFile(this.#statusFile, () => this.#onChange());
    this.#onChange();
  }

  #onChange() {
    this.#status = Number(Utils.exec(`cat ${this.#statusFile}`)) == 0 ? true : false;

    this.emit('changed');
    this.notify('status');

    this.emit('status-changed', this.#status);
  }

  connect(event = 'status-changed', callback) {
    return super.connect(event, callback);
  }
}

// init singleton
const service = new SwayidleStatus;
export default service;

