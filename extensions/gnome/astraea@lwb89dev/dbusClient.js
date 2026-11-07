// Thin async D-Bus client for com.lwb89dev.Astraea.Service.
//
// Frontend rules (docs/dbus-api.md): every call has a timeout, every error is
// caught by the caller, the service is started on demand by the call itself
// (D-Bus activation) — never by spawning the binary. No Nostr, no keys, no
// database access here.

import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

const BUS_NAME = 'com.lwb89dev.Astraea.Service';
const OBJECT_PATH = '/com/lwb89dev/Astraea';
const CALENDAR_IFACE = 'com.lwb89dev.Astraea.Calendar1';

const CALL_TIMEOUT_MS = 10000;

export class AstraeaClient {
    constructor() {
        this._bus = Gio.DBus.session;
        this._signalIds = [];
    }

    /**
     * Async D-Bus call returning the unpacked reply values array.
     * The first call to a stopped service triggers D-Bus activation.
     */
    _call(method, args, replyType) {
        return new Promise((resolve, reject) => {
            this._bus.call(
                BUS_NAME,
                OBJECT_PATH,
                CALENDAR_IFACE,
                method,
                args,
                replyType ? GLib.VariantType.new(replyType) : null,
                Gio.DBusCallFlags.NONE,
                CALL_TIMEOUT_MS,
                null,
                (bus, result) => {
                    try {
                        resolve(bus.call_finish(result).deepUnpack());
                    } catch (e) {
                        reject(e);
                    }
                });
        });
    }

    async getVersion() {
        const [version] = await this._call('GetVersion', null, '(s)');
        return version;
    }

    async getServiceStatus() {
        const [json] = await this._call('GetServiceStatus', null, '(s)');
        return JSON.parse(json);
    }

    /** Occurrences for one YYYY-MM-DD day (all calendars). */
    async getDay(isoDate) {
        const args = new GLib.Variant('(sas)', [isoDate, []]);
        const [json] = await this._call('GetDay', args, '(s)');
        const parsed = JSON.parse(json);
        return Array.isArray(parsed) ? parsed : [];
    }

    /** Occurrence counts per day for a month — used for the grid dots. */
    async getMonth(year, month) {
        const args = new GLib.Variant('(uuas)', [year, month, []]);
        const [json] = await this._call('GetMonth', args, '(s)');
        const parsed = JSON.parse(json);
        return Array.isArray(parsed) ? parsed : [];
    }

    /** Creates an event from the quick-add form. Returns the new event id. */
    async createEvent(draft) {
        const args = new GLib.Variant('(s)', [JSON.stringify(draft)]);
        const [id] = await this._call('CreateEvent', args, '(s)');
        return id;
    }

    /** Asks the service to open/raise the desktop app on a target. */
    async openDesktop(view, targetId, date) {
        const args = new GLib.Variant('(sss)', [view, targetId, date]);
        await this._call('OpenDesktop', args, null);
    }

    /**
     * Subscribes to a Calendar1 signal; returns nothing, cleanup happens in
     * destroy(). The callback receives the unpacked signal parameters.
     */
    onSignal(name, callback) {
        const id = this._bus.signal_subscribe(
            BUS_NAME,
            CALENDAR_IFACE,
            name,
            OBJECT_PATH,
            null,
            Gio.DBusSignalFlags.NONE,
            (_bus, _sender, _path, _iface, _signal, params) => {
                try {
                    callback(params.deepUnpack());
                } catch (e) {
                    console.warn(`astraea: signal handler failed: ${e}`);
                }
            });
        this._signalIds.push(id);
    }

    destroy() {
        for (const id of this._signalIds)
            this._bus.signal_unsubscribe(id);
        this._signalIds = [];
    }
}
