// hud.vert.wgsl — the paint stream (paint.lisp, docs/duel/DUEL_LISP_HUD.md §4.1): 16 floats a vertex, pixels -> clip space.
// a = position xy (pixels, origin top-left, y down) + uv; c = sRGB colour, straight alpha; p, q = the mode and its parameters.
struct HudV { @builtin(position) pos: vec4f, @location(0) uv: vec2f, @location(1) col: vec4f, @location(2) p: vec4f, @location(3) q: vec4f }
@group(1) @binding(0) var<uniform> S: vec4f;   // framebuffer size in pixels
@vertex fn vs_hud(@location(0) a: vec4f, @location(1) c: vec4f, @location(2) p: vec4f, @location(3) q: vec4f) -> HudV {
  var o: HudV;
  o.pos = vec4f(a.x / S.x * 2.0 - 1.0, 1.0 - a.y / S.y * 2.0, 0.0, 1.0); o.uv = a.zw; o.col = c; o.p = p; o.q = q;
  return o;
}
