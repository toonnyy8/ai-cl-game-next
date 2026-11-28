//! M3a: the page boots into a VS CPU fight (the URL's `?p1=..&p2=..&cpu=..`, page.rs `Params`) played on the keyboard, drawn by
//! `render::RenderPlugin` from the game loop's `FrameOut` (game.rs; `?stills` boots to the title for the looks gate's scripts).
use bevy::prelude::*;
use duel_app::camera_bundle;
use duel_app::game::Game;
use duel_app::input::Key;
use duel_app::page::{now_ms, query, raf_frames, say, take_debug, PagePlugin, Params};
use duel_app::render::{self, FrameRes, MeshSrc, RenderPlugin, SCENE_MSAA};
use duel_data::Data;
use duel_look::mesh::Meshes;
use duel_look::SceneInputs;
use std::sync::Arc;

fn main() {
    let data: &'static Data = Box::leak(Box::new(Data::embedded()));
    let font = render::ui::atlas_bytes(&render::ui::font_5x7(data));
    let params = Params::parse(&query());
    for b in &params.bad {
        say(&format!("duel: unknown page parameter {b} (the default kept)"));
    }
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
            (g.log, g.start, g.dev) = (params.log, params.start, params.start.is_some());
            g.title_catch_up = params.start.is_none(); // (?stills)
            g.kb.hash_log = params.log;
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

/// Bevy's key codes of `input::Key`, in its bit order (the physical keys: SDL's scancodes on the frozen page).
const KEYS: [(Key, KeyCode); 18] = [
    (Key::W, KeyCode::KeyW),
    (Key::S, KeyCode::KeyS),
    (Key::A, KeyCode::KeyA),
    (Key::D, KeyCode::KeyD),
    (Key::J, KeyCode::KeyJ),
    (Key::Space, KeyCode::Space),
    (Key::LShift, KeyCode::ShiftLeft),
    (Key::P, KeyCode::KeyP),
    (Key::Up, KeyCode::ArrowUp),
    (Key::Down, KeyCode::ArrowDown),
    (Key::Left, KeyCode::ArrowLeft),
    (Key::Right, KeyCode::ArrowRight),
    (Key::Kp1, KeyCode::Numpad1),
    (Key::Kp0, KeyCode::Numpad0),
    (Key::KpEnter, KeyCode::NumpadEnter),
    (Key::KpPlus, KeyCode::NumpadAdd),
    (Key::Return, KeyCode::Enter),
    (Key::Escape, KeyCode::Escape),
];

/// The game's update: the debug commands that arrived, the window's size, the keys, then one frame if a browser frame went by since
/// the last one (ruling R32: `Game::refresh`, game.rs's header).
fn drive(mut g: NonSendMut<Game>, mut out: ResMut<FrameRes>, win: Single<&Window>, keys: Res<ButtonInput<KeyCode>>) {
    let g = &mut *g;
    take_debug(|n| g.queue_cmd(n as i64));
    g.sc.inputs = inputs(win.physical_width(), win.physical_height(), win.scale_factor());
    let (mut held, mut pressed) = (0, 0);
    for (k, c) in KEYS {
        held |= if keys.pressed(c) { k.bit() } else { 0 };
        pressed |= if keys.just_pressed(c) { k.bit() } else { 0 };
    }
    let ready = render::ready();
    g.keys(held, pressed, ready);
    if !ready || g.stopped.is_some() {
        return; // (stopped: logged once and drawn, on the frame that stopped; the page keeps drawing that frame)
    }
    let now = now_ms();
    let n = g.refresh(raf_frames() as u64, now);
    g.now_ms = now;
    for i in 1..=n {
        let rdt = g.rdt_of(now, i, n);
        let ok = g.frame(&mut out.0, rdt);
        for l in g.m.log.drain(..) {
            say(&l);
        }
        if !ok {
            say(&format!("duel: stopped: unported {}", g.stopped.unwrap_or("?")));
            break;
        }
    }
}
