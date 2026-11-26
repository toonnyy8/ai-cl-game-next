#!/usr/bin/env python3
"""Check a frames.bin written by stubs-capture.c (docs/bevy/plans/2026-11-26-m0a-speed-test.md, Task 2).
Usage: python3 tools/port/capture/check.py build/port/capture/frames.bin [expected_frames=240]"""
import statistics, struct, sys

def load(path):
    b = open(path, "rb").read()
    assert b[:8] == b"SDCAP1\0\0", "bad magic"
    nm, nf = struct.unpack_from("<II", b, 8); o = 16
    meshes = {}
    for _ in range(nm):
        mid, nv = struct.unpack_from("<II", b, o); o += 8
        meshes[mid] = nv; o += nv * 36
    frames = []
    for _ in range(nf):
        tick, = struct.unpack_from("<I", b, o); o += 4 + 640
        nd, = struct.unpack_from("<I", b, o); o += 4
        draws = []
        for _ in range(nd):
            mid, pipe = struct.unpack_from("<II", b, o); o += 8
            rec = struct.unpack_from("<32f", b, o); o += 128
            draws.append((mid, pipe, rec))
        frames.append((tick, draws))
    assert o == len(b), f"trailing bytes: {len(b) - o}"
    return meshes, frames

def main():
    path = sys.argv[1]; want = int(sys.argv[2]) if len(sys.argv) > 2 else 240
    meshes, frames = load(path)
    assert len(frames) == want, f"{len(frames)} frames, want {want}"
    for tick, draws in frames:
        assert all(m in meshes for m, _, _ in draws), f"tick {tick}: a draw names an unknown mesh"
        assert any(r[28] > 1.5 and r[28] <= 2.5 for _, _, r in draws), f"tick {tick}: no character toon draw"
        assert any(0.5 < r[28] <= 1.5 for _, _, r in draws), f"tick {tick}: no stage toon draw"
    nd = [len(d) for _, d in frames]
    pipes = {}
    for _, d in frames:
        for _, p, _ in d: pipes[p] = pipes.get(p, 0) + 1
    print(f"meshes {len(meshes)} verts {sum(meshes.values())} | frames {len(frames)} ticks {frames[0][0]}-{frames[-1][0]} | "
          f"draws min {min(nd)} median {statistics.median(nd)} max {max(nd)} | per pipe {dict(sorted(pipes.items()))}")
    print("PASS")

if __name__ == "__main__":
    main()
