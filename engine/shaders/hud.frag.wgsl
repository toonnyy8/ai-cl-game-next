// hud.frag.wgsl — the paint stream's modes (p.x): 0 flat (the vertex colour); 1 SDF glyph (uv in the atlas; p.y the edge, 0.5 =
// the baked weight, lower = bolder; p.z the softness, 1 = a one-pixel edge, more = blurred; p.w > 0: only an outline band that
// wide); 2 rounded box (uv = pixels from its centre; p.yz the half size, p.w the radius, q.x the feather in pixels, 1 = an
// antialiased edge; q.y > 0: only a border that wide). The atlas is sampled and differentiated before any branch (WGSL's
// uniformity rule for textureSample and fwidth).
struct HudV { @builtin(position) pos: vec4f, @location(0) uv: vec2f, @location(1) col: vec4f, @location(2) p: vec4f, @location(3) q: vec4f }
@group(2) @binding(0) var atlas: texture_2d<f32>;
@group(2) @binding(1) var smp: sampler;
@fragment fn fs_hud(i: HudV) -> @location(0) vec4f {
  let d = textureSample(atlas, smp, i.uv).r;
  let fw = max(fwidth(d), 0.00001);
  var cov = 1.0;
  if (i.p.x > 0.5 && i.p.x < 1.5) {
    let aa = fw * max(i.p.z, 0.001);
    cov = clamp((d - i.p.y) / aa + 0.5, 0.0, 1.0);
    if (i.p.w > 0.0) { cov = cov * clamp((i.p.y + i.p.w - d) / aa + 0.5, 0.0, 1.0); }
  } else if (i.p.x > 1.5) {
    let k = abs(i.uv) - (i.p.yz - vec2f(i.p.w));
    let dist = length(max(k, vec2f(0.0))) + min(max(k.x, k.y), 0.0) - i.p.w;
    let f = max(i.q.x, 0.001);
    cov = clamp(0.5 - dist / f, 0.0, 1.0);
    if (i.q.y > 0.0) { cov = cov * clamp(0.5 + (dist + i.q.y) / f, 0.0, 1.0); }
  }
  return vec4f(i.col.rgb, i.col.a * cov);
}
