// Astraea Calendar — GNOME Shell extension entry point.
//
// Deliberately a standalone top-bar indicator rather than a patch of the
// shell's clock/calendar menu: the DateMenu internals change between GNOME
// releases and monkey-patching them risks breaking the shell (see
// docs/gnome-extension.md for the integration decision record and the
// planned adapter approach).

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

import {AstraeaIndicator} from './indicator.js';

export default class AstraeaExtension extends Extension {
    enable() {
        this._indicator = new AstraeaIndicator(this);
        Main.panel.addToStatusArea(this.uuid, this._indicator);
    }

    disable() {
        this._indicator?.destroy();
        this._indicator = null;
    }
}
