/* musl-hash.c — the answer key's musl libm over every single-float input, as one FNV-1a hash (the exhaustive checks in
 * rs/duel-sim/tests/cpu.rs: `expt2_equals_musl_on_every_input`, `expf_equals_musl_on_every_input`).
 * It dlopens build/simgate/muslm.so (tools/simlib.py builds it: the emsdk musl the native sim preloads, gcc -m32) with
 * RTLD_DEEPBIND, so its own symbols win inside it as under the sim's LD_PRELOAD (glibc's libm only answers its sqrtf).
 *   gcc -m32 -msse2 -mfpmath=sse -ffp-contract=off -O2 -o build/musl-hash tools/port/musl-hash.c -Wl,--no-as-needed -lm -ldl
 *   build/musl-hash expt2|expf [build/simgate/muslm.so]
 * expt2 = ECL's (EXPT X 2) of a single: X * 2 for a zero, else powf (X, 2.0). The hash: h = 0xcbf29ce484222325, then per input
 * bit pattern u = 0 .. 2^32 - 1: h ^= bits (f (u)), h *= 0x100000001b3 (64-bit). */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: %s expt2|expf [muslm.so]\n", argv[0]); return 2; }
  void *so = dlopen(argc > 2 ? argv[2] : "build/simgate/muslm.so", RTLD_NOW | RTLD_LOCAL | RTLD_DEEPBIND);
  if (!so) { fprintf(stderr, "%s\n", dlerror()); return 1; }
  int expt2 = !strcmp(argv[1], "expt2");
  float (*f1)(float) = (float (*)(float))dlsym(so, expt2 ? "powf" : argv[1]);
  float (*f2)(float, float) = (float (*)(float, float))dlsym(so, "powf");
  if (!f1) { fprintf(stderr, "no %s in the library\n", argv[1]); return 1; }
  volatile float two = 2.0f;   /* (the compiler must not see powf's y) */
  uint64_t h = 0xcbf29ce484222325ull;
  uint32_t u = 0;
  do {
    float x, y;
    memcpy(&x, &u, 4);
    y = expt2 ? (x == 0.0f ? x * 2.0f : f2(x, two)) : f1(x);
    uint32_t b;
    memcpy(&b, &y, 4);
    h ^= b;
    h *= 0x100000001b3ull;
  } while (++u != 0);
  printf("%s 0x%016llx\n", argv[1], (unsigned long long)h);
  return 0;
}
