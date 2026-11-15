#!/usr/bin/env python3
"""bars.py — bar A (and bar D's K.O. rate) for the six rows of B4's tables, each table against its row's opponent table, both seats, through
proof.py bar (seeds 501-540 by default: 80 matches a row; mirrors against themselves).
  python3 bars.py OUT_TAG TABLE=VER ... [--rows KI,KH,IH,KK,II,HH] [--seeds 501-540]
TABLE=VER picks t0final/VER/t0-TABLE.lisp and its map t0final/VER-TABLE.json for that table (default v0). Writes t0final/bar/<OUT_TAG>-<row>.json
and prints one line a side."""
import json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
HERE = os.path.dirname(os.path.abspath(__file__))
A4 = os.path.dirname(HERE)
ROWS = {'KI': ('ki-kenpachi', 'kenpachi', 'ki-ichigo', 'ichigo'), 'KH': ('kh-kenpachi', 'kenpachi', 'kh-hisagi', 'hisagi'),
        'IH': ('ih-ichigo', 'ichigo', 'ih-hisagi', 'hisagi'), 'KK': ('kk-kenpachi', 'kenpachi', 'kk-kenpachi', 'kenpachi'),
        'II': ('ii-ichigo', 'ichigo', 'ii-ichigo', 'ichigo'), 'HH': ('hh-hisagi', 'hisagi', 'hh-hisagi', 'hisagi')}


def line(name, r, d):
    j = ' '.join(f"{k}:{v['in_share']:.2f}/{v['out_share']:.3f} f{v['fire_share']:.2f} L{v['lasting']:.2f}{' VAC' if v['vacuous'] else ''}"
                 for k, v in r['job'].items())
    A = r['A']
    ok = A['no_zero'] and A['median_10'] and A['three_arms'] and A['division']
    return (f"{name:12s} med {r['changes']['median']:5} mean {r['changes']['mean']:5} zero {r['changes']['zero']:2} jud {r['judgements_per_match']:6} "
            f"share {r['arm_share']} | {j} | KO {r['ko_rate']:.3f} win {r['ko_win']:.3f} TO {r['timeouts']} | A {'PASS' if ok else 'fail'}"
            f"{'' if ok else ' (' + ','.join(k for k in ('no_zero', 'median_10', 'three_arms', 'division') if not A[k]) + ')'}")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    opt = dict(a[2:].split('=', 1) for a in sys.argv[1:] if a.startswith('--'))
    tag, ver = args[0], dict(a.split('=') for a in args[1:])
    rows = opt.get('rows', ','.join(ROWS)).split(',')
    seeds = opt.get('seeds', '501-540')
    os.makedirs(os.path.join(HERE, 'bar'), exist_ok=True)

    def one(row):
        t1, c1, t2, c2 = ROWS[row]
        v1, v2 = ver.get(t1, 'v0'), ver.get(t2, 'v0')
        out = os.path.join(HERE, 'bar', f'{tag}-{row}.json')
        r = subprocess.run([sys.executable, 'proof.py', 'bar', '--p1', f't0final/{v1}/t0-{t1}.lisp', '--p1map', f't0final/{v1}-{t1}.json',
                            '--c1', c1, '--p2', f't0final/{v2}/t0-{t2}.lisp', '--p2map', f't0final/{v2}-{t2}.json', '--c2', c2,
                            '--seeds', seeds, '-j', opt.get('j', '12')], cwd=A4, capture_output=True, text=True)
        if r.returncode:
            sys.exit(f'{row}: {r.stderr[-2000:]}')
        open(out, 'w').write(r.stdout)
        return row, v1, v2, json.loads(r.stdout)

    with ThreadPoolExecutor(int(opt.get('par', '2'))) as ex:
        for row, v1, v2, d in ex.map(one, rows):
            print(f"{row} ({v1} vs {v2}) seeds {d['seeds']} build {d['build']}")
            for name, r in d['sides'].items():
                print('  ' + line(name, r, d))
                if row in ('KK', 'II', 'HH'):
                    break


if __name__ == '__main__':
    main()
