//! SQLite bootstrap: open, pragmas, versioned migrations, pre-migration
//! backup and corruption handling. XDG paths only (crate::paths).

use std::fs;
use std::path::{Path, PathBuf};

use rusqlite::Connection;
use tracing::{info, warn};

/// Ordered, append-only migration list. Never edit a shipped entry; add a new
/// one. Version = index + 1.
const MIGRATIONS: &[&str] = &[include_str!("../migrations/001_init.sql")];

#[derive(Debug, thiserror::Error)]
pub enum DbError {
    #[error("database I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("sqlite error: {0}")]
    Sqlite(#[from] rusqlite::Error),
    #[error("database is corrupted: {0}")]
    Corrupted(String),
}

pub fn schema_version(conn: &Connection) -> Result<i64, DbError> {
    let exists: i64 = conn.query_row(
        "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='schema_migrations'",
        [],
        |r| r.get(0),
    )?;
    if exists == 0 {
        return Ok(0);
    }
    Ok(conn.query_row(
        "SELECT COALESCE(MAX(version), 0) FROM schema_migrations",
        [],
        |r| r.get(0),
    )?)
}

/// Opens (creating if needed) the database at `path`, applies pragmas and any
/// pending migrations. A file-level backup is taken before migrating an
/// existing database.
pub fn open(path: &Path) -> Result<Connection, DbError> {
    if let Some(dir) = path.parent() {
        fs::create_dir_all(dir)?;
    }
    let existed = path.exists();
    let conn = Connection::open(path)?;

    conn.pragma_update(None, "journal_mode", "WAL")?;
    conn.pragma_update(None, "synchronous", "NORMAL")?;
    conn.pragma_update(None, "foreign_keys", "ON")?;
    conn.pragma_update(None, "busy_timeout", 5000_i64)?;

    let ok: String = conn.query_row("PRAGMA quick_check", [], |r| r.get(0))?;
    if ok != "ok" {
        // Preserve the damaged file for manual recovery; never delete data.
        let quarantine = sibling(path, ".corrupt");
        warn!(?quarantine, "database failed quick_check; quarantining");
        drop(conn);
        fs::rename(path, &quarantine)?;
        return Err(DbError::Corrupted(format!(
            "quick_check failed; damaged file moved to {}",
            quarantine.display()
        )));
    }

    migrate(&conn, existed, path)?;
    Ok(conn)
}

/// Applies pending migrations inside transactions, one version at a time.
pub fn migrate(conn: &Connection, backup_first: bool, path: &Path) -> Result<(), DbError> {
    conn.execute_batch(
        "CREATE TABLE IF NOT EXISTS schema_migrations (
             version INTEGER PRIMARY KEY,
             applied_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
         );",
    )?;
    let current = schema_version(conn)?;
    let target = MIGRATIONS.len() as i64;
    if current >= target {
        return Ok(());
    }

    if backup_first && current > 0 {
        let backup = sibling(path, &format!(".pre-migration-v{current}.bak"));
        info!(?backup, "backing up database before migration");
        conn.execute("VACUUM INTO ?1", [backup.to_string_lossy()])?;
    }

    for version in (current + 1)..=target {
        let sql = MIGRATIONS[(version - 1) as usize];
        info!(version, "applying migration");
        conn.execute_batch("BEGIN")?;
        let applied = conn.execute_batch(sql).and_then(|()| {
            conn.execute(
                "INSERT INTO schema_migrations (version) VALUES (?1)",
                [version],
            )
            .map(|_| ())
        });
        match applied {
            Ok(()) => conn.execute_batch("COMMIT")?,
            Err(e) => {
                let _ = conn.execute_batch("ROLLBACK");
                return Err(e.into());
            }
        }
    }
    Ok(())
}

fn sibling(path: &Path, suffix: &str) -> PathBuf {
    let mut name = path
        .file_name()
        .map(|n| n.to_os_string())
        .unwrap_or_default();
    name.push(suffix);
    path.with_file_name(name)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fresh_database_migrates_to_latest_and_seeds_default_calendar() {
        let dir = tempdir();
        let path = dir.join("astraea.db");
        let conn = open(&path).expect("open");
        assert_eq!(
            schema_version(&conn).expect("version"),
            MIGRATIONS.len() as i64
        );
        let name: String = conn
            .query_row("SELECT name FROM calendars WHERE is_default = 1", [], |r| {
                r.get(0)
            })
            .expect("default calendar");
        assert_eq!(name, "Astraea");
        cleanup(dir);
    }

    #[test]
    fn migrate_is_idempotent() {
        let dir = tempdir();
        let path = dir.join("astraea.db");
        {
            let _ = open(&path).expect("first open");
        }
        let conn = open(&path).expect("second open");
        assert_eq!(
            schema_version(&conn).expect("version"),
            MIGRATIONS.len() as i64
        );
        cleanup(dir);
    }

    fn tempdir() -> PathBuf {
        let dir = std::env::temp_dir().join(format!("astraea-db-test-{}", uuid::Uuid::new_v4()));
        fs::create_dir_all(&dir).expect("mkdir");
        dir
    }

    fn cleanup(dir: PathBuf) {
        let _ = fs::remove_dir_all(dir);
    }
}
