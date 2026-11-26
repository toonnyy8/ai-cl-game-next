use bevy::prelude::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_systems(Startup, |mut c: Commands| {
            c.spawn(Camera3d::default());
        })
        .run();
}
