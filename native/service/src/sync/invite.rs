//! Attendee invite/response wire codec (ADR-007, docs/nostr-sync.md).
//!
//! Reuses the calendar event transport substrate exactly (kind 30078,
//! per-recipient NIP-44, deterministic `d` tag, `p`-tag addressing) but is
//! a distinct message family: every payload carries the `_astraeaInvite`
//! sentinel key so the ingestion loop can tell an invite/response apart
//! from a calendar-sync payload before trying to interpret it as one.

use chrono::{DateTime, SecondsFormat, Utc};
use nostr::{EventBuilder, Kind, Tag, Timestamp, UnsignedEvent};
use serde_json::{json, Value};

use crate::model::Event;
use crate::sync::wire::CALENDAR_KIND;

/// Sentinel key distinguishing this message family from a calendar-sync
/// payload sharing the same kind. Absence of this key means "not ours."
pub const SENTINEL_KEY: &str = "_astraeaInvite";
const TYPE_INVITE: &str = "invite";
const TYPE_RESPONSE: &str = "response";

/// Field bounds for an incoming invite. An invite is unauthenticated in the
/// sense that matters here: anyone who knows the invitee's pubkey can
/// `p`-tag them and have a relay deliver it (see MAX_FETCH_TOTAL_BYTES in
/// transport.rs for the response-size side of this). The outer envelope
/// already caps total ciphertext at `wire::MAX_CONTENT_CHARS` (~90 000
/// chars), but that alone would still let a single field absorb nearly all
/// of it — these are ordinary calendar-field sizes no legitimate client
/// would ever exceed, checked before the payload is trusted enough to show
/// in a notification or store in `invitations`.
const MAX_TITLE_CHARS: usize = 500;
const MAX_DESCRIPTION_CHARS: usize = 4_000;
const MAX_LOCATION_CHARS: usize = 500;
const MAX_TIMEZONE_CHARS: usize = 100;
/// A little slack past "no event realistically spans this long", not a
/// precise calendar limit.
const MAX_EVENT_DURATION_DAYS: i64 = 5 * 365;

pub fn invite_d_tag(event_id: &str) -> String {
    format!("astraea-invite:v1:{event_id}")
}

pub fn response_d_tag(event_id: &str) -> String {
    format!("astraea-invite-response:v1:{event_id}")
}

/// The plaintext of an invite payload — a purpose-built subset of the
/// event, never the internal `Event` wholesale: no `calendarId`,
/// `localRevision` or `syncState` leaks to someone who isn't a member of
/// this calendar (mirrors Echoes' `toShareJson()` discipline).
#[derive(Debug, Clone)]
pub struct InvitePayload {
    pub event_id: String,
    pub title: String,
    pub description: String,
    pub location: Option<String>,
    pub start: DateTime<Utc>,
    pub end: DateTime<Utc>,
    pub timezone: String,
    pub all_day: bool,
}

impl InvitePayload {
    pub fn from_event(event: &Event) -> Self {
        Self {
            event_id: event.id.clone(),
            title: event.title.clone(),
            description: event.description.clone(),
            location: event.location.clone(),
            start: event.start,
            end: event.end,
            timezone: event.timezone.clone(),
            all_day: event.all_day,
        }
    }

    fn to_json(&self) -> Value {
        let iso = |t: DateTime<Utc>| t.to_rfc3339_opts(SecondsFormat::Millis, true);
        json!({
            SENTINEL_KEY: TYPE_INVITE,
            "eventId": self.event_id,
            "title": self.title,
            "description": self.description,
            "location": self.location,
            "startTimeUtc": iso(self.start),
            "endTimeUtc": iso(self.end),
            "timezone": self.timezone,
            "isAllDay": self.all_day,
        })
    }

    fn from_json(value: &Value) -> Option<Self> {
        if value.get(SENTINEL_KEY)?.as_str()? != TYPE_INVITE {
            return None;
        }
        let title = value.get("title").and_then(Value::as_str).unwrap_or("");
        let description = value
            .get("description")
            .and_then(Value::as_str)
            .unwrap_or("");
        let location = value.get("location").and_then(Value::as_str);
        let timezone = value
            .get("timezone")
            .and_then(Value::as_str)
            .unwrap_or("UTC");
        if title.chars().count() > MAX_TITLE_CHARS
            || description.chars().count() > MAX_DESCRIPTION_CHARS
            || location.is_some_and(|l| l.chars().count() > MAX_LOCATION_CHARS)
            || timezone.chars().count() > MAX_TIMEZONE_CHARS
        {
            return None;
        }
        let start = parse_iso(value.get("startTimeUtc")?)?;
        let end = parse_iso(value.get("endTimeUtc")?)?;
        // Reject a non-positive or implausibly long span rather than let it
        // reach the invitations table and whatever renders it.
        let span = end.signed_duration_since(start);
        if span <= chrono::Duration::zero()
            || span > chrono::Duration::days(MAX_EVENT_DURATION_DAYS)
        {
            return None;
        }
        Some(Self {
            event_id: value.get("eventId")?.as_str()?.to_owned(),
            title: title.to_owned(),
            description: description.to_owned(),
            location: location.map(str::to_owned),
            start,
            end,
            timezone: timezone.to_owned(),
            all_day: value
                .get("isAllDay")
                .and_then(Value::as_bool)
                .unwrap_or(false),
        })
    }
}

/// The plaintext of a response payload (invitee -> inviter).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ResponseStatus {
    Accepted,
    Declined,
}

impl ResponseStatus {
    fn as_str(self) -> &'static str {
        match self {
            ResponseStatus::Accepted => "accepted",
            ResponseStatus::Declined => "declined",
        }
    }
}

#[derive(Debug, Clone)]
pub struct ResponsePayload {
    pub event_id: String,
    pub status: ResponseStatus,
}

impl ResponsePayload {
    fn to_json(&self) -> Value {
        json!({
            SENTINEL_KEY: TYPE_RESPONSE,
            "eventId": self.event_id,
            "status": self.status.as_str(),
        })
    }

    fn from_json(value: &Value) -> Option<Self> {
        if value.get(SENTINEL_KEY)?.as_str()? != TYPE_RESPONSE {
            return None;
        }
        let status = match value.get("status")?.as_str()? {
            "accepted" => ResponseStatus::Accepted,
            "declined" => ResponseStatus::Declined,
            _ => return None,
        };
        Some(Self {
            event_id: value.get("eventId")?.as_str()?.to_owned(),
            status,
        })
    }
}

/// Either message family, decoded from one decrypted payload. `None` means
/// "not an invite-family message" (e.g. it's a calendar-sync payload, or
/// junk) — the caller's ingestion loop tries this decode first and falls
/// back to the calendar-sync decoder, never the other way around, so a
/// sentinel-less payload is unambiguous.
pub enum InviteMessage {
    Invite(InvitePayload),
    Response(ResponsePayload),
}

pub fn parse_message(plaintext: &str) -> Option<InviteMessage> {
    let value: Value = serde_json::from_str(plaintext).ok()?;
    if let Some(invite) = InvitePayload::from_json(&value) {
        return Some(InviteMessage::Invite(invite));
    }
    ResponsePayload::from_json(&value).map(InviteMessage::Response)
}

/// Builds the unsigned invite event (owner -> invitee).
pub fn build_invite_unsigned(
    author: nostr::PublicKey,
    invitee: nostr::PublicKey,
    payload: &InvitePayload,
    ciphertext: String,
) -> UnsignedEvent {
    EventBuilder::new(Kind::from_u16(CALENDAR_KIND), ciphertext)
        .tag(Tag::identifier(invite_d_tag(&payload.event_id)))
        .tag(Tag::public_key(invitee))
        .custom_created_at(Timestamp::now())
        .build(author)
}

/// Builds the unsigned response event (invitee -> owner).
pub fn build_response_unsigned(
    author: nostr::PublicKey,
    inviter: nostr::PublicKey,
    payload: &ResponsePayload,
    ciphertext: String,
) -> UnsignedEvent {
    EventBuilder::new(Kind::from_u16(CALENDAR_KIND), ciphertext)
        .tag(Tag::identifier(response_d_tag(&payload.event_id)))
        .tag(Tag::public_key(inviter))
        .custom_created_at(Timestamp::now())
        .build(author)
}

fn parse_iso(value: &Value) -> Option<DateTime<Utc>> {
    DateTime::parse_from_rfc3339(value.as_str()?)
        .ok()
        .map(|t| t.with_timezone(&Utc))
}

pub(crate) fn invite_plaintext(payload: &InvitePayload) -> String {
    payload.to_json().to_string()
}

pub(crate) fn response_plaintext(payload: &ResponsePayload) -> String {
    payload.to_json().to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;

    fn sample_invite() -> InvitePayload {
        InvitePayload {
            event_id: "5f0e8f7a-1111-4222-8333-944444444444".into(),
            title: "Team lunch".into(),
            description: "bring appetite".into(),
            location: Some("Cafe".into()),
            start: Utc.with_ymd_and_hms(2026, 7, 20, 12, 0, 0).unwrap(),
            end: Utc.with_ymd_and_hms(2026, 7, 20, 13, 0, 0).unwrap(),
            timezone: "Europe/Rome".into(),
            all_day: false,
        }
    }

    #[test]
    fn invite_round_trips_through_json() {
        let invite = sample_invite();
        let plaintext = invite_plaintext(&invite);
        match parse_message(&plaintext).expect("parses") {
            InviteMessage::Invite(parsed) => {
                assert_eq!(parsed.event_id, invite.event_id);
                assert_eq!(parsed.title, "Team lunch");
                assert_eq!(parsed.start, invite.start);
                assert_eq!(parsed.location.as_deref(), Some("Cafe"));
            }
            InviteMessage::Response(_) => panic!("expected an invite"),
        }
    }

    #[test]
    fn response_round_trips_through_json() {
        let response = ResponsePayload {
            event_id: "abc-123".into(),
            status: ResponseStatus::Accepted,
        };
        let plaintext = response_plaintext(&response);
        match parse_message(&plaintext).expect("parses") {
            InviteMessage::Response(parsed) => {
                assert_eq!(parsed.event_id, "abc-123");
                assert_eq!(parsed.status, ResponseStatus::Accepted);
            }
            InviteMessage::Invite(_) => panic!("expected a response"),
        }
    }

    #[test]
    fn calendar_sync_payloads_are_not_mistaken_for_invite_messages() {
        // A plain calendar-sync payload (no sentinel key) must not parse.
        let calendar_payload = json!({
            "id": "x", "title": "t", "startTimeUtc": "2026-07-19T09:00:00.000Z",
            "endTimeUtc": "2026-07-19T10:00:00.000Z", "createdAt": 1, "updatedAt": 1
        })
        .to_string();
        assert!(parse_message(&calendar_payload).is_none());
    }

    #[test]
    fn junk_is_skipped_not_errored() {
        assert!(parse_message("not json").is_none());
        assert!(parse_message("{}").is_none());
    }

    #[test]
    fn d_tags_are_deterministic_and_distinct() {
        let id = "evt-1";
        assert_eq!(invite_d_tag(id), "astraea-invite:v1:evt-1");
        assert_eq!(response_d_tag(id), "astraea-invite-response:v1:evt-1");
        assert_ne!(invite_d_tag(id), response_d_tag(id));
    }

    /// Regression for this session's audit: an invite is reachable by
    /// anyone who knows the invitee's pubkey, so its fields must be bounded
    /// before it's trusted enough to reach a notification or the
    /// invitations table.
    #[test]
    fn oversized_or_implausible_invite_fields_are_rejected() {
        let mut invite = sample_invite();
        invite.title = "x".repeat(MAX_TITLE_CHARS + 1);
        assert!(
            parse_message(&invite_plaintext(&invite)).is_none(),
            "oversized title must be rejected"
        );

        let mut invite = sample_invite();
        invite.description = "x".repeat(MAX_DESCRIPTION_CHARS + 1);
        assert!(
            parse_message(&invite_plaintext(&invite)).is_none(),
            "oversized description must be rejected"
        );

        let mut invite = sample_invite();
        invite.end = invite.start; // zero-length span
        assert!(
            parse_message(&invite_plaintext(&invite)).is_none(),
            "a non-positive duration must be rejected"
        );

        let mut invite = sample_invite();
        invite.end = invite.start + chrono::Duration::days(MAX_EVENT_DURATION_DAYS + 1);
        assert!(
            parse_message(&invite_plaintext(&invite)).is_none(),
            "an implausibly long duration must be rejected"
        );
    }
}
