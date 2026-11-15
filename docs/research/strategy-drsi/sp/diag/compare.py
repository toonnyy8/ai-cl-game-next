#!/usr/bin/env python3
"""compare.py RUN.json ... — probe.py's per-match totals side by side (each run: its CPU tier's column, then its opponent's)."""
import json, os, sys
R = [json.load(open(p)) for p in sys.argv[1:]]
keys = sorted({k for r in R for s in ('hi', 'lo') for k in r['per_match'][s]})
print(f"{'':16s}" + ''.join(f"{os.path.basename(p)[:19]:>20s}" for p in sys.argv[1:]))
print(f"{'share':16s}" + ''.join(f"{r['share']:20.3f}" for r in R))
print(f"{'per match':16s}" + ''.join(f"{r['hi'][:6]:>10s}{r['lo'][:6]:>10s}" for r in R))
for k in keys:
    print(f"{k:16s}" + ''.join(f"{r['per_match']['hi'].get(k, 0):10.1f}{r['per_match']['lo'].get(k, 0):10.1f}" for r in R))
