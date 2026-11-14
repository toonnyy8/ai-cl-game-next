import json,sys
for p in sys.argv[1:]:
    d=json.load(open(p)); g=d.get('groups',d)
    print(p.split('/')[-1], d['score'], d.get('build'), [(k,g[k]['ko_wins'],g[k]['ko_losses'],g[k]['timeouts']) for k in ('anchor','mix','rest')])
