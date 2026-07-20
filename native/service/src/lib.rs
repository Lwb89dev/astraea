//! astraea-service library crate: everything the binary uses, exposed so
//! integration tests (tests/) can exercise the real code paths — login
//! bridge, store, recurrence — without going through a spawned process.

pub mod account;
pub mod bus;
pub mod daemon;
pub mod db;
pub mod model;
pub mod paths;
pub mod recurrence;
pub mod store;
pub mod sync;
