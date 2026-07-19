-- Astraea service schema, version 1.
-- Times: *_utc columns are RFC 3339 UTC strings; *_ms are Unix milliseconds.

CREATE TABLE accounts (
    id            TEXT PRIMARY KEY,
    pubkey        TEXT NOT NULL UNIQUE,
    npub          TEXT NOT NULL,
    label         TEXT NOT NULL DEFAULT '',
    signer        TEXT NOT NULL DEFAULT 'read_only',
    is_active     INTEGER NOT NULL DEFAULT 0,
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

CREATE TABLE calendars (
    id            TEXT PRIMARY KEY,
    name          TEXT NOT NULL,
    color         TEXT NOT NULL DEFAULT '0xFF3F51B5',
    is_default    INTEGER NOT NULL DEFAULT 0,
    position      INTEGER NOT NULL DEFAULT 0,
    deleted       INTEGER NOT NULL DEFAULT 0,
    created_at_ms INTEGER NOT NULL,
    updated_at_ms INTEGER NOT NULL
);

CREATE TABLE events (
    id                    TEXT PRIMARY KEY,
    calendar_id           TEXT NOT NULL REFERENCES calendars(id),
    nostr_event_id        TEXT,
    owner_pubkey          TEXT,
    title                 TEXT NOT NULL,
    description           TEXT NOT NULL DEFAULT '',
    location              TEXT,
    url                   TEXT,
    start_utc             TEXT NOT NULL,
    end_utc               TEXT NOT NULL,
    timezone              TEXT NOT NULL,
    all_day               INTEGER NOT NULL DEFAULT 0,
    recurrence            TEXT,               -- NULL | daily | weekly | monthly | yearly
    recurrence_end_utc    TEXT,
    recurrence_exceptions TEXT NOT NULL DEFAULT '[]',  -- JSON array, reserved
    reminders             TEXT NOT NULL DEFAULT '[]',  -- JSON [{"minutesBefore":n}]
    status                TEXT NOT NULL DEFAULT 'confirmed',
    visibility            TEXT NOT NULL DEFAULT 'private',
    color                 TEXT NOT NULL DEFAULT '0xFF2196F3',
    created_at_ms         INTEGER NOT NULL,
    updated_at_ms         INTEGER NOT NULL,
    deleted_at_ms         INTEGER,
    local_revision        INTEGER NOT NULL DEFAULT 1,
    remote_revision       TEXT,
    sync_state            TEXT NOT NULL DEFAULT 'local_only',
    signature_state       TEXT NOT NULL DEFAULT 'unsigned',
    encryption_state      TEXT NOT NULL DEFAULT 'plaintext_local',
    source_device         TEXT,
    metadata              TEXT NOT NULL DEFAULT '{}'
);

CREATE INDEX idx_events_start      ON events(start_utc);
CREATE INDEX idx_events_calendar   ON events(calendar_id);
CREATE INDEX idx_events_sync_state ON events(sync_state);
CREATE INDEX idx_events_owner      ON events(owner_pubkey);

CREATE TABLE reminders_fired (
    event_id     TEXT NOT NULL,
    occurrence_utc TEXT NOT NULL,
    minutes_before INTEGER NOT NULL,
    fired_at_ms  INTEGER NOT NULL,
    PRIMARY KEY (event_id, occurrence_utc, minutes_before)
);

CREATE TABLE nostr_relays (
    url         TEXT PRIMARY KEY,
    read        INTEGER NOT NULL DEFAULT 1,
    write       INTEGER NOT NULL DEFAULT 1,
    state       TEXT NOT NULL DEFAULT 'unknown',
    last_ok_ms  INTEGER
);

CREATE TABLE sync_queue (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id        TEXT NOT NULL,
    op              TEXT NOT NULL,             -- publish | delete
    created_at_ms   INTEGER NOT NULL,
    attempts        INTEGER NOT NULL DEFAULT 0,
    next_attempt_ms INTEGER NOT NULL DEFAULT 0,
    last_error      TEXT
);

CREATE INDEX idx_sync_queue_next ON sync_queue(next_attempt_ms);

CREATE TABLE sync_failures (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id     TEXT NOT NULL,
    op           TEXT NOT NULL,
    error        TEXT NOT NULL,
    failed_at_ms INTEGER NOT NULL
);

CREATE TABLE auth_sessions (
    id            TEXT PRIMARY KEY,
    status        TEXT NOT NULL,               -- pending | completed | cancelled | expired
    created_at_ms INTEGER NOT NULL,
    expires_at_ms INTEGER NOT NULL
);

CREATE TABLE app_settings (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Seed: the default calendar every install has.
INSERT INTO calendars (id, name, color, is_default, position, created_at_ms, updated_at_ms)
VALUES ('default', 'Astraea', '0xFF3F51B5', 1, 0,
        CAST(strftime('%s','now') AS INTEGER) * 1000,
        CAST(strftime('%s','now') AS INTEGER) * 1000);
