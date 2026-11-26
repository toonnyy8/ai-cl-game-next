//! M0: the blank page (a clear colour and a camera) with the page contract of `duel_app::page`.
use bevy::prelude::*;
use duel_app::page::{PagePlugin, camera_bundle};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                title: "SOUL DUEL".into(),
                canvas: Some("#bevy".into()),
                fit_canvas_to_parent: true,
                prevent_default_event_handling: true,
                ..default()
            }),
            ..default()
        }))
        .add_plugins(PagePlugin)
        .insert_resource(ClearColor(Color::srgb(0.08, 0.08, 0.1)))
        .insert_resource(bevy::winit::WinitSettings::game())
        .add_systems(Startup, |mut c: Commands| {
            c.spawn(camera_bundle());
        })
        .run();
}
