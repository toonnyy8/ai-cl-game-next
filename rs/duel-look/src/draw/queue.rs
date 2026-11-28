//! port: engine/lisp/render.lisp's queues — DRAW-MESH (a 32-float record per draw, `*dq*` growing when full) and ADD-POINT-LIGHT
//! (%ADD-LIGHT: a candidate scored by its distance to the camera target).
use super::frame::{srgb_lin, FrameOut, DQ_STRIDE, MAX_LIGHT_CANDIDATES};
use duel_sim::math::f_sqrt;

/// DRAW-MESH's keywords (their defaults in `Default`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct DrawOpts {
    /// TINT (sRGB; linearised into the record), EMISSIVE, FLASH, ALPHA, SPECULAR (negative: the environment's).
    pub tint: Option<[f32; 3]>,
    pub emissive: f32,
    pub flash: f32,
    pub alpha: f32,
    pub specular: f32,
    /// RIM (3 linear floats), ENV-RIM.
    pub rim: Option<[f32; 3]>,
    pub env_rim: f32,
    /// TOON: the 4 toon lanes, or NIL (the lit shader).
    pub toon: Option<[f32; 4]>,
}

impl Default for DrawOpts {
    fn default() -> Self {
        DrawOpts { tint: None, emissive: 0.0, flash: 0.0, alpha: 1.0, specular: -1.0, rim: None, env_rim: 1.0, toon: None }
    }
}

/// port: render.lisp DRAW-MESH — queue mesh ID with world matrix MODEL (column-major). The record is WGSL Draw:
/// `[0..15 model][16..19 tint rgba][20 emissive 21 flash 22 specular 23 mesh id][24..26 rim, 27 env-rim][28..31 toon]`.
pub fn draw_mesh(out: &mut FrameOut, id: u32, model: &[f32; 16], o: &DrawOpts) {
    let mut q = [0.0f32; DQ_STRIDE];
    q[..16].copy_from_slice(model);
    (q[16], q[17], q[18]) = match o.tint {
        Some(t) => (srgb_lin(t[0]), srgb_lin(t[1]), srgb_lin(t[2])),
        None => (1.0, 1.0, 1.0),
    };
    (q[19], q[20], q[21], q[22], q[23], q[27]) = (o.alpha, o.emissive, o.flash, o.specular, id as f32, o.env_rim);
    if let Some(r) = o.rim {
        q[24..27].copy_from_slice(&r);
    }
    if let Some(t) = o.toon {
        q[28..32].copy_from_slice(&t);
    }
    out.dq.push(q); // (DRAW-MESH doubles a full *dq*: Vec's growth; reserved so steady state never grows)
}

/// port: render.lisp ADD-POINT-LIGHT (%ADD-LIGHT): a point light for this frame (sRGB colour, RADIUS m, INTENSITY K, PRIORITY): a
/// candidate while there is room and it is lit; its score (lower wins) is the distance to the camera target TG minus the radius,
/// minus 10000 per priority level.
#[allow(clippy::too_many_arguments)]
pub fn add_point_light(out: &mut FrameOut, tg: [f32; 3], x: f32, y: f32, z: f32, r: f32, g: f32, b: f32, radius: f32, k: f32, prio: i32) {
    let n = out.light_n;
    if n < MAX_LIGHT_CANDIDATES && k > 0.0 && radius > 0.0 {
        let (o, c) = (n * 8, &mut out.light_cand);
        let (dx, dy, dz) = (x - tg[0], y - tg[1], z - tg[2]);
        (c[o], c[o + 1], c[o + 2], c[o + 3]) = (x, y, z, radius);
        (c[o + 4], c[o + 5], c[o + 6]) = (k * srgb_lin(r), k * srgb_lin(g), k * srgb_lin(b));
        c[o + 7] = f_sqrt(dx * dx + dy * dy + dz * dz) - radius;
        if prio != 0 {
            c[o + 7] -= 10000.0 * prio as f32;
        }
        out.light_n = n + 1;
    }
}
