// fx-toon.vert.wgsl — the toon fx batch (docs/style/STYLE_STORM_DESIGN.md §3.2): vertex = position, uv,
// (heat, seed, wobble, palette + presence). Fog is passed on: it tints the colour, never the coverage
// (alpha-to-coverage would punch holes).
// #include "frame.wgsl"
@group(1) @binding(0) var<uniform> F: Frame;
// #include "fx-toon-io.wgsl"
fn fxt_vert(p: vec3f, uv: vec2f, c: vec4f) -> FxT {
  var o: FxT;
  o.pos = F.vp * vec4f(p, 1.0); o.uv = uv; o.col = c.rgb; o.pk = c.a; o.fog = fog_amount(p);
  return o;
}
@vertex fn vs_fx_toon(@location(0) p: vec3f, @location(1) uv: vec2f, @location(2) c: vec4f) -> FxT { return fxt_vert(p, uv, c); }
// The soft flame's fringe pass (RP_FXT_F, §15): the same vertices; a shape outside SOFT_CLASS, or every shape while the
// feather is off (F.clk.w 0), is moved outside the clip volume, so its fragments never run twice.
@vertex fn vs_fx_toon_f(@location(0) p: vec3f, @location(1) uv: vec2f, @location(2) c: vec4f) -> FxT {
  var o = fxt_vert(p, uv, c);
  if (F.clk.w <= 0.0 || !soft_class(c.a, c.g)) { o.pos = vec4f(0.0, 0.0, 2.0, 1.0); }
  return o;
}
// The flame layer (§15.6, *FLAME-ALPHA* < 1): RP_FXT_N draws every toon fx shape but the flame class in the scene pass,
// RP_FXT_L only the flame class into the layer (the other shapes moved outside the clip volume, as above).
@vertex fn vs_fx_toon_n(@location(0) p: vec3f, @location(1) uv: vec2f, @location(2) c: vec4f) -> FxT {
  var o = fxt_vert(p, uv, c);
  if (soft_class(c.a, c.g)) { o.pos = vec4f(0.0, 0.0, 2.0, 1.0); }
  return o;
}
@vertex fn vs_fx_toon_l(@location(0) p: vec3f, @location(1) uv: vec2f, @location(2) c: vec4f) -> FxT {
  var o = fxt_vert(p, uv, c);
  if (!soft_class(c.a, c.g)) { o.pos = vec4f(0.0, 0.0, 2.0, 1.0); }
  return o;
}
