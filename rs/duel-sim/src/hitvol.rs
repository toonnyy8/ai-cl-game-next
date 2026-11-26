//! Hit-volume geometry (engine/lisp/hitvol.lisp): does an attack volume touch a hurt cylinder? Pure single-float functions
//! (every literal there is a single). Hurt volumes are vertical cylinders (radius tr, height th) standing on (tx ty tz).
#![allow(clippy::too_many_arguments)]
use crate::cl::{max_f32, min_f32};
use crate::math::{fwd_x, fwd_z};

/// port: engine/lisp/hitvol.lisp MAKE-VOL's six floats: [type, p1..p4, p5]; type 0 ARC (r half-angle y0 y1), 1 CAP (a b h r
/// yaw), 2 SPH (fwd up r), 3 TSPH (r). duel-data carries them made (`MoveDef::vols`).
pub type Vol = [f32; 6];

/// port: engine/lisp/hitvol.lisp VOL-HIT-P (attacker at (ax ay az) facing (fx 0 fz); for TSPH (ax ay az) is the target point).
pub fn vol_hit_p(
    v: &Vol,
    ax: f32,
    ay: f32,
    az: f32,
    fx: f32,
    fz: f32,
    tx: f32,
    ty: f32,
    tz: f32,
    tr: f32,
    th: f32,
    extra: f32,
) -> bool {
    let ty_ = v[0];
    if ty_ < 0.5 {
        // ARC
        let (r, half, y0, y1) = (v[1] + extra, v[2], ay + v[3], ay + v[4]);
        let (dx, dz) = (tx - ax, tz - az);
        let d = libm::sqrtf(dx * dx + dz * dz);
        d <= r + tr
            && y0 <= ty + th
            && y1 >= ty
            && (half >= 3.1 || d < tr + 0.05 || {
                let c = (dx * fx + dz * fz) / d;
                let s = tr / d;
                let c = c.clamp(-1.0, 1.0); // = the Lisp's nested IFs, NaN and -0.0 included
                libm::acosf(c) <= half + libm::asinf(if s > 1.0 { 1.0 } else { s })
            })
    } else if ty_ < 1.5 {
        // CAP: closest point on the segment; a yawed cap turns its own axis
        let (mut fx, mut fz) = (fx, fz);
        let yo = v[5];
        if yo != 0.0 {
            let (c, sn) = (libm::cosf(yo), libm::sinf(yo));
            (fx, fz) = (fx * c + fz * sn, fz * c - fx * sn);
        }
        let (a, b, h, r) = (v[1], v[2], ay + v[3], v[4]);
        let (dx, dz) = (tx - ax, tz - az);
        let along = dx * fx + dz * fz;
        let s = if along < a {
            a
        } else if along > b {
            b
        } else {
            along
        };
        let (ex, ez) = (tx - (ax + fx * s), tz - (az + fz * s));
        ex * ex + ez * ez <= (r + tr) * (r + tr) && h >= ty - r && h <= ty + th + r
    } else {
        // SPH / TSPH: sphere vs cylinder
        let sph = ty_ < 2.5;
        let (f, u, r) = if sph {
            (v[1], v[2], v[3])
        } else {
            (0.0, 1.1, v[1])
        };
        let (cx, cy, cz) = (ax + fx * f, ay + u, az + fz * f);
        let (dx, dz) = (tx - cx, tz - cz);
        let (lo, hi) = (ty + tr, ty + th - tr);
        let dy = if cy < lo {
            lo - cy
        } else if cy > hi {
            cy - hi
        } else {
            0.0
        };
        dx * dx + dz * dz + dy * dy <= (r + tr) * (r + tr)
    }
}

/// port: engine/lisp/hitvol.lisp CAPSULE-CYL-HIT-P (the cylinder as a capsule of radius tr from ty+tr to ty+th-tr).
pub fn capsule_cyl_hit_p(
    ax: f32,
    ay: f32,
    az: f32,
    bx: f32,
    by: f32,
    bz: f32,
    r: f32,
    tx: f32,
    ty: f32,
    tz: f32,
    tr: f32,
    th: f32,
) -> bool {
    let lo = ty + min_f32(tr, 0.5 * th);
    let hi = max_f32(lo, ty + th - tr);
    let (d1x, d1y, d1z, d2y) = (bx - ax, by - ay, bz - az, hi - lo);
    let (rx, ry, rz) = (ax - tx, ay - lo, az - tz);
    let a = d1x * d1x + d1y * d1y + d1z * d1z;
    let e = d2y * d2y;
    let f = d2y * ry;
    let c = d1x * rx + d1y * ry + d1z * rz;
    let b = d1y * d2y;
    let unit = |x: f32| max_f32(0.0, min_f32(1.0, x));
    let (mut s, mut u) = (0.0f32, 0.0f32);
    if a <= 1e-8 && e <= 1e-8 {
    } else if a <= 1e-8 {
        u = unit(f / e);
    } else if e <= 1e-8 {
        s = unit(-c / a);
    } else {
        let den = a * e - b * b;
        s = if den > 1e-8 {
            unit((b * f - c * e) / den)
        } else {
            0.0
        };
        u = (b * s + f) / e;
        if u < 0.0 {
            u = 0.0;
            s = unit(-c / a);
        } else if u > 1.0 {
            u = 1.0;
            s = unit((b - c) / a);
        }
    }
    let (dx, dy, dz) = (rx + d1x * s, ry + d1y * s - d2y * u, rz + d1z * s);
    let rr = r + tr;
    dx * dx + dy * dy + dz * dz <= rr * rr
}

/// port: engine/lisp/hitvol.lisp OBOX-CYL-HIT-P (a yaw-only box: half-width hw, half-height hh, half-length hl).
pub fn obox_cyl_hit_p(
    cx: f32,
    cy: f32,
    cz: f32,
    yaw: f32,
    hw: f32,
    hh: f32,
    hl: f32,
    tx: f32,
    ty: f32,
    tz: f32,
    tr: f32,
    th: f32,
) -> bool {
    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
    let (dx, dz) = (tx - cx, tz - cz);
    let lx = dx * -fz + dz * fx;
    let lz = dx * fx + dz * fz;
    let ex = lx - max_f32(-hw, min_f32(hw, lx));
    let ez = lz - max_f32(-hl, min_f32(hl, lz));
    ex * ex + ez * ez <= tr * tr && cy - hh <= ty + th && cy + hh >= ty
}

/// port: engine/lisp/hitvol.lisp CYL-CYL-HIT-P.
pub fn cyl_cyl_hit_p(
    ax: f32,
    ay: f32,
    az: f32,
    ar: f32,
    ah: f32,
    bx: f32,
    by: f32,
    bz: f32,
    br: f32,
    bh: f32,
) -> bool {
    let (dx, dz, rr) = (bx - ax, bz - az, ar + br);
    dx * dx + dz * dz <= rr * rr && ay <= by + bh && by <= ay + ah
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::cl::vectors::rows;

    fn f(r: &crate::cl::vectors::Row) -> Vec<f32> {
        r.args.iter().map(|t| t.s()).collect()
    }

    #[test]
    fn hit_volumes_match_lisp() {
        for r in rows("vol-hit-p") {
            let a = f(&r);
            let v: Vol = a[0..6].try_into().unwrap();
            let got = vol_hit_p(
                &v, a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15], a[16],
            );
            assert_eq!(got, r.out[0].b(), "vol-hit-p {a:?}");
        }
        for r in rows("capsule-cyl-hit-p") {
            let a = f(&r);
            let got = capsule_cyl_hit_p(
                a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11],
            );
            assert_eq!(got, r.out[0].b(), "capsule {a:?}");
        }
        for r in rows("obox-cyl-hit-p") {
            let a = f(&r);
            let got = obox_cyl_hit_p(
                a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11],
            );
            assert_eq!(got, r.out[0].b(), "obox {a:?}");
        }
        for r in rows("cyl-cyl-hit-p") {
            let a = f(&r);
            let got = cyl_cyl_hit_p(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
            assert_eq!(got, r.out[0].b(), "cyl-cyl {a:?}");
        }
    }
}
