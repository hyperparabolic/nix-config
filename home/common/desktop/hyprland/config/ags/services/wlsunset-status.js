import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

import GLib from 'gi://GLib';
const HOME = GLib.getenv('HOME');

/**
 * Manages stopping and starting wlsunset.service, additionally listens to
 * ~/.local/share/wlsunset-status for changes to that service's status
 * (populated by wlsunset-status.service)
 */
class WLSunsetStatus extends Service {
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
  #statusFile = `${HOME}/.local/share/wlsunset-status`;

  get status() {
    return this.#status;
  }

  set status(b) {
    const subCommand = b ? 'restart' : 'stop';
    Utils.execAsync(`systemctl --user ${subCommand} wlsunset.service`);
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
const service = new WLSunsetStatus;
export default service;

