# b1_a1: band `hisburst`, arm k = arm 0 with :iks-hoho-follow 0
Band: hisburst (G3 rules 37, 39: Kenpachi's burst running). Arm k: ichigo-ki-r2b2a1-style, arm 0's :base/:rules plus :iks-hoho-follow 0 (id :c-ki-i-r3-b1a1-k): no Hoho follow-up window while his burst runs (default 64 ticks).
Why: a Hoho chase into a running burst is open to his combo-breaking push. Evidence is weak.
Screened (seed0 300, arm 0 = 0.8927): kikon-p 0 0.8845; steer-p 0 0.8234 (cliff); retreat-p 0 0.8927 (inert); roll-p 0 0.8861; hoho-follow 0 0.896 (kept); kikon-p 1 + steer-p 1 0.8845; wake-hoho-p 0 + meaty-p 0 0.8927 (inert); hoho-follow 0 + hoho-p 1 0.8894; + gap-wait 3 0.868; hoho-follow 20 + getsuga-min 5 0.896.
Measured final (seed0 300): score 0.896; anchor 199/1/0, mix 150/50/0, rest 191/9/0 (arm 0: 199/1/0, 148/52/0, 191/9/0).
band.py pair vs arm 0 (block 300): pooled b 6, c 8, z -0.53 (a = arm 0); mix b6 c8 z -0.53; anchor, rest 0/0. No time-outs.
Risk: +0.0033 over arm 0, within noise; the band moves play in few matches.
