//! SOUL DUEL's Bevy app (docs/bevy/BEVY_PORT.md §4): the library half, so the page's modules are reachable as `duel_app::*`.
pub mod driver;
pub mod page;
pub mod render;

pub use render::camera::camera_bundle;
