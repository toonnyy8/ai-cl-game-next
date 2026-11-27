/* stubs-draw.c — the draw key's recorder (docs/bevy/M3A_NOTES.md §1; the M3a plan's Task 1): the simgate C layer
   (tools/simgate/stubs.c, unchanged) with r_mesh_new keeping every mesh's floats, r_frame recording all nine arrays and the cosmetic
   RNG state at the frames DRAW_FRAMES lists, a viewport from the environment and the real HUD atlas. Widened from M0a's
   tools/port/capture/stubs-capture.c (which stays as it is). Built by gen.py draw:
     SG_STUBS=tools/port/oracle/stubs-draw.c ecl-host --norc --load tools/simgate/build.lisp -- build/oracle/draw-img/duel.fas
   (from the repo root: the atlas's .incbin paths below are relative to the assembler's working directory).

   Environment:
     DRAW_FRAMES  the frames to key, counted in r_frame calls since the process started (startup calls none, so frame 0 is the first
                  %FRAME): a comma list of items "a", "a-b" (both ends kept) or "a-b/k" (a, a+k, ... <= b). Required.
     DRAW_OUT     the .bin to write. Required.
     DRAW_W / DRAW_H / DRAW_DPR   pf_width / pf_height / pf_density (defaults 1280 / 720 / 1, the stock stub's).
   Lines (stdout): "draw: rng at start 0x<rng_state>" at the first pf_pump (the scene's start: after startup, before frame 0's
   draws); "draw: <made> meshes made, <drawn> drawn, <n> frames -> <path>" once the file is written.
   After the last listed frame the file is written and the recorder sets DRAW_DONE=1 in the environment (draw.lisp polls it with
   EXT:GETENV after each frame, names the meshes and exits 0); the frame returns as usual.

   Format (little-endian; this header is authoritative):
     "SDDRW1\0\0", u32 width, u32 height, u32 n_meshes, u32 n_frames;
     per mesh (only those the keyed frames draw, by id ascending): u32 id, u32 n_floats, then the f32s exactly as r_mesh_new got
       them (n_floats = 9 x its vertices: position, normal, sRGB colour);
     per keyed frame, in order: u32 frame, u32 tick (ENGINE::*TICK*), u32 rng_state (rng_float's xorshift32 state, engine/c/rng.c,
       as r_frame was called), then for each array in this order: fu (160), p (30), dq (n x 32), fxa, fxb, ui, ft, hb, hk:
       u32 n_floats and the f32s. (r_frame's own argument order is fu p dq fxa fxb ui ft hb hk; render.lisp END-FRAME. A dq record's
       mesh id is (int) record[23].)
   r_frame returns n (the browser's draw count; it only feeds *DRAW-COUNT*, the stats line and r_timing, which returns 0). */
#define r_mesh_new sg_unused_r_mesh_new
#define r_frame sg_unused_r_frame
#define pf_width sg_unused_pf_width
#define pf_height sg_unused_pf_height
#define pf_density sg_unused_pf_density
#define lhud_font sg_unused_lhud_font
#define pf_pump sg_pf_pump
#include "tools/simgate/stubs.c"
#undef r_mesh_new
#undef r_frame
#undef pf_width
#undef pf_height
#undef pf_density
#undef lhud_font
#undef pf_pump

/* the stock pump, observed: its first call (the first %FRAME's poll, after startup) prints the cosmetic RNG's state there, the start
   state duel_look::CosRng takes ("draw: rng at start 0x..."). Nothing else changes. */
int pf_pump(float *f, float maxdt, int lock) {
  static int first = 1;
  if (first) { first = 0; printf("draw: rng at start 0x%08x\n", rng_state); fflush(stdout); }
  return sg_pf_pump(f, maxdt, lock);
}

static long dr_env(const char *k, long d) { const char *s = getenv(k); return s && *s ? atol(s) : d; }
int pf_width(void) { return (int)dr_env("DRAW_W", 1280); }
int pf_height(void) { return (int)dr_env("DRAW_H", 720); }
float pf_density(void) { const char *s = getenv("DRAW_DPR"); return s && *s ? (float)atof(s) : 1.0f; }

/* duel/hud-font/lhud-font.c's lhud_font with the same two files: that file uses #embed, which the host gcc (13) lacks, so the bytes
   come in through the assembler's .incbin (the stock stub returns none: no glyphs, the HUD streams stay empty natively) */
__asm__(".section .rodata\n.balign 4\ndr_lhud_atlas:\n.incbin \"duel/hud-font/atlas.r8\"\ndr_lhud_atlas_end:\n"
        ".balign 4\ndr_lhud_metrics:\n.incbin \"duel/hud-font/metrics.bin\"\ndr_lhud_metrics_end:\n.previous\n");
extern const unsigned char dr_lhud_atlas[], dr_lhud_atlas_end[], dr_lhud_metrics[], dr_lhud_metrics_end[];
const unsigned char *lhud_font(int k, int *n) {
  *n = k ? (int)(dr_lhud_metrics_end - dr_lhud_metrics) : (int)(dr_lhud_atlas_end - dr_lhud_atlas);
  return k ? dr_lhud_metrics : dr_lhud_atlas;
}

typedef struct { int n; float *v; } DrMesh;
static DrMesh *dr_mesh = 0; static int dr_nmesh = 0, dr_mcap = 0;
static unsigned char *dr_used = 0; static int dr_ucap = 0;       /* meshes the keyed frames draw: only those are written */
static unsigned char *dr_want = 0; static long dr_last = -1;     /* the keyed frames (a bitmap) and the last one */
static long dr_calls = 0; static unsigned dr_frames = 0; static int dr_done = 0;
static FILE *dr_tmp = 0;                                         /* the frames as they come (the meshes go first in the file) */

int r_mesh_new(const float *v, int n) {
  if (dr_nmesh == dr_mcap) { dr_mcap = dr_mcap * 2 + 64; dr_mesh = realloc(dr_mesh, dr_mcap * sizeof(DrMesh)); if (!dr_mesh) exit(5); }
  dr_mesh[dr_nmesh].n = n;
  dr_mesh[dr_nmesh].v = malloc((size_t)n * 9 * sizeof(float) + 1);
  if (!dr_mesh[dr_nmesh].v) exit(5);
  memcpy(dr_mesh[dr_nmesh].v, v, (size_t)n * 9 * sizeof(float));
  return dr_nmesh++;
}

static void dr_parse(void) {   /* DRAW_FRAMES -> dr_want, dr_last; exit 7 on a malformed list */
  const char *s = getenv("DRAW_FRAMES");
  if (!s || !*s) { fprintf(stderr, "draw: DRAW_FRAMES unset\n"); exit(7); }
  for (int pass = 0; pass < 2; pass++) {
    const char *p = s;
    while (*p) {
      char *e; long a = strtol(p, &e, 10), b = a, k = 1;
      if (e == p || a < 0) { fprintf(stderr, "draw: bad DRAW_FRAMES at '%s'\n", p); exit(7); }
      p = e;
      if (*p == '-') { b = strtol(p + 1, &e, 10); if (e == p + 1 || b < a) exit(7); p = e; }
      if (*p == '/') { k = strtol(p + 1, &e, 10); if (e == p + 1 || k < 1) exit(7); p = e; }
      if (*p == ',') p++; else if (*p) { fprintf(stderr, "draw: bad DRAW_FRAMES at '%s'\n", p); exit(7); }
      for (long f = a; f <= b; f += k) { if (pass) dr_want[f] = 1; else if (f > dr_last) dr_last = f; }
    }
    if (!pass) { dr_want = calloc((size_t)dr_last + 1, 1); if (!dr_want) exit(5); }
  }
}

static void dr_put(const void *p, size_t n) { if (fwrite(p, 1, n, dr_tmp) != n) exit(6); }
static void dr_u32(unsigned x) { dr_put(&x, 4); }
static void dr_arr(const float *v, int n) { dr_u32((unsigned)n); if (n > 0) dr_put(v, (size_t)n * sizeof(float)); }

static unsigned dr_tick(void) {   /* ENGINE::*TICK* (a fixnum; time.lisp) */
  static cl_object sym = 0;
  if (!sym) sym = ecl_make_symbol("*TICK*", "ENGINE");
  return (unsigned)ecl_fixnum(ecl_symbol_value(sym));
}

static void dr_write(void) {
  const char *out = getenv("DRAW_OUT"); FILE *f; static char buf[1 << 16]; size_t k;
  unsigned nused = 0;
  if (!out || !*out) { fprintf(stderr, "draw: DRAW_OUT unset\n"); exit(7); }
  f = fopen(out, "wb"); if (!f) { fprintf(stderr, "draw: cannot write %s\n", out); exit(6); }
  for (int i = 0; i < dr_nmesh && i < dr_ucap; i++) nused += dr_used[i];
  fwrite("SDDRW1\0\0", 1, 8, f);
  { unsigned h[4] = { (unsigned)pf_width(), (unsigned)pf_height(), nused, dr_frames }; fwrite(h, 4, 4, f); }
  for (int i = 0; i < dr_nmesh && i < dr_ucap; i++) {
    if (!dr_used[i]) continue;
    unsigned h[2] = { (unsigned)i, (unsigned)dr_mesh[i].n * 9 }; fwrite(h, 4, 2, f);
    fwrite(dr_mesh[i].v, sizeof(float), (size_t)dr_mesh[i].n * 9, f);
  }
  rewind(dr_tmp);
  while ((k = fread(buf, 1, sizeof buf, dr_tmp)) > 0) if (fwrite(buf, 1, k, f) != k) exit(6);
  if (fclose(f)) exit(6);
  fclose(dr_tmp);
  printf("draw: %d meshes made, %u drawn, %u frames -> %s\n", dr_nmesh, nused, dr_frames, out); fflush(stdout);
}

int r_frame(const float *fu, const float *rp, const float *dq, int n, const float *fxa, int nfa, const float *fxb, int nfb,
            const float *ui, int nui, const float *fxt, int nft, const float *hud, int nhud, const float *hudb, int nhudb) {
  long fr = dr_calls++;
  if (dr_done) return n;
  if (!dr_want) { dr_parse(); dr_tmp = tmpfile(); if (!dr_tmp) exit(6); }
  if (fr > dr_last || !dr_want[fr]) return n;
  dr_u32((unsigned)fr); dr_u32(dr_tick()); dr_u32(rng_state);
  dr_arr(fu, 160); dr_arr(rp, 30); dr_arr(dq, n * 32);
  for (int i = 0; i < n; i++) {
    int id = (int)dq[32 * i + 23];
    if (id >= dr_ucap) { int nc = id * 2 + 64; dr_used = realloc(dr_used, nc); if (!dr_used) exit(5); memset(dr_used + dr_ucap, 0, nc - dr_ucap); dr_ucap = nc; }
    if (id >= 0) dr_used[id] = 1;
  }
  dr_arr(fxa, nfa); dr_arr(fxb, nfb); dr_arr(ui, nui); dr_arr(fxt, nft); dr_arr(hud, nhud); dr_arr(hudb, nhudb);
  dr_frames++;
  if (fr == dr_last) { dr_write(); dr_done = 1; setenv("DRAW_DONE", "1", 1); }
  return n;
}
