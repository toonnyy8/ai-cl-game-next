// bright.frag.wgsl — bloom step 1: keep the bright part of the scene (half resolution).
// P.y = the soft flame's glow (docs/style/STYLE_STORM_DESIGN.md §15, 0 = off): saturated warm bright pixels (the fire
// palettes' bodies, REIATSU's yellow) add P.y x their colour to what blooms, so the flames get a little halo after the blur.
// A prototype gate by hue: any other saturated warm bright pixel (an orange costume in full light) glows with them.
// #include "fullscreen.vert.wgsl"
@group(3) @binding(0) var<uniform> P: vec4f;
@group(2) @binding(0) var t0: texture_2d<f32>;
@group(2) @binding(1) var s0: sampler;
@fragment fn fs_bright(i: Post) -> @location(0) vec4f {   // P.x = threshold, P.y = flame glow
  let c = textureSample(t0, s0, i.uv).rgb;
  let m = max(c.r, max(c.g, c.b));
  let warm = smoothstep(0.45, 0.65, (m - min(c.r, min(c.g, c.b))) / max(m, 1e-4)) * step(c.b + 0.15, c.r) * smoothstep(0.8, 0.95, m);
  return vec4f(c * (smoothstep(P.x, 1.0, m) + P.y * warm), 1.0);
}
