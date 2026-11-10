// hud.frag.wgsl — the paint stream's modes (p.x), docs/duel/DUEL_LISP_HUD.md §4.1 and §10:
//  0 flat (the vertex colour; a polygon's AA: p.y = 1, uv.x = the signed distance to the triangle's outer edge in local units,
//    > 0 inside, p.z / p.w the same for its two neighbours (1e4 = none); each divided by its screen gradient is the exact distance
//    in pixels under any affine transform, and the coverage takes the nearest);
//  1 SDF glyph (uv in the atlas; p.y the edge, 0.5 = the baked weight, lower = bolder; p.z the softness, 1 = a one-pixel edge, more
//    = blurred; p.w > 0: only an outline band that wide);
//  2 rounded box (uv = local units from its centre; p.yz the half size, p.w the radius, q.x the feather in screen pixels, 1 = an
//    antialiased edge, large = a soft shadow / glow; q.y > 0: only a border that wide, local units);
//  3 ellipse / ring / arc (uv local units from the centre; p.yz the radii, p.w > 0: a ring that thick (local), q.x the feather in
//    screen pixels, q.y in (0, 1): only that fraction clockwise from the top, butt ends; q.z < 0: counter-clockwise).
// Patterns, modes 0 and 1 only (q.w): > 0 halftone dots on the screen grid, pitch q.w px, radius q.x px (a one-pixel soft edge);
//  < 0 stripes (mode 0): pitch -q.w local units along uv.y (the pattern coordinate set per vertex), lines q.x wide starting at
//  uv.y = 0 (box-filtered); the coverage is multiplied in. Local-unit sizes go to pixels by the uv's screen derivatives, taken
//  before any branch (WGSL's uniformity rule for textureSample, dpdx / dpdy and fwidth), so a scaled or rotated shape keeps a
//  one-pixel edge.
struct HudV { @builtin(position) pos: vec4f, @location(0) uv: vec2f, @location(1) col: vec4f, @location(2) p: vec4f, @location(3) q: vec4f }
@group(2) @binding(0) var atlas: texture_2d<f32>;
@group(2) @binding(1) var smp: sampler;
@fragment fn fs_hud(i: HudV) -> @location(0) vec4f {
  let d = textureSample(atlas, smp, i.uv).r;
  let fw = max(fwidth(d), 0.00001);
  let gx = dpdx(i.uv); let gy = dpdy(i.uv);
  let lpp = max(sqrt(abs(gx.x * gy.y - gx.y * gy.x)), 0.00001);   // local units per pixel (similarity transforms: exact)
  let g0 = max(length(vec2f(gx.x, gy.x)), 0.00001);               // |screen gradient| of uv.x (mode 0's edge distance)
  let g1 = max(length(vec2f(gx.y, gy.y)), 0.00001);               // |screen gradient| of uv.y (the stripes' coordinate)
  let hx = dpdx(i.p.zw); let hy = dpdy(i.p.zw);                    // mode 0: the neighbour edges' distances
  let gz = max(length(vec2f(hx.x, hy.x)), 0.00001); let gw = max(length(vec2f(hx.y, hy.y)), 0.00001);
  var cov = 1.0;
  if (i.p.x < 0.5) {
    if (i.p.y > 0.5) { cov = clamp(min(i.uv.x / g0, min(i.p.z / gz, i.p.w / gw)) + 0.5, 0.0, 1.0); }
  } else if (i.p.x < 1.5) {
    let aa = fw * max(i.p.z, 0.001);
    cov = clamp((d - i.p.y) / aa + 0.5, 0.0, 1.0);
    if (i.p.w > 0.0) { cov = cov * clamp((i.p.y + i.p.w - d) / aa + 0.5, 0.0, 1.0); }
  } else if (i.p.x < 2.5) {
    let k = abs(i.uv) - (i.p.yz - vec2f(i.p.w));
    let dist = (length(max(k, vec2f(0.0))) + min(max(k.x, k.y), 0.0) - i.p.w) / lpp;
    let f = max(i.q.x, 0.001);
    cov = clamp(0.5 - dist / f, 0.0, 1.0);
    if (i.q.y > 0.0) { cov = cov * clamp(0.5 + (dist + i.q.y / lpp) / f, 0.0, 1.0); }
  } else {
    let r = max(i.p.yz, vec2f(0.0001));
    let e = length(i.uv / r);
    let ge = length(i.uv / (r * r));
    let dist = select((e - 1.0) * e / max(ge, 0.00001), -min(r.x, r.y), e < 0.0001) / lpp;   // circles exact, ellipses close
    let f = max(i.q.x, 0.001);
    cov = clamp(0.5 - dist / f, 0.0, 1.0);
    if (i.p.w > 0.0) { cov = cov * clamp(0.5 + (dist + i.p.w / lpp) / f, 0.0, 1.0); }
    if (i.q.y > 0.0 && i.q.y < 1.0) {
      let tau = 6.2831853;
      var a = atan2(i.uv.x * sign(i.q.z + 0.5), -i.uv.y);
      if (a < 0.0) { a = a + tau; }
      let fa = i.q.y * tau;
      let da = select(-min(a - fa, tau - a), min(a, fa - a), a <= fa);
      cov = cov * clamp(da * length(i.uv) / lpp + 0.5, 0.0, 1.0);
    }
  }
  if (i.p.x < 1.5 && i.q.w != 0.0) {
    if (i.q.w > 0.0) {
      let c = i.pos.xy - (floor(i.pos.xy / i.q.w) + 0.5) * i.q.w;
      cov = cov * clamp(i.q.x + 0.5 - length(c), 0.0, 1.0);
    } else {
      // box filter over one pixel: the cumulative line coverage F(x) = floor(x / pitch) w + clamp(x mod pitch, 0, w)
      let pitch = -i.q.w; let w = i.q.x; let h = 0.5 * g1;
      let x0 = i.uv.y - h; let x1 = i.uv.y + h;
      let f0 = floor(x0 / pitch) * w + clamp(x0 - floor(x0 / pitch) * pitch, 0.0, w);
      let f1 = floor(x1 / pitch) * w + clamp(x1 - floor(x1 / pitch) * pitch, 0.0, w);
      cov = cov * clamp((f1 - f0) / g1, 0.0, 1.0);
    }
  }
  return vec4f(i.col.rgb, i.col.a * cov);
}
