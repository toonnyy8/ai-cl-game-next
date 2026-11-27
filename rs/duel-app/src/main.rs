//! M3a: the page boots into the title and runs the fight the debug commands start (`Module._debug_cmd(2005)`), drawn by
//! `render::RenderPlugin` from the driver's `FrameOut` (ruling R17's minimal driver; Task 10 owns the loop, the keys and the dev line).
use bevy::prelude::*;
use duel_app::driver::{due_at, Game};
use duel_app::page::{now_ms, say, take_debug, PagePlugin};
use duel_app::render::{self, FrameRes, MeshSrc, RenderPlugin, SCENE_MSAA};
use duel_app::camera_bundle;
use duel_data::Data;
use duel_look::mesh::Meshes;
use duel_look::SceneInputs;
use std::sync::Arc;

fn main() {
    let data: &'static Data = Box::leak(Box::new(Data::embedded()));
    let font = render::ui::atlas_bytes(&render::ui::font_5x7(data));
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
        .add_plugins((PagePlugin, RenderPlugin { font }))
        .insert_resource(bevy::winit::WinitSettings::game())
        .insert_resource(MeshSrc(Arc::new(Meshes::build(data))))
        .insert_non_send({
            let mut g = Game::new(data, inputs(640, 360, 1.0));
            let q = query();
            g.log = q.contains("log");
            g.clock_dt = q.contains("dt=clock");
            g
        })
        .add_systems(Startup, |mut c: Commands| {
            c.spawn(camera_bundle());
        })
        .add_systems(Update, drive)
        .run();
}

/// The page's fixed inputs from the real surface: the window's size in pixels and its density, the renderer's MSAA; the rest are
/// the desktop window's (M3b makes the phone's live).
fn inputs(w: u32, h: u32, density: f32) -> SceneInputs {
    SceneInputs { width: w.max(1), height: h.max(1), density, msaa: SCENE_MSAA, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 }
}

/// The driver's update: the debug commands that arrived, the window's size, then the frames the page clock says are due.
fn drive(mut g: NonSendMut<Game>, mut out: ResMut<FrameRes>, win: Single<&Window>) {
    let due = due_at(now_ms());
    let g = &mut *g;
    take_debug(|n| g.queue_cmd(n as i64, due));
    g.sc.inputs = inputs(win.physical_width(), win.physical_height(), win.scale_factor());
    if !render::ready() {
        return;
    }
    for _ in 0..g.due_now(due) {
        let ok = g.frame(&mut out.0);
        for l in g.m.log.drain(..) {
            say(&l);
        }
        if !ok {
            say(&format!("duel: stopped: unported {}", g.stopped.unwrap_or("?")));
            break;
        }
    }
}

/// The page URL's query: `?log` the combat log on the console (as the frozen page prints it after a debug command), `?dt=clock` the
/// page clock's dt (driver.rs).
fn query() -> String {
    #[cfg(target_arch = "wasm32")]
    {
        web_sys::window().and_then(|w| w.location().search().ok()).unwrap_or_default()
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        std::env::var("DUEL_QUERY").unwrap_or_default()
    }
}
