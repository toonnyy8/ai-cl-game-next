#!/usr/bin/env python3
"""combo-trial.py — play a trial file in the native sim and print each trial's result (the CPU work's step 2: every combo
and means of a fighter's catalogue verified against a dummy; skill duel-character-cpu "Order").

  python3 tools/combo-trial.py docs/research/rukia-cpu/trials-shikai.lisp          a Markdown table
  python3 tools/combo-trial.py FILE --log                                          and every trial's combat log

Columns: dmg dealt, hits, the combo counter's top, gaps (per hit after the first: the frames he could act before it; 0 = a
true combo), adv (his first free frame - hers after the last hit or block), the distance, her Reiatsu / flash step change,
his layers / chill at the end, the hits.
A trial file holds plists read by tools/simgate/trial.lisp (its header: the keys). The P1 trial player presses only its
:script ((button frames &key modded wait) ...) in order (each waits until the last started its move), buttons :quick J, :flash K, :sig L, modded :sig SP2, modded :flash SP1,
:kikon O, :step, modded :step Hoho, modded :quick a burst, :breaker I, :guard U.
"""
import os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import simgate

def main():
    path = sys.argv[1]; show = '--log' in sys.argv
    simgate.build()
    r = subprocess.run([simgate.ECL, '--norc', '--load', 'tools/simgate/trial.lisp', '--', simgate.FAS, os.path.abspath(path)],
                       cwd=simgate.ROOT, capture_output=True, text=True, env=dict(os.environ, LD_PRELOAD=simgate.MUSLM))
    if r.returncode:
        sys.exit((r.stdout + r.stderr)[-3000:] + f'\n[combo-trial] exited {r.returncode}')
    print('| Trial | dmg | hits | combo | gaps | adv | dist | Reiatsu | FS | layers / chill | log |')
    print('|---|---|---|---|---|---|---|---|---|---|---|')
    log = []
    for line in r.stdout.splitlines():
        if 'trial begin' in line:
            log = []
        elif 'trial end' in line:
            f = [x.strip() for x in line.split('trial end', 1)[1].split('|')]
            kv = {x.split(' ', 1)[0]: x.split(' ', 1)[1] if ' ' in x else '' for x in f[1:]}
            hits = [re.sub(r'^\[\s*\d+\] P1 ', '', l).replace(' -> P2', '') for l in log if re.search(r'\] P1 \S+ -> P2 ', l)]
            print(f"| {f[0]} | {kv['dmg']} | {kv['hits']} | {kv['combo']} | {kv['gaps'] or '—'} | {kv['adv']} | {kv['dist']} | "
                  f"{kv['reiatsu']} | {kv['fs']} | {kv['layers'].replace(' chill ', ' / ')} | {'; '.join(hits)} |")
            if show:
                print('\n'.join('    ' + l for l in log))
        elif re.match(r'\[\s*\d+\] ', line.split('duel ', 1)[-1]) or line.startswith('['):
            log.append(line)

if __name__ == '__main__':
    main()
