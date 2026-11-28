// composite.frag.wgsl — final image on the swapchain: scene + bloom (1/2 and 1/4 levels) + vignette,
// then desaturation toward luma (P.z = *GRADE-DESAT*; 0 leaves the color exactly as it was).
// P[0].w = *GRADE-SPLIT* / window height and P[1] = *GRADE-CUT* (split.wgsl): the frame split in two halves moved
// apart; what falls outside the frame is black. 0 and P[1].w < 0 = the plain image.
// #include "fullscreen.vert.wgsl"
// #include "split.wgsl"
@group(3) @binding(0) var<uniform> P: array<vec4f, 2>;
@group(2) @binding(0) var t0: texture_2d<f32>;
@group(2) @binding(1) var s0: sampler;
@group(2) @binding(2) var t1: texture_2d<f32>;
@group(2) @binding(3) var s1: sampler;
@group(2) @binding(4) var t2: texture_2d<f32>;
@group(2) @binding(5) var s2: sampler;
@fragment fn fs_comp(i: Post) -> @location(0) vec4f {    // P[0].x = bloom strength, .y = vignette, .z = desaturate, .w = split
  let dim = vec2f(textureDimensions(t0));
  let k = split_uv(i.uv, P[0].w, P[1], dim.x / dim.y);
  let uv = k.xy;
  let inside = f32(k.z == 1.0);
  var c = (textureSample(t0, s0, uv).rgb + (textureSample(t1, s1, uv).rgb * 0.6 + textureSample(t2, s2, uv).rgb) * P[0].x) * inside;
  let q = i.uv - 0.5;
  c *= 1.0 - P[0].y * dot(q, q) * 2.0;
  c = mix(c, vec3f(dot(c, vec3f(0.2126, 0.7152, 0.0722))), P[0].z);
  c = select(c, vec3f(1.0), k.z > 1.5);   // the cut's white edges
  return vec4f(c, 1.0);
}
// RP_COMP_A (*RENDER-TRANSPARENT*, docs/duel/DUEL_WEBUI.md §4; the user, 2026-10-28): fs_comp with the scene's alpha
// out, for a canvas configured premultiplied (no sky: the scene cleared to 0,0,0,0, its colour is premultiplied). Bloom
// and additive fx can leave colour above that alpha; the alpha rises to the brightest channel, so the output stays a
// valid premultiplied colour (a glow lightens the page behind it). fs_comp (alpha 1) is unchanged.
@fragment fn fs_comp_a(i: Post) -> @location(0) vec4f {
  let dim = vec2f(textureDimensions(t0));
  let k = split_uv(i.uv, P[0].w, P[1], dim.x / dim.y);
  let uv = k.xy;
  let inside = f32(k.z == 1.0);
  let s = textureSample(t0, s0, uv);
  var c = (s.rgb + (textureSample(t1, s1, uv).rgb * 0.6 + textureSample(t2, s2, uv).rgb) * P[0].x) * inside;
  let q = i.uv - 0.5;
  c *= 1.0 - P[0].y * dot(q, q) * 2.0;
  c = clamp(mix(c, vec3f(dot(c, vec3f(0.2126, 0.7152, 0.0722))), P[0].z), vec3f(0.0), vec3f(1.0));
  c = select(c, vec3f(1.0), k.z > 1.5);
  return vec4f(c, max(s.a * inside, max(c.r, max(c.g, c.b))));
}
