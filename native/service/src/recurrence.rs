//! Recurrence expansion, semantically identical to the Dart implementation
//! (`lib/utils/recurrence.dart`): occurrences are computed in UTC from the
//! original anchor (never by advancing the previous normalized instant, so a
//! Jan-31 monthly series yields Feb 28/29 and then Mar 31 again), bounded by
//! the recurrence end and the query window, with a hard safety cap.

use chrono::{DateTime, Datelike, Duration, TimeZone, Timelike, Utc};

use crate::model::{Event, Occurrence, Recurrence};

/// Safety cap mirroring the Dart expander (~10 years of daily).
const MAX_OCCURRENCES: usize = 3660;

/// Every occurrence of `event` overlapping the half-open window
/// `[range_start, range_end)`, in chronological order.
pub fn expand(event: &Event, range_start: DateTime<Utc>, range_end: DateTime<Utc>) -> Vec<Occurrence> {
    if event.is_deleted() {
        return Vec::new();
    }
    let duration = event.end - event.start;
    let mut out = Vec::new();

    let mut add_if_overlaps = |start: DateTime<Utc>| {
        let end = start + duration;
        if end > range_start && start < range_end {
            out.push(Occurrence::from_event(event, start, end));
        }
    };

    if event.recurrence == Recurrence::None {
        add_if_overlaps(event.start);
        return out;
    }

    let hard_end = match event.recurrence_end {
        Some(rec_end) if rec_end < range_end => rec_end,
        _ => range_end,
    };

    let slack = if duration < Duration::zero() { Duration::zero() } else { duration };
    let mut index = first_useful_index(event.start, event.recurrence, range_start - slack);
    let mut current = occurrence_at(event.start, event.recurrence, index);
    let mut guard = 0usize;
    while current <= hard_end && guard < MAX_OCCURRENCES {
        add_if_overlaps(current);
        index += 1;
        current = occurrence_at(event.start, event.recurrence, index);
        guard += 1;
    }
    out
}

/// Expand many events over one window, sorted by occurrence start.
pub fn expand_all<'a>(
    events: impl IntoIterator<Item = &'a Event>,
    range_start: DateTime<Utc>,
    range_end: DateTime<Utc>,
) -> Vec<Occurrence> {
    let mut all: Vec<Occurrence> = events
        .into_iter()
        .flat_map(|e| expand(e, range_start, range_end))
        .collect();
    all.sort_by_key(|o| o.occurrence_start);
    all
}

/// A conservative index near `target` so old open-ended series don't walk
/// thousands of irrelevant occurrences (one period of slack, like Dart).
fn first_useful_index(anchor: DateTime<Utc>, kind: Recurrence, target: DateTime<Utc>) -> i64 {
    if target <= anchor {
        return 0;
    }
    let days = (target - anchor).num_days();
    match kind {
        Recurrence::Daily => (days - 1).max(0),
        Recurrence::Weekly => (days / 7 - 1).max(0),
        Recurrence::Monthly => {
            let months = (target.year() as i64 - anchor.year() as i64) * 12
                + (target.month() as i64 - anchor.month() as i64);
            (months - 1).max(0)
        }
        Recurrence::Yearly => (target.year() as i64 - anchor.year() as i64 - 1).max(0),
        Recurrence::None => 0,
    }
}

fn occurrence_at(anchor: DateTime<Utc>, kind: Recurrence, index: i64) -> DateTime<Utc> {
    match kind {
        Recurrence::None => anchor,
        Recurrence::Daily => anchor + Duration::days(index),
        Recurrence::Weekly => anchor + Duration::days(index * 7),
        Recurrence::Monthly => {
            let absolute_month = anchor.year() as i64 * 12 + anchor.month() as i64 - 1 + index;
            let year = absolute_month.div_euclid(12) as i32;
            let month = (absolute_month.rem_euclid(12) + 1) as u32;
            at_clamped(anchor, year, month)
        }
        Recurrence::Yearly => {
            let year = anchor.year() + index as i32;
            at_clamped(anchor, year, anchor.month())
        }
    }
}

/// `year-month-anchor.day` with the day clamped into the month, keeping the
/// anchor's time of day. Mirrors Dart's `DateTime.utc(..., day.clamp(...))`.
fn at_clamped(anchor: DateTime<Utc>, year: i32, month: u32) -> DateTime<Utc> {
    let day = anchor.day().min(days_in_month(year, month));
    Utc.with_ymd_and_hms(year, month, day, anchor.hour(), anchor.minute(), anchor.second())
        .single()
        .map(|dt| dt + Duration::nanoseconds(anchor.nanosecond() as i64))
        // Unreachable for a clamped valid Gregorian date in UTC (no DST gaps);
        // fall back to the anchor rather than panicking in a daemon.
        .unwrap_or(anchor)
}

fn days_in_month(year: i32, month: u32) -> u32 {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 => {
            if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 {
                29
            } else {
                28
            }
        }
        _ => 30,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::model::SyncState;
    use chrono::TimeZone;

    fn utc(y: i32, mo: u32, d: u32, h: u32, mi: u32) -> DateTime<Utc> {
        Utc.with_ymd_and_hms(y, mo, d, h, mi, 0).single().expect("valid test date")
    }

    fn event(start: DateTime<Utc>, end: DateTime<Utc>, rec: Recurrence, until: Option<DateTime<Utc>>) -> Event {
        Event {
            id: "e1".into(),
            calendar_id: "default".into(),
            nostr_event_id: None,
            owner_pubkey: None,
            title: "t".into(),
            description: String::new(),
            location: None,
            url: None,
            start,
            end,
            timezone: "Europe/Rome".into(),
            all_day: false,
            recurrence: rec,
            recurrence_end: until,
            reminders: vec![],
            status: "confirmed".into(),
            visibility: "private".into(),
            color: "0xFF2196F3".into(),
            created_at: start,
            updated_at: start,
            deleted_at: None,
            local_revision: 1,
            remote_revision: None,
            sync_state: SyncState::LocalOnly,
            source_device: None,
            metadata: serde_json::Map::new(),
        }
    }

    #[test]
    fn single_event_overlap_is_half_open() {
        let e = event(utc(2026, 7, 19, 9, 0), utc(2026, 7, 19, 10, 0), Recurrence::None, None);
        // Window ending exactly at the start excludes it.
        assert!(expand(&e, utc(2026, 7, 19, 8, 0), utc(2026, 7, 19, 9, 0)).is_empty());
        // Window starting exactly at the end excludes it.
        assert!(expand(&e, utc(2026, 7, 19, 10, 0), utc(2026, 7, 19, 11, 0)).is_empty());
        assert_eq!(expand(&e, utc(2026, 7, 19, 0, 0), utc(2026, 7, 20, 0, 0)).len(), 1);
    }

    #[test]
    fn daily_series_expands_within_window() {
        let e = event(utc(2026, 7, 1, 9, 0), utc(2026, 7, 1, 9, 30), Recurrence::Daily, None);
        let occ = expand(&e, utc(2026, 7, 10, 0, 0), utc(2026, 7, 13, 0, 0));
        assert_eq!(occ.len(), 3);
        assert_eq!(occ[0].occurrence_start, utc(2026, 7, 10, 9, 0));
        assert_eq!(occ[2].occurrence_start, utc(2026, 7, 12, 9, 0));
    }

    #[test]
    fn monthly_jan31_clamps_to_february_then_recovers() {
        let e = event(utc(2026, 1, 31, 12, 0), utc(2026, 1, 31, 13, 0), Recurrence::Monthly, None);
        let occ = expand(&e, utc(2026, 1, 1, 0, 0), utc(2026, 4, 1, 0, 0));
        let starts: Vec<_> = occ.iter().map(|o| o.occurrence_start).collect();
        assert_eq!(
            starts,
            vec![utc(2026, 1, 31, 12, 0), utc(2026, 2, 28, 12, 0), utc(2026, 3, 31, 12, 0)]
        );
    }

    #[test]
    fn yearly_feb29_clamps_on_non_leap_years() {
        let e = event(utc(2024, 2, 29, 8, 0), utc(2024, 2, 29, 9, 0), Recurrence::Yearly, None);
        let occ = expand(&e, utc(2025, 1, 1, 0, 0), utc(2026, 12, 31, 0, 0));
        let starts: Vec<_> = occ.iter().map(|o| o.occurrence_start).collect();
        assert_eq!(starts, vec![utc(2025, 2, 28, 8, 0), utc(2026, 2, 28, 8, 0)]);
    }

    #[test]
    fn recurrence_end_bounds_the_series() {
        let e = event(
            utc(2026, 7, 1, 9, 0),
            utc(2026, 7, 1, 10, 0),
            Recurrence::Weekly,
            Some(utc(2026, 7, 15, 9, 0)),
        );
        let occ = expand(&e, utc(2026, 6, 1, 0, 0), utc(2026, 9, 1, 0, 0));
        assert_eq!(occ.len(), 3); // Jul 1, 8, 15 — the 22nd is past the end.
    }

    #[test]
    fn deleted_events_produce_nothing() {
        let mut e = event(utc(2026, 7, 1, 9, 0), utc(2026, 7, 1, 10, 0), Recurrence::Daily, None);
        e.sync_state = SyncState::DeletedPending;
        assert!(expand(&e, utc(2026, 7, 1, 0, 0), utc(2026, 8, 1, 0, 0)).is_empty());
    }

    #[test]
    fn long_event_overlapping_window_start_is_included() {
        // 3-day event recurring weekly; window starts mid-occurrence.
        let e = event(utc(2026, 7, 6, 0, 0), utc(2026, 7, 9, 0, 0), Recurrence::Weekly, None);
        let occ = expand(&e, utc(2026, 7, 7, 12, 0), utc(2026, 7, 8, 0, 0));
        assert_eq!(occ.len(), 1);
        assert_eq!(occ[0].occurrence_start, utc(2026, 7, 6, 0, 0));
    }
}
