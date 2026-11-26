//! M0a speed test (throwaway, docs/bevy/plans/2026-11-26-m0a-speed-test.md): replay 240 frames captured from the frozen game
//! (tools/port/capture) through Bevy's own renderer: the toon / ink-hull draws as Bevy materials (toon.rs), the camera as a
//! Bevy Camera3d with the captured projection, one line of Bevy text for the HUD. Prints the frozen build's console lines
//! (`startup: heap ..`, `perf: startup .. | frame .. ms avg ..`) so tools/run.mjs and the G3 parser read both builds alike.
mod capture;
mod toon;

use bevy::{
    asset::{RenderAssetUsages, embedded_asset},
    camera::{CameraProjection, SubCameraView, visibility::NoFrustumCulling},
    math::Vec3A,
    mesh::PrimitiveTopology,
    prelude::*,
    render::view::Tonemapping,
};
use capture::Capture;
use std::collections::HashMap;
use toon::{HullCwMaterial, HullMaterial, ToonLanes, ToonMaterial, draw_lanes, frame_lanes};

static FRAMES_BIN: &[u8] = include_bytes!(concat!(env!("CARGO_MANIFEST_DIR"), "/../../../build/port/capture/frames.bin"));

/// The scene size the frozen build measured at (Task 1: 1280x720, render-scale 1.00); the window's physical size.
const SCENE_W: u32 = 1280;
const SCENE_H: u32 = 720;
/// Frames drawn with every slot visible before `startup:` (the pipelines compile during load, Review Focus 3).
const WARM_FRAMES: u32 = 12;

/// Diagnostic switches from the page URL's query (`?msaa=off`, `?empty`, `?static`): the speed test's breakdown.
#[derive(Resource, Clone, Copy, Default)]
struct Exp {
    msaa_off: bool,
    empty: bool,
    still: bool,
}

fn exp_from_url() -> Exp {
    #[cfg(target_arch = "wasm32")]
    let q = web_sys::window().and_then(|w| w.location().search().ok()).unwrap_or_default();
    #[cfg(not(target_arch = "wasm32"))]
    let q = std::env::var("M0A_EXP").unwrap_or_default();
    Exp { msaa_off: q.contains("msaa=off"), empty: q.contains("empty"), still: q.contains("static") }
}

/// Platform log: the browser console on wasm (plain text, no tracing prefix: run.mjs matches line starts), stdout natively.
fn say(s: &str) {
    #[cfg(target_arch = "wasm32")]
    web_sys::console::log_1(&s.into());
    #[cfg(not(target_arch = "wasm32"))]
    println!("{s}");
}

/// Milliseconds since the page started (performance.now) or since the process started.
fn now_ms() -> f64 {
    #[cfg(target_arch = "wasm32")]
    {
        web_sys::window().and_then(|w| w.performance()).map_or(0.0, |p| p.now())
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        use std::sync::OnceLock;
        static T0: OnceLock<std::time::Instant> = OnceLock::new();
        T0.get_or_init(std::time::Instant::now).elapsed().as_secs_f64() * 1000.0
    }
}

fn heap_mb() -> f64 {
    #[cfg(target_arch = "wasm32")]
    {
        use wasm_bindgen::JsCast;
        let m: js_sys::WebAssembly::Memory = wasm_bindgen::memory().unchecked_into();
        let b: js_sys::ArrayBuffer = m.buffer().unchecked_into();
        b.byte_length() as f64 / 1048576.0
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        0.0
    }
}

/// The captured frame's projection (clip_from_view = VP x V^-1), z flipped for Bevy's reverse-Z depth (clear 0, GreaterEqual).
#[derive(Debug, Clone, Default)]
struct CapProj {
    m: Mat4,
}

impl CameraProjection for CapProj {
    fn get_clip_from_view(&self) -> Mat4 {
        self.m
    }
    fn get_clip_from_view_for_sub(&self, _sub: &SubCameraView) -> Mat4 {
        self.m
    }
    fn update(&mut self, _w: f32, _h: f32) {}
    fn far(&self) -> f32 {
        400.0 // render.lisp's camera
    }
    fn get_frustum_corners(&self, z_near: f32, z_far: f32) -> [Vec3A; 8] {
        let inv = self.m.inverse();
        let dir = |x: f32, y: f32| {
            let p = inv.project_point3(Vec3::new(x, y, 0.5));
            p / -p.z // a view-space ray at depth 1
        };
        let rays = [dir(1.0, -1.0), dir(1.0, 1.0), dir(-1.0, 1.0), dir(-1.0, -1.0)];
        let mut out = [Vec3A::ZERO; 8];
        for (i, r) in rays.iter().enumerate() {
            out[i] = Vec3A::from(*r * z_near.abs());
            out[i + 4] = Vec3A::from(*r * z_far.abs());
        }
        out
    }
}

enum Pool {
    Toon,
    Hull,
    HullCw,
}

fn pool_of(pipe: u32, model: &Mat4) -> Option<Pool> {
    match pipe {
        1 => Some(Pool::Toon),
        2 if model.determinant() < 0.0 => Some(Pool::HullCw),
        2 => Some(Pool::Hull),
        _ => None, // lit / transparent draws: left out of the speed test (counted)
    }
}

struct Slot<M: Asset> {
    e: Entity,
    mat: Handle<M>,
    mesh: u32,
    lanes: ToonLanes,
}

#[derive(Resource)]
struct Replay {
    cap: Capture,
    meshes: HashMap<u32, Handle<Mesh>>,
    frame_lanes: ToonLanes,
    toon: Vec<Slot<ToonMaterial>>,
    hull: Vec<Slot<HullMaterial>>,
    hull_cw: Vec<Slot<HullCwMaterial>>,
    cam: Entity,
    frame: usize,
    worst_affine: f32,
}

#[derive(Resource, Default)]
struct Perf {
    frames: u32,
    started: Option<f64>,
    win_t0: f64,
    win_n: u32,
    win_sum: f64,
    win_max: f64,
    last: f64,
}

fn main() {
    let mut app = App::new();
    app.add_plugins(DefaultPlugins.set(WindowPlugin {
        primary_window: Some(Window {
            title: "SOUL DUEL M0a".into(),
            resolution: bevy::window::WindowResolution::new(SCENE_W, SCENE_H).with_scale_factor_override(1.0),
            canvas: Some("#bevy".into()),
            fit_canvas_to_parent: true,
            prevent_default_event_handling: true,
            ..default()
        }),
        ..default()
    }))
    .add_plugins((
        MaterialPlugin::<ToonMaterial>::default(),
        MaterialPlugin::<HullMaterial>::default(),
        MaterialPlugin::<HullCwMaterial>::default(),
    ))
    .insert_resource(Time::<Fixed>::from_hz(60.0))
    .insert_resource(ClearColor(Color::srgb(0.08, 0.08, 0.1)))
    .insert_resource(bevy::winit::WinitSettings::game())
    .init_resource::<Perf>()
    .insert_resource(exp_from_url())
    .add_systems(Startup, setup)
    .add_systems(FixedUpdate, replay)
    .add_systems(Last, perf);
    embedded_asset!(app, "shaders/toon.wesl");
    app.run();
}

fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut toon_m: ResMut<Assets<ToonMaterial>>,
    mut hull_m: ResMut<Assets<HullMaterial>>,
    mut hull_cw_m: ResMut<Assets<HullCwMaterial>>,
    windows: Query<&Window>,
    exp: Res<Exp>,
) {
    let cap = Capture::parse(FRAMES_BIN).expect("frames.bin");
    let mut mh = HashMap::new();
    let mut nverts = 0usize;
    for m in &cap.meshes {
        let mut mesh = Mesh::new(PrimitiveTopology::TriangleList, RenderAssetUsages::RENDER_WORLD);
        mesh.insert_attribute(Mesh::ATTRIBUTE_POSITION, m.verts.iter().map(|v| [v[0], v[1], v[2]]).collect::<Vec<_>>());
        mesh.insert_attribute(Mesh::ATTRIBUTE_NORMAL, m.verts.iter().map(|v| [v[3], v[4], v[5]]).collect::<Vec<_>>());
        mesh.insert_attribute(Mesh::ATTRIBUTE_COLOR, m.verts.iter().map(|v| [v[6], v[7], v[8], 1.0]).collect::<Vec<_>>());
        nverts += m.verts.len();
        mh.insert(m.id, meshes.add(mesh));
    }
    // pool sizes: the most draws of each kind in any frame
    let (mut nt, mut nh, mut nc, mut left_out) = (0, 0, 0, 0);
    for f in &cap.frames {
        let (mut t, mut h, mut c) = (0, 0, 0);
        for d in &f.draws {
            match pool_of(d.pipe, &Mat4::from_cols_slice(&d.rec[0..16])) {
                Some(Pool::Toon) => t += 1,
                Some(Pool::Hull) => h += 1,
                Some(Pool::HullCw) => c += 1,
                None => left_out += 1,
            }
        }
        (nt, nh, nc) = (nt.max(t), nh.max(h), nc.max(c));
    }
    let fl = frame_lanes(&cap.frames[0].fu);
    let any_mesh = mh.values().next().unwrap().clone();
    // every slot starts visible (the warm-up draws each material's pipeline once before `startup:`)
    macro_rules! pool {
        ($n:expr, $assets:expr, $ty:ident) => {
            (0..$n)
                .map(|_| {
                    let mat = $assets.add($ty { lanes: fl });
                    let e = commands
                        .spawn((Mesh3d(any_mesh.clone()), MeshMaterial3d(mat.clone()), Transform::default(), NoFrustumCulling))
                        .id();
                    Slot { e, mat, mesh: u32::MAX, lanes: fl }
                })
                .collect::<Vec<_>>()
        };
    }
    let toon = pool!(nt, toon_m, ToonMaterial);
    let hull = pool!(nh, hull_m, HullMaterial);
    let hull_cw = pool!(nc, hull_cw_m, HullCwMaterial);
    let cam = commands
        .spawn((Camera3d::default(), Tonemapping::None, Projection::custom(CapProj::default()), Transform::default()))
        .id();
    if exp.msaa_off {
        commands.entity(cam).insert(Msaa::Off);
    }
    commands.spawn((
        Text::new("YAMAMOTO 山本 284"),
        TextFont { font_size: bevy::text::FontSize::Px(22.0), ..default() },
        Node { position_type: PositionType::Absolute, top: Val::Px(12.0), left: Val::Px(16.0), ..default() },
    ));
    let px = windows.iter().next().map(|w| (w.physical_width(), w.physical_height())).unwrap_or((0, 0));
    say(&format!(
        "m0a: {} meshes {} verts, {} frames, slots toon {nt} hull {nh} hull-cw {nc}, {left_out} lit/transparent draws left out, render px {}x{}",
        cap.meshes.len(),
        nverts,
        cap.frames.len(),
        px.0,
        px.1
    ));
    say(&format!("m0a: exp msaa_off {} empty {} static {}", exp.msaa_off, exp.empty, exp.still));
    say("m0a: left out of the toon shader: point lights (stage pools, the character's warm shadow); Frame lanes frozen at frame 0");
    commands.insert_resource(Replay { cap, meshes: mh, frame_lanes: fl, toon, hull, hull_cw, cam, frame: 0, worst_affine: 0.0 });
}

/// One sim step: the next captured frame's draws onto the preallocated slots, its camera onto the Camera3d.
fn replay(
    mut r: ResMut<Replay>,
    mut q: Query<(&mut GlobalTransform, &mut Visibility, &mut Mesh3d)>,
    exp: Res<Exp>,
    mut cams: Query<(&mut Transform, &mut Projection), Without<Mesh3d>>,
    mut toon_m: ResMut<Assets<ToonMaterial>>,
    mut hull_m: ResMut<Assets<HullMaterial>>,
    mut hull_cw_m: ResMut<Assets<HullCwMaterial>>,
) {
    let r = &mut *r;
    if exp.still && r.frame > 0 {
        return;
    }
    let f = &r.cap.frames[r.frame];
    let (mut it, mut ih, mut ic) = (0usize, 0usize, 0usize);
    let mut worst = r.worst_affine;
    macro_rules! put {
        ($slots:expr, $i:ident, $assets:expr, $d:expr, $m:expr) => {{
            let s = &mut $slots[$i];
            $i += 1;
            if let Ok((mut t, mut v, mut mesh)) = q.get_mut(s.e) {
                // the model matrix as it is (shear included): written straight into GlobalTransform; the slot's Transform
                // never changes, so Bevy's propagation leaves it alone
                let tr = Transform::from_matrix($m);
                let err = (tr.to_matrix() - $m).to_cols_array().iter().fold(0.0f32, |a, &b| a.max(b.abs()));
                worst = worst.max(err);
                *t = GlobalTransform::from(bevy::math::Affine3A::from_mat4($m));
                *v = if exp.empty { Visibility::Hidden } else { Visibility::Inherited };
                if s.mesh != $d.mesh {
                    if let Some(h) = r.meshes.get(&$d.mesh) {
                        mesh.0 = h.clone();
                    }
                    s.mesh = $d.mesh;
                }
            }
            let lanes = draw_lanes(&r.frame_lanes, &$d.rec);
            if lanes != s.lanes {
                if let Some(mut mat) = $assets.get_mut(&s.mat) {
                    mat.lanes = lanes;
                }
                s.lanes = lanes;
            }
        }};
    }
    for d in &f.draws {
        let m = Mat4::from_cols_slice(&d.rec[0..16]);
        match pool_of(d.pipe, &m) {
            Some(Pool::Toon) => put!(r.toon, it, toon_m, d, m),
            Some(Pool::Hull) => put!(r.hull, ih, hull_m, d, m),
            Some(Pool::HullCw) => put!(r.hull_cw, ic, hull_cw_m, d, m),
            None => {}
        }
    }
    let hidden = r.toon[it..].iter().map(|s| s.e).chain(r.hull[ih..].iter().map(|s| s.e)).chain(r.hull_cw[ic..].iter().map(|s| s.e));
    for e in hidden {
        if let Ok((_, mut v, _)) = q.get_mut(e) {
            *v = Visibility::Hidden;
        }
    }
    if worst > r.worst_affine + 1e-3 {
        say(&format!("m0a: model matrices with shear (drawn through GlobalTransform): max TRS error {worst:.4}"));
    }
    r.worst_affine = worst;
    // camera: eye = Frame.cam, forward through the screen centre (inv_vp); clip_from_view = VP x V^-1 (V^-1 = the camera's
    // world transform), z flipped for reverse-Z
    let fu = &f.fu;
    let vp = Mat4::from_cols_slice(&fu[0..16]);
    let inv_vp = Mat4::from_cols_slice(&fu[16..32]);
    let eye = Vec3::from_slice(&fu[32..35]);
    let fwd = (inv_vp.project_point3(Vec3::new(0.0, 0.0, 0.5)) - eye).normalize();
    let ct = Transform::from_translation(eye).looking_to(fwd, Vec3::Y);
    let zflip = Mat4::from_cols(Vec4::X, Vec4::Y, Vec4::new(0.0, 0.0, -1.0, 0.0), Vec4::new(0.0, 0.0, 1.0, 1.0));
    if let Ok((mut t, mut p)) = cams.get_mut(r.cam) {
        *t = ct;
        if let Projection::Custom(c) = &mut *p {
            if let Some(cp) = c.get_mut::<CapProj>() {
                cp.m = zflip * vp * ct.to_matrix();
            }
        }
    }
    r.frame = (r.frame + 1) % r.cap.frames.len();
}

/// The frozen build's console lines: `startup: heap ..` once after the warm-up, `perf: ..` every 2 s (render.c r_timing's format).
fn perf(mut p: ResMut<Perf>, r: Option<Res<Replay>>) {
    let now = now_ms();
    p.frames += 1;
    if p.frames == WARM_FRAMES {
        let h = heap_mb();
        say(&format!("startup: heap {h:.1} MB, wasm memory {h:.1} MB"));
        p.started = Some(now);
        (p.win_t0, p.win_n, p.win_sum, p.win_max, p.last) = (now, 0, 0.0, 0.0, now);
        return;
    }
    let Some(st) = p.started else { return };
    let dt = now - p.last;
    p.last = now;
    if dt > 1000.0 {
        // hidden / unfocused: the window restarts, so the hidden time is not a frame (Review Focus 4)
        (p.win_t0, p.win_n, p.win_sum, p.win_max) = (now, 0, 0.0, 0.0);
        return;
    }
    p.win_n += 1;
    p.win_sum += dt;
    p.win_max = p.win_max.max(dt);
    if now - p.win_t0 >= 2000.0 && p.win_n > 0 {
        let avg = p.win_sum / p.win_n as f64;
        let draws = r.as_ref().map_or(0, |r| r.cap.frames[r.frame].draws.len());
        say(&format!(
            "perf: startup {st:.0} ms | frame {avg:.1} ms avg ({:.1} fps) max {:.1} | render-scale 1.00 pixel-lights 0 | draws {draws} tris 0",
            1000.0 / avg,
            p.win_max
        ));
        (p.win_t0, p.win_n, p.win_sum, p.win_max) = (now, 0, 0.0, 0.0);
    }
}
