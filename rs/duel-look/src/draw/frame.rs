//! port: engine/lisp/render.lisp's frame half — what END-FRAME hands `r_frame`: the frame uniforms (FILL-FRAME-UNIFORMS,
//! FILL-TOON-UNIFORMS), the post parameters (END-FRAME's `*rp*`), the point lights (SELECT-LIGHTS), and the environment they read
//! (the ENVIRONMENT struct's defaults, then duel/lisp/stage.lisp STAGE-ENV). The queues themselves are `queue.rs`.
use super::camera::Camera;
use duel_sim::cl::{min_f32, musl_powf, round_f32};
use duel_sim::math::{f_max, f_mod, f_sqrt};

/// `+fu-floats+`: the WGSL Frame struct.
pub const FU_FLOATS: usize = 160;
/// `*rp*`'s length.
pub const P_FLOATS: usize = 30;
/// `+dq-stride+`: the WGSL Draw struct.
pub const DQ_STRIDE: usize = 32;
/// `+max-lights+`, `+max-light-candidates+`.
pub const MAX_LIGHTS: usize = 8;
pub const MAX_LIGHT_CANDIDATES: usize = 64;
/// The first `*dq*`'s records (DRAW-MESH doubles it when full: `FrameOut.dq` grows the same way; the ruling R5).
pub const DQ_RESERVE: usize = 1024;

/// The arrays `r_frame` gets (render.lisp END-FRAME), kept across frames as the Lisp keeps its buffers: `fu`, `p` and the selected
/// lights are rewritten each frame (stale light slots past the count stay, as `*lp*` / `*lc*` do), the queues are emptied by
/// `begin` (BEGIN-FRAME). Every buffer is reserved once; nothing grows in steady state.
pub struct FrameOut {
    pub fu: [f32; FU_FLOATS],
    pub p: [f32; P_FLOATS],
    pub dq: Vec<[f32; DQ_STRIDE]>,
    /// The vertex streams (fills in floats): `*fx-alpha*`, `*fx-add*`, `*ui-batch*`, `*fx-toon*`, `*hud-batch*`, `*hud-back*`.
    pub fxa: Vec<f32>,
    pub fxb: Vec<f32>,
    pub ui: Vec<f32>,
    pub ft: Vec<f32>,
    pub hb: Vec<f32>,
    pub hk: Vec<f32>,
    /// `*light-cand*` (x y z radius r g b score) and `*light-n*`: this frame's candidates.
    pub(crate) light_cand: [f32; 8 * MAX_LIGHT_CANDIDATES],
    pub(crate) light_n: usize,
    /// `*lp*` / `*lc*`: the selected lights (never cleared).
    lp: [f32; 4 * MAX_LIGHTS],
    lc: [f32; 4 * MAX_LIGHTS],
}

impl Default for FrameOut {
    fn default() -> Self {
        // (the streams' MAKE-STREAM-BUFFER sizes: render.lisp RENDER-INIT 9 x 16384, ui.lisp 8 x 32768, paint.lisp 16 x 32768,
        // paint-shapes.lisp 16 x 8192: STREAM-ROOM-P's caps)
        FrameOut {
            fu: [0.0; FU_FLOATS],
            p: [0.0; P_FLOATS],
            dq: Vec::with_capacity(DQ_RESERVE),
            fxa: Vec::with_capacity(9 * 16384),
            fxb: Vec::with_capacity(9 * 16384),
            ui: Vec::with_capacity(8 * 32768),
            ft: Vec::with_capacity(9 * 16384),
            hb: Vec::with_capacity(16 * 32768),
            hk: Vec::with_capacity(16 * 8192),
            light_cand: [0.0; 8 * MAX_LIGHT_CANDIDATES],
            light_n: 0,
            lp: [0.0; 4 * MAX_LIGHTS],
            lc: [0.0; 4 * MAX_LIGHTS],
        }
    }
}

impl FrameOut {
    /// port: render.lisp BEGIN-FRAME's queue half (its UPDATE-CAMERA: `Camera::update`, called where the frame needs it).
    pub fn begin(&mut self) {
        self.dq.clear();
        self.light_n = 0;
        for s in [&mut self.fxa, &mut self.fxb, &mut self.ft, &mut self.ui, &mut self.hb, &mut self.hk] {
            s.clear();
        }
    }
}

/// port: render.lisp SRGB->LIN: `powf(fmaxf(c, 0), 2.2f)` (musl's powf).
pub fn srgb_lin(c: f32) -> f32 {
    musl_powf(f_max(c, 0.0), 2.2)
}

/// port: engine/lisp/meshgen.lisp HEXC with K 1: #xRRGGBB -> (r g b), each `(min 1.0 (* 1.0 (/ byte 255.0)))`.
pub fn hexc(h: u32) -> [f32; 3] {
    let ch = |s: u32| min_f32(1.0, 1.0 * (((h >> s) & 0xff) as f32 / 255.0));
    [ch(16), ch(8), ch(0)]
}

/// port: engine/lisp/math.lisp V3-NORMALIZE! (sqrtf of the dot; a zero vector stays zero).
fn v3_normalize(a: [f32; 3]) -> [f32; 3] {
    let l = f_sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]); // (sqrtf of a sum of squares)
    if l > 1e-12 {
        let s = 1.0 / l;
        [a[0] * s, a[1] * s, a[2] * s]
    } else {
        [0.0; 3]
    }
}

/// port: render.lisp ENVIRONMENT (all colours sRGB 0..1; intensities multiply them).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Env {
    pub sky_top: [f32; 3],
    pub fog_color: [f32; 3],
    pub fog_density: f32,
    pub fog_base: f32,
    pub fog_falloff: f32,
    pub fog_max: f32,
    pub ambient_sky: [f32; 3],
    pub ambient_ground: [f32; 3],
    pub ambient_intensity: f32,
    pub moon_dir: [f32; 3],
    pub moon_color: [f32; 3],
    pub moon_intensity: f32,
    pub sun_size: f32,
    pub sun_glow: f32,
    pub rim_color: [f32; 3],
    pub rim_intensity: f32,
    pub rim_power: f32,
    pub specular: f32,
    pub shininess: f32,
    pub exposure: f32,
    pub bloom: bool,
    pub bloom_threshold: f32,
    pub bloom_strength: f32,
    pub vignette: f32,
    pub toon: bool,
    pub key_light: [f32; 3],
    pub toon_threshold: f32,
    pub toon_band: f32,
    pub toon_gradient: f32,
    pub toon_gradient_height: f32,
    pub toon_light_gain: f32,
    pub shade_value: f32,
    pub shade_saturation: f32,
    pub shade_hue: f32,
    pub shade_lift: f32,
    pub cin_rim: [f32; 3],
    pub cin_width: f32,
}

impl Default for Env {
    /// port: render.lisp (defstruct environment)'s slot defaults.
    fn default() -> Self {
        Env {
            sky_top: [0.035, 0.03, 0.10],
            fog_color: [0.20, 0.13, 0.34],
            fog_density: 0.028,
            fog_base: 0.0,
            fog_falloff: 0.08,
            fog_max: 1.0,
            ambient_sky: [0.30, 0.30, 0.55],
            ambient_ground: [0.12, 0.07, 0.14],
            ambient_intensity: 0.45,
            moon_dir: v3_normalize([-0.35, 0.55, -0.75]),
            moon_color: [0.65, 0.72, 1.0],
            moon_intensity: 0.5,
            sun_size: 1.0,
            sun_glow: 0.25,
            rim_color: [0.35, 0.55, 1.0],
            rim_intensity: 0.35,
            rim_power: 3.0,
            specular: 0.5,
            shininess: 48.0,
            exposure: 1.2,
            bloom: true,
            bloom_threshold: 0.62,
            bloom_strength: 0.9,
            vignette: 0.35,
            toon: false,
            key_light: [-0.45, 0.62, 0.40],
            toon_threshold: 0.5,
            toon_band: 0.02,
            toon_gradient: 0.14,
            toon_gradient_height: 1.8,
            toon_light_gain: 0.45,
            shade_value: 0.72,
            shade_saturation: 1.25,
            shade_hue: 8.0,
            shade_lift: 0.25,
            cin_rim: [0.0; 3],
            cin_width: 0.16,
        }
    }
}

impl Env {
    /// port: duel/lisp/stage.lisp STAGE-ENV — night: the toon look on, the cold sky and fog, the moon behind the arena, bloom on the
    /// effect cores only, a vignette (START-GAME; CINE-END again).
    pub fn stage_env(&mut self) {
        self.sky_top = hexc(0x1A1E2A);
        self.fog_color = hexc(0x363B4C);
        self.moon_color = hexc(0xD6DAE0);
        self.moon_dir = v3_normalize([-0.3, 0.16, -0.92]);
        self.toon = true;
        (self.fog_density, self.fog_base, self.fog_falloff, self.fog_max) = (0.012, 0.0, 0.06, 0.92);
        (self.moon_intensity, self.sun_size, self.sun_glow) = (1.0, 6.0, 0.012);
        (self.exposure, self.bloom, self.bloom_threshold, self.bloom_strength) = (1.0, true, 0.97, 0.6);
        self.vignette = 0.25;
    }
}

/// The render globals END-FRAME reads besides the environment (render.lisp's defvars; the composite's grade and the soft flame).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Post {
    /// `*grade-desat*`, `*grade-split*`, `*grade-impact*` and its `*impact-params*`, `*grade-cut*` (a one-frame latch),
    /// `*render-transparent*` (a one-frame latch).
    pub grade_desat: f32,
    pub grade_split: f32,
    pub grade_impact: i32,
    pub impact_params: [f32; 10],
    pub grade_cut: [f32; 5],
    pub render_transparent: bool,
    /// `*soft-flame*` (0..3), `*soft-flame-knobs*` (tuning), `*flame-alpha*`.
    pub soft_flame: usize,
    pub soft_flame_knobs: [f32; 8],
    pub flame_alpha: f32,
    /// `*fx-clock*`[0]: the fx clock in seconds (FX-CLOCK-ADVANCE).
    pub fx_clock: f32,
}

impl Post {
    /// The defvars' values at load, RENDER-INIT's `(grade-impact 0)` applied; `*soft-flame-knobs*` from tuning.json.
    pub fn new(d: &duel_data::Data) -> Post {
        let knobs: Vec<f32> = d.tuning["*SOFT-FLAME-KNOBS*"].as_array().expect("tuning *SOFT-FLAME-KNOBS*").iter().map(|x| x.as_f64().unwrap() as f32).collect();
        let mut p = Post {
            grade_desat: 0.0,
            grade_split: 0.0,
            grade_impact: 0,
            impact_params: [0.0; 10],
            grade_cut: [0.0; 5],
            render_transparent: false,
            soft_flame: 2, // port: render.lisp *SOFT-FLAME* 2 (the user, 2026-11-20)
            soft_flame_knobs: knobs.try_into().expect("*SOFT-FLAME-KNOBS*: 8 floats"),
            flame_alpha: 0.8, // port: render.lisp *FLAME-ALPHA* 0.8 (the user, 2026-11-20)
            fx_clock: 0.0,
        };
        p.grade_impact(0);
        p
    }

    /// port: render.lisp GRADE-IMPACT with its keyword defaults (threshold 0.4, keep-sat 0.45, keep-hue 10, keep-hue-2 = keep-hue,
    /// ink (0.031 0.031 0.047), paper (1 1 1)). ponytail: the other presets' keywords come with their callers (Task 6's impact frames).
    pub fn grade_impact(&mut self, mode: i32) {
        self.grade_impact = mode;
        self.impact_params = [0.4, 0.45, 10.0, 0.031, 0.031, 0.047, 1.0, 1.0, 1.0, 10.0];
    }
}

/// port: render.lisp SCENE-SCALE.
fn scene_scale(render_scale: f32, cap: f32) -> f32 {
    if cap < 1.0 { min_f32(render_scale, cap) } else { render_scale }
}

/// port: render.lisp END-FRAME's `*rp*` (before SELECT-LIGHTS): the latches are cleared.
pub fn fill_post(out: &mut FrameOut, env: &Env, post: &mut Post, ww: u32, wh: u32, render_scale: f32, scale_cap: f32) {
    let p = &mut out.p;
    let ss = scene_scale(render_scale, scale_cap);
    p[0] = if env.bloom { 1.0 } else { 0.0 };
    (p[1], p[2], p[3]) = (env.bloom_threshold, env.bloom_strength, env.vignette);
    p[4] = round_f32(ww as f32 * ss).max(1) as f32;
    p[5] = round_f32(wh as f32 * ss).max(1) as f32;
    (p[6], p[7], p[8], p[9]) = (ww as f32, wh as f32, post.grade_desat, post.grade_split);
    p[10] = if env.toon { 1.0 } else { 0.0 };
    p[11] = post.grade_impact as f32;
    p[23] = post.soft_flame_knobs[1 + 2 * post.soft_flame];
    p[24] = post.flame_alpha;
    p[12..22].copy_from_slice(&post.impact_params);
    p[25..30].copy_from_slice(&post.grade_cut);
    post.grade_cut = [0.0; 5];
    p[22] = if post.render_transparent { 1.0 } else { 0.0 };
    post.render_transparent = false;
}

/// port: render.lisp SELECT-LIGHTS — up to 8 of the frame's candidates into `*lp*` / `*lc*` (a light whose sphere lies outside the
/// view frustum first dropped: its score set to the largest float); the count.
pub fn select_lights(out: &mut FrameOut, cam: &Camera) -> usize {
    let (n, m) = (out.light_n, &cam.view_proj);
    let c = &mut out.light_cand;
    for i in 0..n {
        let o = i * 8;
        let (x, y, z, r) = (c[o], c[o + 1], c[o + 2], c[o + 3]);
        for j in 0..3 {
            for sg in [1.0f32, -1.0] {
                let pa = m[3] + sg * m[j];
                let pb = m[7] + sg * m[4 + j];
                let pc = m[11] + sg * m[8 + j];
                let pd = m[15] + sg * m[12 + j];
                if pa * x + pb * y + pc * z + pd < -(r * f_sqrt(pa * pa + pb * pb + pc * pc)) {
                    c[o + 7] = f32::MAX;
                }
            }
        }
    }
    let mut k = 0;
    while k < MAX_LIGHTS && k < n {
        let (mut best, mut bs) = (usize::MAX, f32::MAX);
        for i in 0..n {
            let s = c[i * 8 + 7];
            if s < bs {
                (bs, best) = (s, i);
            }
        }
        if best == usize::MAX {
            break;
        }
        let (o, d) = (best * 8, k * 4);
        out.lp[d..d + 4].copy_from_slice(&c[o..o + 4]);
        out.lc[d..d + 3].copy_from_slice(&c[o + 4..o + 7]);
        let r = c[o + 3];
        out.lc[d + 3] = 1.0 / (r * r);
        c[o + 7] = f32::MAX;
        k += 1;
    }
    k
}

/// port: render.lisp FILL-FRAME-UNIFORMS (NL = the point lights used), with FILL-TOON-UNIFORMS while the environment is toon.
/// PIXEL_LIGHTS `*pixel-lights*`, MSAA `*msaa-samples*`.
pub fn fill_frame_uniforms(out: &mut FrameOut, env: &Env, post: &Post, cam: &Camera, nl: usize, pixel_lights: u32, msaa: u32) {
    let u = &mut out.fu;
    let lin3 = |u: &mut [f32; FU_FLOATS], o: usize, v: [f32; 3], k: f32, w: f32| {
        (u[o], u[o + 1], u[o + 2], u[o + 3]) = (k * srgb_lin(v[0]), k * srgb_lin(v[1]), k * srgb_lin(v[2]), w);
    };
    u[0..16].copy_from_slice(&cam.view_proj);
    u[16..32].copy_from_slice(&cam.inv_view_proj);
    (u[32], u[33], u[34], u[35]) = (cam.eye[0], cam.eye[1], cam.eye[2], env.exposure);
    lin3(u, 36, env.fog_color, 1.0, env.fog_density);
    (u[40], u[41], u[42], u[43]) = (env.fog_base, env.fog_falloff, env.fog_max, 0.0);
    lin3(u, 44, env.ambient_sky, env.ambient_intensity, 0.0);
    lin3(u, 48, env.ambient_ground, env.ambient_intensity, 0.0);
    (u[52], u[53], u[54], u[55]) = (env.moon_dir[0], env.moon_dir[1], env.moon_dir[2], env.sun_size);
    lin3(u, 56, env.moon_color, env.moon_intensity, env.sun_glow);
    lin3(u, 60, env.rim_color, env.rim_intensity, env.rim_power);
    lin3(u, 64, env.sky_top, 1.0, 0.0);
    (u[68], u[69], u[70]) = (env.specular, env.shininess, nl as f32);
    u[71] = if env.toon { 2.0 } else { (pixel_lights as usize).min(MAX_LIGHTS) as f32 };
    u[72..104].copy_from_slice(&out.lp);
    u[104..136].copy_from_slice(&out.lc);
    if env.toon {
        fill_toon_uniforms(u, &out.p, env, post, cam, msaa);
    }
}

/// port: render.lisp FILL-TOON-UNIFORMS — the Frame's toon lanes 136..159: the key light in camera axes, the toon / shade knobs, the
/// scene size (`*rp*`), the cinematic back-rim, the fx clock in 24 Hz ticks, the toon fx discard threshold, the soft flame.
fn fill_toon_uniforms(u: &mut [f32; FU_FLOATS], p: &[f32; P_FLOATS], e: &Env, post: &Post, cam: &Camera, msaa: u32) {
    let (k, rt, up, fw) = (e.key_light, cam.right, cam.upv, cam.forward);
    let kx = k[0] * rt[0] + k[1] * up[0] - k[2] * fw[0];
    let ky = k[0] * rt[1] + k[1] * up[1] - k[2] * fw[1];
    let kz = k[0] * rt[2] + k[1] * up[2] - k[2] * fw[2];
    let l = f_max(1e-6, f_sqrt(kx * kx + ky * ky + kz * kz));
    (u[136], u[137], u[138], u[139]) = (kx / l, ky / l, kz / l, e.toon_threshold);
    (u[140], u[141], u[142], u[143]) = (e.toon_band, e.toon_gradient, e.toon_gradient_height, e.toon_light_gain);
    (u[144], u[145], u[146], u[147]) = (e.shade_value, e.shade_saturation, e.shade_hue, e.shade_lift);
    (u[148], u[149], u[150], u[151]) = (p[4], p[5], cam.proj[5], p[5] / 720.0);
    let c = e.cin_rim;
    (u[152], u[153], u[154], u[155]) = (srgb_lin(c[0]), srgb_lin(c[1]), srgb_lin(c[2]), e.cin_width);
    let clk = post.fx_clock;
    u[156] = duel_sim::cl::floor_f32(24.0 * clk) as i32 as f32; // (i->f (f->i x)): (int)floorf, then (float)
    u[157] = if msaa > 1 { 0.0 } else { 0.5 };
    u[158] = if post.soft_flame > 0 { f_mod(24.0 * clk, 6144.0) } else { -1.0 };
    u[159] = post.soft_flame_knobs[2 * post.soft_flame];
}
