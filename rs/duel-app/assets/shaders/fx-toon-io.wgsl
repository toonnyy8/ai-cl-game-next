// fx-toon-io.wgsl — shared by fx-toon.vert.wgsl and fx-toon.frag.wgsl (the toon fx batch, RP_FXT).
// col = the vertex's heat, seed, wobble; pk = palette + presence (flat: a toon call passes one value).
struct FxT {
  @builtin(position) pos: vec4f,
  @location(0) uv: vec2f, @location(1) col: vec3f,
  @location(2) @interpolate(flat) pk: f32,
  @location(3) fog: f32,
}
// The pk lane (a toon call's palette argument carries the flags by addition): palette p 0..15 + presence k (the fraction)
// + 16 a fan shape + 32 g a glass level (g 0..3) + 128 the FLAME FLAG (STYLE_STORM_DESIGN §15.8: +TOON-FLAME+, fx-shapes.lisp;
// the Lisp side sets it only on the borderline tongue auras). PK_NOFLAG strips the flag: every decoder reads the glass from it.
fn pk_noflag(pk: f32) -> f32 { return select(pk, pk - 128.0, pk >= 128.0); }
// Soft flame (docs/style/STYLE_STORM_DESIGN.md §15): the flame-class shapes that get the feathered fringe, the continuous
// flow and the flame layer (§15.6). PK = the vertex's pk lane, SEED = its seed lane (< 0: an along shape). The flame flag
// always (§15.8); the fire style (palettes 0 FIRE, 1 EMBER, 15 FLAME) always; REIATSU (2) only as an along shape (the
// aura's tongues and its ring: not Kenpachi's comet smear or the hit stamps).
fn soft_class(pk: f32, seed: f32) -> bool {
  let pk0 = pk - 32.0 * floor(pk / 32.0);
  let p = u32(select(pk0, pk0 - 16.0, pk0 >= 16.0));
  return pk >= 128.0 || p == 0u || p == 1u || p == 15u || (p == 2u && seed < 0.0);
}
