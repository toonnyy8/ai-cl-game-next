# b3_a0: style keys (ichigo-ki-r2b2a1-style) retuned
Baseline c-ih-i-r1-b0a1 0.7706. Final = v6 (7 evals, seed0 300): vs baseline
:iks-mix-generic 0.6->0.2, :iks-mix-ptr3 0.6->1.0, :iks-gap-p 1.0->0.0, :iks-wait-max 40->150. No exchange keys.
Scores: v1 (ptr3 .2, space .5) 0.6815; v2 (generic .2, ptr3 1.0) 0.8086; v3 (gap-p .3, wait-max 100) 0.7871;
v4 (v2+v3) 0.8531; v5 (generic 0, ptr3 1.0) 0.7393; v6 (v4 with gap-p 0, wait-max 150) 0.8663; v7 (v4, ns-wait 36, space .2) 0.8185.
Final v6: anchor 196W/4L/0TO; mix 160/27/13TO; rest 166/26/8TO. Score 0.8663.
Lesson: pointer-3 play weight up and less generic helps; generic fully off (v5) hurts mix group badly.
