// flame-bright.frag.wgsl — RP_BRIGHT_FL: bright.frag.wgsl's bloom step 1 on a frame with the flame layer (STYLE_STORM_DESIGN
// §15.6). At 0.8 a flame over a dark stage falls out of the warm gate's value band, so the glow (P.y) is gated and weighted on
// the pixel the single pass would have drawn: the layer (t1, premultiplied) laid fully over the scene, so the halo stays as at
// 1 (a glass flame keeps its weaker glow). The threshold term reads the scene as composited. P.x = threshold, P.y = flame glow, P.z = the layer's opacity.
// #include "fullscreen.vert.wgsl"
@group(3) @binding(0) var<uniform> P: vec4f;
@group(2) @binding(0) var t0: texture_2d<f32>;
@group(2) @binding(1) var s0: sampler;
@group(2) @binding(2) var t1: texture_2d<f32>;
@group(2) @binding(3) var s1: sampler;
fn warm(c: vec3f) -> f32 {   // ponytail: bright.frag.wgsl's gate, copied (that file stays as it was: its pipeline's output must not move)
  let m = max(c.r, max(c.g, c.b));
  return smoothstep(0.45, 0.65, (m - min(c.r, min(c.g, c.b))) / max(m, 1e-4)) * step(c.b + 0.15, c.r) * smoothstep(0.8, 0.95, m);
}
@fragment fn fs_bright_fl(i: Post) -> @location(0) vec4f {
  let c = textureSample(t0, s0, i.uv).rgb;
  let l = textureSample(t1, s1, i.uv);
  let b = (c - P.z * l.rgb) / max(1.0 - P.z * l.a, 1e-3);   // the scene behind the layer (c = b (1 - P.z a) + P.z layer)
  let g = l.rgb + b * (1.0 - l.a);                   // the pixel as the single pass would have drawn it (the layer opaque)
  let m = max(c.r, max(c.g, c.b));
  let w = P.y * warm(g);
  if (l.a <= 0.0) { return vec4f(c * (smoothstep(P.x, 1.0, m) + w), 1.0); }   // no flame: bright.frag's sum exactly
  return vec4f(c * smoothstep(P.x, 1.0, m) + g * w, 1.0);
}
