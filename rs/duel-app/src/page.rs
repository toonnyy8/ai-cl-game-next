//! The page contract (docs/bevy/BEVY_PORT.md §3 "Browser"): debug commands from `Module._debug_cmd(n)`, the console lines
//! tools/run.mjs reads (`startup: heap ..`, `perf: ..`, M0a's formats), and the camera setup every view needs.
use bevy::light::cluster::GlobalClusterSettings;
use bevy::prelude::*;
use std::collections::VecDeque;
use std::sync::Mutex;

pub use crate::render::camera::camera_bundle;

/// Commands from JS between frames: the exported function cannot reach the World, so the driver (main.rs) takes them each update
/// (`take_debug`) into the Match's command queue.
static PENDING: Mutex<VecDeque<i32>> = Mutex::new(VecDeque::new());

/// The debug commands that arrived since the last call, in order (each logged `debug N`, as M0's drain did).
pub fn take_debug(mut f: impl FnMut(i32)) {
    for n in PENDING.lock().unwrap().drain(..) {
        say(&format!("debug {n}"));
        f(n);
    }
}

/// `Module._debug_cmd(n)` (index.html: `window.Module._debug_cmd = n => wasm.debug_cmd(n)`).
#[cfg_attr(target_arch = "wasm32", wasm_bindgen::prelude::wasm_bindgen)]
pub fn debug_cmd(n: i32) {
    PENDING.lock().unwrap().push_back(n);
}

/// Platform log: the browser console on wasm (plain text, no tracing prefix: run.mjs matches line starts), stdout natively.
pub fn say(s: &str) {
    #[cfg(target_arch = "wasm32")]
    web_sys::console::log_1(&s.into());
    #[cfg(not(target_arch = "wasm32"))]
    println!("{s}");
}

/// Milliseconds since the page started (performance.now: run.mjs's virtual clock under --fixed-dt) or the process started.
pub fn now_ms() -> f64 {
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

/// The wasm linear memory in MB (0 natively).
pub fn heap_mb() -> f64 {
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

/// Frames drawn before `startup:` (M0a: the pipelines compile during load).
const WARM_FRAMES: u32 = 12;

pub struct PagePlugin;

impl Plugin for PagePlugin {
    fn build(&self, app: &mut App) {
        app.init_resource::<Perf>().add_systems(Startup, no_light_clustering).add_systems(Last, perf);
    }
}

/// No light clustering (docs/bevy/M0_NOTES.md §1): Bevy 0.20.1's GPU clustering makes new GPU buffers per view per frame and
/// wgpu's web backend never destroys a dropped buffer, so headless Chrome's GPU process dies after ~700-900 frames. Both halves
/// are needed: this, and `ClusterConfig::None` on every camera (`camera_bundle`); either alone fails. The port draws no Bevy
/// lights (the toon shader takes its own lanes), so nothing is lost.
fn no_light_clustering(mut s: ResMut<GlobalClusterSettings>) {
    s.gpu_clustering = None;
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

/// The frozen build's console lines: `startup: heap ..` once after the warm-up, `perf: ..` every 2 s (render.c r_timing's format).
fn perf(mut p: ResMut<Perf>) {
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
        // hidden / unfocused: the window restarts, so the hidden time is not a frame
        (p.win_t0, p.win_n, p.win_sum, p.win_max) = (now, 0, 0.0, 0.0);
        return;
    }
    p.win_n += 1;
    p.win_sum += dt;
    p.win_max = p.win_max.max(dt);
    if now - p.win_t0 >= 2000.0 {
        let avg = p.win_sum / p.win_n as f64;
        say(&format!(
            "perf: startup {st:.0} ms | frame {avg:.1} ms avg ({:.1} fps) max {:.1} | render-scale 1.00 pixel-lights 0 | draws 0 tris 0",
            1000.0 / avg,
            p.win_max
        ));
        (p.win_t0, p.win_n, p.win_sum, p.win_max) = (now, 0, 0.0, 0.0);
    }
}
