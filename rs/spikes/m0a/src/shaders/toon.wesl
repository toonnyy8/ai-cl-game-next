// toon.wesl — engine/shaders/toon.vert.wgsl + toon.frag.wgsl (+ frame.wgsl's fog) ported to a Bevy material for the M0a
// speed test (docs/bevy/plans/2026-11-26-m0a-speed-test.md). Same maths: SHADE_OF's designed shadow, the two-tone band on
// the key light (characters, Draw.toon.x 2) or the moon (stage, 1), the darker feet gradient, the cinematic back-rim, the
// emissive and hit-flash lanes, fog; vs_hull / fs_ink the ink hull. Left out (logged by the app): the point lights (the
// stage's per-pixel pools, the character's warm shadow), so `warm` and `dif` are 0. Output is linear: Bevy's view target
// is sRGB (the original wrote gamma into its own scene target and composited after).
import bevy_pbr::render::mesh_functions::{get_world_from_local, mesh_position_local_to_world};
import bevy_pbr::render::view_transformations::position_world_to_clip;

struct ToonLanes {
  tint: vec4f, fx: vec4f, toon: vec4f,      // the Draw record's lanes
  key: vec4f, toon_f: vec4f, shd: vec4f, cin: vec4f, fog: vec4f, fogh: vec4f, moon_dir: vec4f, cam: vec4f, scr: vec4f,   // Frame lanes
};
@group(constants::MATERIAL_BIND_GROUP) @binding(0) var<uniform> L: ToonLanes;

struct Vertex {
  @builtin(instance_index) ii: u32,
  @location(0) p: vec3f, @location(1) n: vec3f, @location(2) c: vec3f,
};
struct ToonV {
  @builtin(position) pos: vec4f,
  @location(0) wpos: vec3f, @location(1) nrm: vec3f, @location(2) col: vec3f, @location(3) shade: vec3f,
};

fn hsv(c: vec3f) -> vec3f {
  let k = vec4f(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  let p = mix(vec4f(c.bg, k.wz), vec4f(c.gb, k.xy), step(c.b, c.g));
  let q = mix(vec4f(p.xyw, c.r), vec4f(c.r, p.yzx), step(p.x, c.r));
  let d = q.x - min(q.w, q.y);
  return vec3f(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}
fn rgb(h: vec3f) -> vec3f {
  let p = abs(fract(h.xxx + vec3f(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
  return h.z * mix(vec3f(1.0), clamp(p - 1.0, vec3f(0.0), vec3f(1.0)), h.y);
}
fn shade_of(alb: vec3f) -> vec3f {
  var h = hsv(pow(alb, vec3f(1.0 / 2.2)));
  let warm = h.x < 0.19 || h.x > 0.83;
  if (h.y < 0.12) { h.x = 0.61; h.y = max(h.y * L.shd.y, 0.10); }
  else { h.x = fract(h.x + select(L.shd.z, -L.shd.z, warm) / 360.0); h.y = min(h.y * L.shd.y, 1.0); }
  h.z = h.z * L.shd.x;
  return pow(rgb(h), vec3f(2.2));
}
fn fog_amount(p: vec3f) -> f32 {
  let d = length(p - L.cam.xyz);
  let hf = 0.35 + 0.65 * exp(-max(p.y - L.fogh.x, 0.0) * L.fogh.y);
  return min(1.0 - exp(-d * L.fog.w * hf), L.fogh.z);
}

@vertex fn vs_toon(v: Vertex) -> ToonV {
  let m = get_world_from_local(v.ii);
  let wp = mesh_position_local_to_world(m, vec4f(v.p, 1.0));
  let a = m[0].xyz; let b = m[1].xyz; let e = m[2].xyz;
  let nm = mat3x3f(cross(b, e), cross(e, a), cross(a, b)) * v.n * select(1.0, -1.0, dot(a, cross(b, e)) < 0.0);
  var o: ToonV;
  o.pos = position_world_to_clip(wp.xyz);
  o.wpos = wp.xyz; o.nrm = nm; o.col = pow(v.c, vec3f(2.2));
  o.shade = shade_of(o.col * L.tint.rgb);
  return o;
}

@vertex fn vs_hull(v: Vertex) -> ToonV {
  let m = get_world_from_local(v.ii);
  let wp = (m * vec4f(v.p, 1.0)).xyz;
  let we = (m * vec4f(v.n, 0.0)).xyz / max(length(m[0].xyz), 1e-6);
  let depth = position_world_to_clip(wp).w;
  let mpp = 2.0 * depth / (L.scr.z * L.scr.y);
  let vd = normalize(L.cam.xyz - wp);
  let taper = mix(0.45, 1.0, 1.0 - abs(dot(normalize(we + vec3f(1e-6)), vd)));
  let q = wp + we * (clamp(L.toon.w * L.scr.w * mpp, 0.004, 0.03) * taper);
  var o: ToonV;
  o.pos = position_world_to_clip(q + normalize(q - L.cam.xyz) * L.toon.y);
  o.wpos = wp; o.nrm = we; o.col = pow(v.c, vec3f(2.2)); o.shade = vec3f(0.0);
  return o;
}

@fragment fn fs_toon(i: ToonV) -> @location(0) vec4f {
  let n = normalize(i.nrm);
  let alb = i.col * L.tint.rgb;
  let chr = L.toon.x > 1.5;
  let ld = select(L.moon_dir.xyz, L.key.xyz, chr);
  let th = select(0.5, L.key.w, chr);
  let lit = smoothstep(th - L.toon_f.x, th + L.toon_f.x, dot(n, ld) * 0.5 + 0.5);
  var sh = i.shade;
  if (!chr) { sh = mix(sh, alb, L.shd.w); }
  var c = mix(sh, alb, lit);
  let vv = normalize(L.cam.xyz - i.wpos);
  if (chr) {
    c *= mix(1.0 - L.toon_f.y, 1.0, clamp((i.wpos.y - L.toon.y) / L.toon_f.z, 0.0, 1.0));
    c += L.cin.rgb * step(1.0 - L.cin.w, 1.0 - max(dot(n, vv), 0.0));
  }
  c += alb * L.fx.x;
  c = mix(c, L.fog.rgb, fog_amount(i.wpos) * L.toon.z);
  c = clamp(c, vec3f(0.0), vec3f(1.0));
  return vec4f(mix(c, vec3f(1.0), L.fx.y), 1.0);
}

@fragment fn fs_ink(i: ToonV) -> @location(0) vec4f {
  let c = mix(i.col * L.tint.rgb, L.fog.rgb, fog_amount(i.wpos) * L.toon.z);
  return vec4f(clamp(c, vec3f(0.0), vec3f(1.0)), 1.0);
}
