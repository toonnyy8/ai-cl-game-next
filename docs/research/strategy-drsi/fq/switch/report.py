#!/usr/bin/env python3
"""report.py — one line per measure (sw.py measure's <tag>.json): share, draws, switches a match (mean / zero-change matches), arm shares,
the ranged mode's mean distance and share inside 3 m, the DRIVE switches; then each listed pair's b / c against the first.
usage: report.py ev/A.json ev/B.json ...   (the first is the one paired against the rest)"""
import json, sys

ds = [(p, json.load(open(p))) for p in sys.argv[1:]]
for p, d in ds:
    hr = d.get('hrange', {})
    print(f"{p:40s} share {d['share']:.3f} draws {d.get('draws', '-'):>3} chg {d['changes_per_match']['mean']:5.1f} zero {d['changes_per_match']['zero']:3d} "
          f"arms {d['arm_share']} d {hr.get('mean_d', '-')} in3 {hr.get('close_share', '-')} dsw {d.get('dswitch')} leave {d.get('leave_shikai')}")
a = ds[0][1]['wins']
for p, d in ds[1:]:
    w = d['wins']
    b = sum(1 for k in a if a[k] > 0 and not w.get(k, 0) > 0)
    c = sum(1 for k in a if w.get(k, 0) > 0 and not a[k] > 0)
    print(f'  {ds[0][0]} vs {p}: b {b} c {c} z {(b - c) / max(1, b + c) ** 0.5:.2f}')
