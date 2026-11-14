cd $(dirname $0)
while IFS= read -r v; do n=${v%%::*}; e=${v#*::}; echo "$n :$e"; ./try.sh $n ":$e" "" | python3 -c "
import sys,json
d=json.loads(sys.stdin.readline());print(d['score'],{k:(g['ko_wins'],g['timeouts']) for k,g in d['groups'].items()})"; done
