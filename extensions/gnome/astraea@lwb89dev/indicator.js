// Panel indicator + popup: agenda for a selectable day, quick event
// creation, and a shortcut into the desktop app. Thin frontend by design —
// all data comes from astraea-service via AstraeaClient, every call is
// async, and the shell keeps working (with a clear status line) when the
// service is missing.

import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

import {AstraeaClient} from './dbusClient.js';

function pad2(n) {
    return n < 10 ? `0${n}` : `${n}`;
}

function isoDate(dt) {
    return `${dt.get_year()}-${pad2(dt.get_month())}-${pad2(dt.get_day_of_month())}`;
}

function localTimezoneId() {
    const id = GLib.TimeZone.new_local().get_identifier();
    // g_time_zone_get_identifier can return an offset like "+02:00" when the
    // system zone is unnamed; the service requires an IANA name.
    return id && id.includes('/') ? id : 'UTC';
}

/** "HH:MM" → [h, m], or null if not parseable. */
function parseTime(text) {
    const match = /^\s*(\d{1,2})[:.](\d{2})\s*$/.exec(text);
    if (!match)
        return null;
    const h = Number(match[1]);
    const m = Number(match[2]);
    if (h > 23 || m > 59)
        return null;
    return [h, m];
}

export const AstraeaIndicator = GObject.registerClass(
class AstraeaIndicator extends PanelMenu.Button {
    _init(extension) {
        super._init(0.5, 'Astraea Calendar');
        this._extension = extension;
        this._gettext = extension.gettext.bind(extension);
        this._client = new AstraeaClient();
        this._selected = GLib.DateTime.new_now_local();
        this._destroyed = false;

        this.add_child(new St.Icon({
            icon_name: 'x-office-calendar-symbolic',
            style_class: 'system-status-icon',
        }));

        this._buildMenu();

        // Signals keep the popup fresh without polling; the menu also
        // refreshes every time it opens (cheap: one GetDay).
        this._client.onSignal('EventsChanged', () => this._refresh());
        this.menu.connect('open-state-changed', (_menu, open) => {
            if (open)
                this._refresh();
        });
    }

    _buildMenu() {
        const _ = this._gettext;

        // --- date navigation row -------------------------------------
        const nav = new PopupMenu.PopupBaseMenuItem({
            reactive: false,
            can_focus: false,
        });
        const navBox = new St.BoxLayout({
            style_class: 'astraea-nav',
            x_expand: true,
        });
        this._dateLabel = new St.Label({
            text: '',
            x_expand: true,
            x_align: Clutter.ActorAlign.CENTER,
            y_align: Clutter.ActorAlign.CENTER,
            style_class: 'astraea-date-label',
        });
        navBox.add_child(this._navButton('go-previous-symbolic',
            _('Previous day'), () => this._shiftDay(-1)));
        navBox.add_child(this._dateLabel);
        navBox.add_child(this._navButton('go-next-symbolic',
            _('Next day'), () => this._shiftDay(1)));
        nav.add_child(navBox);
        this.menu.addMenuItem(nav);

        const todayItem = new PopupMenu.PopupMenuItem(_('Today'));
        todayItem.connect('activate', () => {
            this._selected = GLib.DateTime.new_now_local();
            this._refresh();
        });
        this.menu.addMenuItem(todayItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        // --- agenda ---------------------------------------------------
        this._agendaSection = new PopupMenu.PopupMenuSection();
        this.menu.addMenuItem(this._agendaSection);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        // --- quick add ------------------------------------------------
        this._quickAdd = new PopupMenu.PopupSubMenuMenuItem(_('New event…'));
        this._buildQuickAdd(this._quickAdd.menu);
        this.menu.addMenuItem(this._quickAdd);

        // --- open app + status ---------------------------------------
        const openItem = new PopupMenu.PopupMenuItem(_('Open Astraea'));
        openItem.connect('activate', () => {
            this._client.openDesktop('day', '', isoDate(this._selected))
                .catch(e => this._showError(e));
        });
        this.menu.addMenuItem(openItem);

        this._statusItem = new PopupMenu.PopupMenuItem('', {
            reactive: false,
            can_focus: false,
        });
        this._statusItem.label.add_style_class_name('astraea-status');
        this.menu.addMenuItem(this._statusItem);
    }

    _navButton(iconName, accessibleName, onClick) {
        const button = new St.Button({
            style_class: 'button astraea-nav-button',
            can_focus: true,
            child: new St.Icon({icon_name: iconName, icon_size: 16}),
        });
        button.set_accessible_name(accessibleName);
        button.connect('clicked', onClick);
        return button;
    }

    _buildQuickAdd(menu) {
        const _ = this._gettext;

        const makeRow = (labelText, entry) => {
            const item = new PopupMenu.PopupBaseMenuItem({
                reactive: false,
                can_focus: false,
            });
            const row = new St.BoxLayout({x_expand: true});
            row.add_child(new St.Label({
                text: labelText,
                y_align: Clutter.ActorAlign.CENTER,
                style_class: 'astraea-field-label',
            }));
            entry.set_x_expand(true);
            row.add_child(entry);
            item.add_child(row);
            menu.addMenuItem(item);
        };

        this._titleEntry = new St.Entry({
            hint_text: _('Title'),
            can_focus: true,
            style_class: 'astraea-entry',
        });
        makeRow(_('Title'), this._titleEntry);

        this._startEntry = new St.Entry({
            hint_text: '09:00',
            can_focus: true,
            style_class: 'astraea-entry',
        });
        makeRow(_('Start'), this._startEntry);

        this._endEntry = new St.Entry({
            hint_text: '10:00',
            can_focus: true,
            style_class: 'astraea-entry',
        });
        makeRow(_('End'), this._endEntry);

        this._allDaySwitch = new PopupMenu.PopupSwitchMenuItem(_('All day'), false);
        menu.addMenuItem(this._allDaySwitch);

        const saveItem = new PopupMenu.PopupMenuItem(_('Save'));
        saveItem.connect('activate', () => this._saveQuickEvent());
        menu.addMenuItem(saveItem);

        const editorItem = new PopupMenu.PopupMenuItem(_('Open full editor…'));
        editorItem.connect('activate', () => {
            this._client.openDesktop('new-event', '', isoDate(this._selected))
                .catch(e => this._showError(e));
        });
        menu.addMenuItem(editorItem);

        // Focus the title as soon as the submenu opens: keyboard-first.
        this._quickAdd.menu.connect('open-state-changed', (_m, open) => {
            if (open)
                this._titleEntry.grab_key_focus();
        });
    }

    async _saveQuickEvent() {
        const _ = this._gettext;
        const title = this._titleEntry.get_text().trim();
        if (title === '') {
            Main.notify('Astraea', _('The event needs a title.'));
            return;
        }

        const allDay = this._allDaySwitch.state;
        let startLocal, endLocal;
        if (allDay) {
            startLocal = this._atTime(0, 0);
            endLocal = this._atTime(23, 59);
        } else {
            const start = parseTime(this._startEntry.get_text() || '09:00');
            const end = parseTime(this._endEntry.get_text() || '10:00');
            if (!start || !end) {
                Main.notify('Astraea', _('Times must be HH:MM.'));
                return;
            }
            startLocal = this._atTime(start[0], start[1]);
            endLocal = this._atTime(end[0], end[1]);
            if (endLocal.compare(startLocal) < 0) {
                Main.notify('Astraea', _('The end time is before the start.'));
                return;
            }
        }

        const draft = {
            schemaVersion: 1,
            title,
            start: startLocal.to_utc().format_iso8601(),
            end: endLocal.to_utc().format_iso8601(),
            timezone: localTimezoneId(),
            allDay,
        };
        try {
            await this._client.createEvent(draft);
            this._titleEntry.set_text('');
            this._quickAdd.menu.close(true);
            this._refresh();
        } catch (e) {
            this._showError(e);
        }
    }

    _atTime(hour, minute) {
        return GLib.DateTime.new_local(
            this._selected.get_year(),
            this._selected.get_month(),
            this._selected.get_day_of_month(),
            hour, minute, 0);
    }

    _shiftDay(days) {
        this._selected = this._selected.add_days(days);
        this._refresh();
    }

    async _refresh() {
        if (this._destroyed)
            return;
        const _ = this._gettext;
        this._dateLabel.set_text(this._selected.format('%A %e %B %Y'));

        let occurrences;
        try {
            occurrences = await this._client.getDay(isoDate(this._selected));
        } catch (e) {
            if (this._destroyed)
                return;
            this._agendaSection.removeAll();
            this._setStatus(_('Astraea service unavailable — install astraea-service, then reopen this menu.'));
            console.warn(`astraea: GetDay failed: ${e}`);
            return;
        }
        if (this._destroyed)
            return;

        this._agendaSection.removeAll();
        if (occurrences.length === 0) {
            const empty = new PopupMenu.PopupMenuItem(_('No events'), {
                reactive: false,
                can_focus: false,
            });
            empty.label.add_style_class_name('astraea-status');
            this._agendaSection.addMenuItem(empty);
        }
        for (const occurrence of occurrences.slice(0, 12)) {
            const time = occurrence.allDay
                ? _('All day')
                : this._formatTime(occurrence.occurrenceStart);
            const item = new PopupMenu.PopupMenuItem(`${time}  ${occurrence.title}`);
            item.connect('activate', () => {
                this._client.openDesktop('event', occurrence.eventId, '')
                    .catch(e => this._showError(e));
            });
            this._agendaSection.addMenuItem(item);
        }
        if (occurrences.length > 12) {
            const more = new PopupMenu.PopupMenuItem(
                _('%d more — open Astraea').format(occurrences.length - 12));
            more.connect('activate', () => {
                this._client.openDesktop('day', '', isoDate(this._selected))
                    .catch(e => this._showError(e));
            });
            this._agendaSection.addMenuItem(more);
        }

        // Status line: sync/auth summary, best-effort.
        try {
            const status = await this._client.getServiceStatus();
            if (this._destroyed)
                return;
            const pending = status.pendingOperations ?? 0;
            const auth = status.authenticated
                ? _('signed in')
                : _('local-only');
            const sync = pending > 0
                ? _('%d change(s) waiting to sync').format(pending)
                : _('up to date');
            this._setStatus(`${auth} · ${sync}`);
        } catch (e) {
            this._setStatus('');
        }
    }

    _formatTime(iso) {
        const dt = GLib.DateTime.new_from_iso8601(iso, null);
        return dt ? dt.to_local().format('%H:%M') : '';
    }

    _setStatus(text) {
        this._statusItem.label.set_text(text);
        this._statusItem.visible = text !== '';
    }

    _showError(e) {
        const _ = this._gettext;
        Main.notify('Astraea', _('Operation failed: %s').format(String(e)));
    }

    destroy() {
        this._destroyed = true;
        this._client.destroy();
        super.destroy();
    }
});
