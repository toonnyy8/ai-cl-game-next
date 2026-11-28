// split.wgsl — the composite's split (render.lisp *GRADE-SPLIT* and *GRADE-CUT*; included by composite.frag.wgsl and
// composite-fx.frag.wgsl). SHEAR and C are in window heights: C = the cut's point (x, y from the centre), its angle (the line's
// direction (cos, sin), y down) and OPEN; OPEN < 0 = no cut: the old split, the left half moved up by SHEAR and the right half down
// along the vertical centre line. With a cut, the side its normal (d.y, -d.x) points to is moved by OPEN along the normal and SHEAR
// along the line, the other side the opposite way; between them a void 2 x OPEN wide, black, its outer 0.3 x OPEN on each side white.
// Returns the uv to sample (xy) and what the pixel shows (z): 1 the image, 0 black (outside the frame, the void), 2 white (its edges).
fn split_uv(uv: vec2f, shear: f32, C: vec4f, aspect: f32) -> vec3f {
  if (C.w < 0.0) {
    let s = vec2f(uv.x, uv.y + select(-shear, shear, uv.x < 0.5));   // (the old split, unchanged)
    return vec3f(s, f32(s.y >= 0.0 && s.y <= 1.0));
  }
  let q = vec2f((uv.x - 0.5) * aspect, uv.y - 0.5);
  let d = vec2f(cos(C.z), sin(C.z));
  let n = vec2f(d.y, -d.x);
  let dist = dot(q - C.xy, n);
  if (abs(dist) < C.w) { return vec3f(uv, select(0.0, 2.0, abs(dist) > 0.7 * C.w)); }
  let p = q - sign(dist) * (C.w * n + shear * d);
  let s = vec2f(p.x / aspect + 0.5, p.y + 0.5);
  return vec3f(s, f32(s.x >= 0.0 && s.x <= 1.0 && s.y >= 0.0 && s.y <= 1.0));
}
