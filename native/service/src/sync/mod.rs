//! Nostr synchronization (phase 7). `wire` implements the normative wire
//! contract (docs/nostr-sync.md), `transport` isolates the relay pool behind
//! a trait, `engine` runs pull-merge-push cycles against the store.

pub mod engine;
pub mod transport;
pub mod wire;

pub use engine::SyncEngine;
