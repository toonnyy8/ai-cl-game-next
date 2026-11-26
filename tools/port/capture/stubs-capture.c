/* stubs-capture.c — the simgate C layer (tools/simgate/stubs.c) plus a recorder for the Bevy port's speed test
   (docs/bevy/plans/2026-11-26-m0a-speed-test.md, Task 2): r_mesh_new keeps every mesh's vertices, r_frame records the
   frames [CAP_F0, CAP_F0 + CAP_N) (counted in r_frame calls; env, defaults 600 / 240) and writes them to CAP_OUT
   (default build/port/capture/frames.bin), then exits 0. Format (little-endian):
     "SDCAP1\0\0", u32 n_meshes, u32 n_frames;
     per mesh (only those the recorded frames draw) u32 id, u32 n_verts, n_verts * 9 f32 (+vertex-floats+: pos, normal, sRGB colour);
     per frame u32 tick, 160 f32 (fu: struct Frame), u32 n_draws, per draw u32 mesh_id, u32 pipe, 32 f32 (struct Draw).
   mesh_id = (int) record[23] and pipe as render.c r_draw_queue picks it: 0 lit, 1 toon, 2 ink hull (record[28] < 0.5 / > 2.5),
   +3 when transparent (record[19] < 0.999: drawn lit). Built by: SG_STUBS=tools/port/capture/stubs-capture.c tools/simgate/build.lisp. */
#define r_mesh_new sg_unused_r_mesh_new
#define r_frame sg_unused_r_frame
#include "tools/simgate/stubs.c"
#undef r_mesh_new
#undef r_frame

typedef struct { int n; float *v; } CapMesh;
static CapMesh *cap_mesh = 0; static int cap_nmesh = 0, cap_mcap = 0;
static unsigned char *cap_buf = 0; static size_t cap_len = 0, cap_cap = 0;
static long cap_calls = 0; static int cap_frames = 0;
static unsigned char *cap_used = 0; static int cap_ucap = 0;   /* meshes the recorded frames draw: only those are written */

static void cap_put(const void *p, size_t n) {
  if (cap_len + n > cap_cap) { cap_cap = (cap_len + n) * 2 + 4096; cap_buf = realloc(cap_buf, cap_cap); if (!cap_buf) exit(5); }
  memcpy(cap_buf + cap_len, p, n); cap_len += n;
}
static void cap_u32(unsigned x) { cap_put(&x, 4); }
static long cap_env(const char *k, long d) { const char *s = getenv(k); return s && *s ? atol(s) : d; }

int r_mesh_new(const float *v, int n) {
  if (cap_nmesh == cap_mcap) { cap_mcap = cap_mcap * 2 + 64; cap_mesh = realloc(cap_mesh, cap_mcap * sizeof(CapMesh)); if (!cap_mesh) exit(5); }
  cap_mesh[cap_nmesh].n = n;
  cap_mesh[cap_nmesh].v = malloc((size_t)n * 9 * sizeof(float));
  if (n && !cap_mesh[cap_nmesh].v) exit(5);
  memcpy(cap_mesh[cap_nmesh].v, v, (size_t)n * 9 * sizeof(float));
  return cap_nmesh++;
}

static void cap_write(void) {
  const char *out = getenv("CAP_OUT"); FILE *f;
  if (!out || !*out) out = "build/port/capture/frames.bin";
  f = fopen(out, "wb"); if (!f) { fprintf(stderr, "capture: cannot write %s\n", out); exit(6); }
  int nused = 0;
  for (int i = 0; i < cap_nmesh && i < cap_ucap; i++) nused += cap_used[i];
  fwrite("SDCAP1\0\0", 1, 8, f);
  { unsigned h[2] = { (unsigned)nused, (unsigned)cap_frames }; fwrite(h, 4, 2, f); }
  for (int i = 0; i < cap_nmesh; i++) {
    if (i >= cap_ucap || !cap_used[i]) continue;
    unsigned h[2] = { (unsigned)i, (unsigned)cap_mesh[i].n }; fwrite(h, 4, 2, f);
    fwrite(cap_mesh[i].v, sizeof(float), (size_t)cap_mesh[i].n * 9, f);
  }
  fwrite(cap_buf, 1, cap_len, f); fclose(f);
  printf("capture: %d meshes made, %d drawn, %d frames -> %s\n", cap_nmesh, nused, cap_frames, out); fflush(stdout);
}

int r_frame(const float *fu, const float *rp, const float *dq, int n, const float *fxa, int nfa, const float *fxb, int nfb,
            const float *ui, int nui, const float *fxt, int nft, const float *hud, int nhud, const float *hudb, int nhudb) {
  long f0 = cap_env("CAP_F0", 600), nf = cap_env("CAP_N", 240);
  (void)rp; (void)fxa; (void)nfa; (void)fxb; (void)nfb; (void)ui; (void)nui; (void)fxt; (void)nft; (void)hud; (void)nhud; (void)hudb; (void)nhudb;
  if (cap_calls++ < f0) return n;
  cap_u32((unsigned)(cap_calls - 1)); cap_put(fu, 160 * sizeof(float)); cap_u32((unsigned)n);
  for (int i = 0; i < n; i++) {
    const float *q = dq + 32 * i;
    int tr = q[19] < 0.999f;
    int id = (int)q[23];
    if (id >= cap_ucap) { int nc = id * 2 + 64; cap_used = realloc(cap_used, nc); if (!cap_used) exit(5); memset(cap_used + cap_ucap, 0, nc - cap_ucap); cap_ucap = nc; }
    if (id >= 0) cap_used[id] = 1;
    cap_u32((unsigned)id);
    cap_u32((unsigned)(tr ? 3 : q[28] < 0.5f ? 0 : q[28] > 2.5f ? 2 : 1));
    cap_put(q, 32 * sizeof(float));
  }
  if (++cap_frames >= nf) { cap_write(); exit(0); }
  return n;
}
