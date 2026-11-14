D=docs/research/strategy-drsi/sp/ki-I/rounds/round02/nodes/b1_a0/scratch
W1=":iks-meaty-p 0.0 :iks-mix-whiff 1.5 :iks-mix-ptr3 0.6 :iks-mix-space 0.1 :iks-wait-max 40 :iks-gap-p 1.0 :iks-gap-fs 150 :iks-ns-wait 24 :iks-getsuga-min 6.5"
i=0
while IFS='|' read n k; do $D/run.sh $n "$W1 $k" | cut -c1-30,100-; done <<'L'
p1|:iks-hoho-p 0.0 :iks-wake-hoho-p 0
p2|:iks-break-p 0.5
p3|:iks-punish-p 0.0
p4|:iks-confirm-p 0.0
p5|:iks-awaken-p 0.0
p6|:iks-gap-p 0.0
p7|:iks-retreat-p 0.0
p8|:iks-wait-max 150
p9|:iks-mix-kessa 0.6
p10|:iks-mix-whiff 0.1
p11|:iks-steer-p 0.0
p12|:iks-gap-wait 5.5
L
