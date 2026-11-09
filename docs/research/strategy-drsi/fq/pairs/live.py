#!/usr/bin/env python3
"""live.py — every pairing with both seats on the build's lookup (no strategy file anywhere), HARD, both seats: the cross effect of the lookup
entries (DUEL_AI_STRATEGY §8.15's "where every pairing stands", redone after §8.18).   usage: live.py [--seed0 600]  -> JSON lines"""
import json, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__)); FQ = os.path.dirname(HERE); ROOT = os.path.abspath(os.path.join(FQ, '../../../..'))
seed0 = sys.argv[sys.argv.index('--seed0') + 1] if '--seed0' in sys.argv else '600'
for c, v in (('ichigo', 'kenpachi'), ('ichigo', 'hisagi'), ('hisagi', 'kenpachi'), ('kenpachi', 'ichigo'), ('kenpachi', 'hisagi'),
             ('hisagi', 'ichigo'), ('kenpachi', 'kenpachi'), ('ichigo', 'ichigo'), ('hisagi', 'hisagi')):
    r = subprocess.run([sys.executable, 'tools/strategy-switch.py', '--char', c, '--vs', v, '--cand', os.path.join(FQ, 'pool/never.lisp'),
                        '--seed0', seed0, '--seeds', '100', '-j', '10'], cwd=ROOT, capture_output=True, text=True, check=True)
    print(json.dumps(dict(char=c, vs=v, seeds=f'{int(seed0) + 1}-{int(seed0) + 100}', live_share=json.loads(r.stdout)['inc_share'])), flush=True)
