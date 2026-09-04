//! XDG base-directory resolution. No hardcoded /home paths anywhere.

use std::env;
use std::path::PathBuf;

const APP_DIR: &str = "astraea";

fn xdg_dir(var: &str, home_fallback: &[&str]) -> PathBuf {
    match env::var_os(var) {
        Some(v) if !v.is_empty() => PathBuf::from(v).join(APP_DIR),
        _ => {
            let home = env::var_os("HOME")
                .map(PathBuf::from)
                .unwrap_or_else(|| PathBuf::from("."));
            let mut p = home;
            for part in home_fallback {
                p.push(part);
            }
            p.join(APP_DIR)
        }
    }
}

pub fn data_dir() -> PathBuf {
    xdg_dir("XDG_DATA_HOME", &[".local", "share"])
}

pub fn config_dir() -> PathBuf {
    xdg_dir("XDG_CONFIG_HOME", &[".config"])
}

pub fn cache_dir() -> PathBuf {
    xdg_dir("XDG_CACHE_HOME", &[".cache"])
}

pub fn state_dir() -> PathBuf {
    xdg_dir("XDG_STATE_HOME", &[".local", "state"])
}

pub fn log_dir() -> PathBuf {
    state_dir().join("logs")
}

pub fn runtime_dir() -> Option<PathBuf> {
    env::var_os("XDG_RUNTIME_DIR").map(|v| PathBuf::from(v).join(APP_DIR))
}

pub fn database_path() -> PathBuf {
    data_dir().join("astraea.db")
}
