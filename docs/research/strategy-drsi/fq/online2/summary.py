#!/usr/bin/env python3
"""summary.py — online2's tables (online2.md §4) from out/<tag>/: live wins and the per-25-match curve (4 runs pooled), each run's final table
frozen against the proxy (601-800) and the shipped CPU (501-600), the base table's disagreement, rules moved / flipped, the largest |q|, broken
tables (held-out < 0.5 x the offline table's), and eps vs eps 0 on the same seeds, paired by 25-match block.
  usage: summary.py [TAG ...]   (default: every folder in out/)"""
import json, math, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'out')
jl = lambda f: [json.loads(l) for l in open(f) if l.strip()]


def load(tag):
    d = os.path.join(OUT, tag)
    return dict(train=json.load(open(os.path.join(d, 'train.json'))), proxy=jl(os.path.join(d, 'heldout-proxy-601-800.jsonl')),
                ship=jl(os.path.join(d, 'heldout-shipped-501-600.jsonl')), stats=jl(os.path.join(d, 'stats.jsonl')))


def paired(a, b):
    """Mean and SE of (a - b) learner wins per 25-match block (same seeds), as a share."""
    xs = [(x['learner'] - y['learner']) / x['n'] for x, y in zip(a['train']['curve'], b['train']['curve'])]
    assert [x['seeds'] for x in a['train']['curve']] == [y['seeds'] for y in b['train']['curve']]
    m = sum(xs) / len(xs)
    sd = math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1))
    return m, sd / math.sqrt(len(xs))


def main():
    tags = sys.argv[1:] or sorted(os.listdir(OUT))
    rows = {t: load(t) for t in tags}
    for t, r in rows.items():
        tr = r['train']
        print(f'## {t}  (eta {tr["eta"]}, eps {tr["eps"]}{", decay " + str(tr["eps_decay"]) if tr.get("eps_decay") else ""})')
        print(f'live {tr["learner"]}/{tr["n"]} = {tr["learner"] / tr["n"]:.3f}, frozen {tr["q1"]}/{tr["n"]} = {tr["q1"] / tr["n"]:.3f}, '
              f'b/c {tr["b"]}/{tr["c"]} z {tr["z"]}')
        print('curve (4 runs pooled, per 25-match block, learner/frozen of 100):',
              ', '.join(f'{v["learner"]}/{v["q1"]}' for k, v in sorted(tr['by_block'].items(), key=lambda kv: int(kv[0]))))
        bp, bs = r['proxy'][0]['q1_share'], r['ship'][0]['q1_share']
        print(f'held-out vs proxy 601-800 (offline {bp:.3f}):', ', '.join(f'{x["table_share"]:.3f}' for x in r['proxy']),
              f'mean {sum(x["table_share"] for x in r["proxy"]) / len(r["proxy"]):.3f}', '| z', ', '.join(str(x['z']) for x in r['proxy']))
        print(f'held-out vs shipped 501-600 (offline {bs:.3f}):', ', '.join(f'{x["table_share"]:.3f}' for x in r['ship']),
              f'mean {sum(x["table_share"] for x in r["ship"]) / len(r["ship"]):.3f}', '| z', ', '.join(str(x['z']) for x in r['ship']))
        print('differ from the offline pick (vs proxy / vs shipped):', ', '.join(f'{x["differ"]:.2f}' for x in r['proxy']), '/',
              ', '.join(f'{x["differ"]:.2f}' for x in r['ship']))
        print('arms vs proxy (offline', r['proxy'][0]['arms_q1'], '):', '; '.join(str(x['arms']) for x in r['proxy']))
        print('rules moved / led flipped (of led) / tied gained / max |q|:',
              '; '.join(f'{s["moved"]} / {s["flips"]} ({s["led"]}) / {s["gained"]} / {s["max_abs_q"]:.3f}' for s in r['stats']))
        broke = [i for i, (p, s) in enumerate(zip(r['proxy'], r['ship'])) if p['table_share'] < 0.5 * bp or s['table_share'] < 0.5 * bs]
        print('broken (held-out < 0.5 x offline):', broke or 'none')
        base = re.sub(r'-e\d+(d\d+)?', '-e000', t)
        if base != t and base in rows:
            m, se = paired(r, rows[base])
            print(f'live vs {base}, paired by block: {m:+.3f} (SE {se:.3f})')
        print()


if __name__ == '__main__':
    main()
