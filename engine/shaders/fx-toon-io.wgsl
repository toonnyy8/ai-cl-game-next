// fx-toon-io.wgsl — shared by fx-toon.vert.wgsl and fx-toon.frag.wgsl (the toon fx batch, RP_FXT).
// col = the vertex's heat, seed, wobble; pk = palette + presence (flat: a toon call passes one value).
struct FxT {
  @builtin(position) pos: vec4f,
  @location(0) uv: vec2f, @location(1) col: vec3f,
  @location(2) @interpolate(flat) pk: f32,
  @location(3) fog: f32,
}
// Soft flame (docs/style/STYLE_STORM_DESIGN.md §15): the flame-class shapes that get the feathered fringe and the continuous
// flow. PK = the vertex's palette + presence lane (glass + 32 g, fan + 16), SEED = its seed lane (< 0: an along shape). The
// fire style (palettes 0 FIRE, 1 EMBER, 15 FLAME) always; REIATSU (2) only as an along shape (the aura's tongues and its
// ring: not Kenpachi's comet smear or the hit stamps). A prototype selector, chosen by the shader alone (no Lisp flag).
fn soft_class(pk: f32, seed: f32) -> bool {
  let pk0 = pk - 32.0 * floor(pk / 32.0);
  let p = u32(select(pk0, pk0 - 16.0, pk0 >= 16.0));
  return p == 0u || p == 1u || p == 15u || (p == 2u && seed < 0.0);
}
