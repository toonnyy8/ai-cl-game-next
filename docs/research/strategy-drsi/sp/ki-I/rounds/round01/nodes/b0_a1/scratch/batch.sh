#!/bin/bash
S=/media/8tsp/projects/ai-cl-game-next/docs/research/strategy-drsi/sp/ki-I/rounds/round01/nodes/b0_a1/scratch/mk.sh
while IFS='|' read n k; do $S $n "$k" | python3 -c "
import sys,json
for l in sys.stdin:
    l=l.strip()
    i=l.find('{')
    if i<0: print(l); continue
    j=json.loads(l[i:]); g=j['groups']
    print(l[:i],j['score'],{k:(v['ko_wins'],v['ko_losses'],v['timeouts']) for k,v in g.items()})
"; done
