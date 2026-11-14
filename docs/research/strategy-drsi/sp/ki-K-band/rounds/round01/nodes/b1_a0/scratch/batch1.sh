cd $(dirname $0)
for v in "k1::kikon 1.0" "k2::kikon 0.0" "o2::other 2.0" "hi::kk-hoho-in-p 1.0 :kk-hin-fs 100" "bk::kk-bankai-p 1.0" "kr::kk-kikon-red-p 0.0 :kk-kikon-ptr-p 0.0" "ns::kk-ns-safe-p 0.0"; do n=${v%%::*}; e=${v#*::}; echo "$n :$e"; ./try.sh $n ":$e" "" | python3 -c "
import sys,json
d=json.loads(sys.stdin.readline());print(d['score'],{k:(g['ko_wins'],g['timeouts']) for k,g in d['groups'].items()})"; done
