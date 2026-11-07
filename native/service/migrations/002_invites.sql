-- Event attendee invites (ADR-007, docs/nostr-sync.md "Attendee invites").
-- Times: *_ms are Unix milliseconds, matching 001_init.sql's convention.

-- Attendees of an event I own. One row per invited pubkey; status moves
-- invited -> accepted|declined as response events arrive. A row here is
-- pure metadata — never a secret, never key material.
CREATE TABLE attendees (
    event_id      TEXT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    pubkey        TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'invited',
    invited_at_ms INTEGER NOT NULL,
    responded_at_ms INTEGER,
    PRIMARY KEY (event_id, pubkey)
);

CREATE INDEX idx_attendees_event ON attendees(event_id);

-- Invitations addressed to me that I have not yet accepted or declined.
-- Deliberately separate from `events`: an incoming invite has no local
-- event until accepted (docs/nostr-sync.md), so it cannot live in the
-- events table without inventing a fake sync_state for "not mine yet".
-- The payload fields are a cache of the invite's plaintext (already
-- decrypted before this row is written) purely for display; accepting
-- copies them into a real events row.
CREATE TABLE invitations (
    id                TEXT PRIMARY KEY,
    event_id          TEXT NOT NULL,
    inviter_pubkey    TEXT NOT NULL,
    title             TEXT NOT NULL,
    description       TEXT NOT NULL DEFAULT '',
    location          TEXT,
    start_utc         TEXT NOT NULL,
    end_utc           TEXT NOT NULL,
    timezone          TEXT NOT NULL,
    all_day           INTEGER NOT NULL DEFAULT 0,
    status            TEXT NOT NULL DEFAULT 'pending',
    received_at_ms    INTEGER NOT NULL,
    responded_at_ms   INTEGER
);

CREATE INDEX idx_invitations_status ON invitations(status);

-- Outgoing invite/response events still to be published, analogous to
-- sync_queue for calendar events. `kind` is 'invite' (I'm inviting
-- `peer_pubkey` to `event_id`, an event I own) or 'response' (I'm telling
-- `peer_pubkey`, the event's owner, whether I accept `event_id`).
CREATE TABLE invite_outbox (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    kind            TEXT NOT NULL,
    event_id        TEXT NOT NULL,
    peer_pubkey     TEXT NOT NULL,
    created_at_ms   INTEGER NOT NULL,
    attempts        INTEGER NOT NULL DEFAULT 0,
    next_attempt_ms INTEGER NOT NULL DEFAULT 0,
    last_error      TEXT
);

CREATE INDEX idx_invite_outbox_next ON invite_outbox(next_attempt_ms);

-- Incremental-pull cursor for the invite/response stream, separate from the
-- calendar-sync cursor (app_settings key sync.cursor_s) since the two kinds
-- of event serve different purposes and should not gate each other. Stored
-- as an app_settings row (key 'sync.invite_cursor_s'), no schema needed here.
