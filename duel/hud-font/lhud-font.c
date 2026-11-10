/* lhud-font.c — the Lisp HUD's baked text atlas as static data (docs/duel/DUEL_LISP_HUD.md §4.2): tools/sdf-bake.py writes
   atlas.r8 (R8 texels) and metrics.bin next to this file; #embed (C23; clang accepts it in C17 as an extension) puts their bytes
   in the wasm's data section, so nothing is read or consed at load. lhud_font(0) = the atlas, (1) = the metrics, size in *N. */
#pragma clang diagnostic ignored "-Wc23-extensions"
static const unsigned char lhud_atlas[] = {
#embed "atlas.r8"
};
static _Alignas(4) const unsigned char lhud_metrics[] = {
#embed "metrics.bin"
};
const unsigned char *lhud_font(int k, int *n) {
  *n = k ? (int)sizeof lhud_metrics : (int)sizeof lhud_atlas;
  return k ? lhud_metrics : lhud_atlas;
}
