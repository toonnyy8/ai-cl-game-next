# b2_a1 (kk-ken, round 1): ken-ki-style when behind and close, or even/close/high Reiatsu

Slice: (lead behind, dj in) OR (lead behind, dj reach) OR (lead even, dj in, mr high). Strategy: `:fn ken-ki-style`.
History: b0_a0 (behind/even 0.98), b0_a1 (near+not-ahead 0.975), b1_a0 (close+not-ahead / mr low 0.975), b2_a0 (behind/mr low/startup 0.905),
b1_a1 (ichigo-ki-style, weaker 0.90). All one mechanism: a KI style CPU beats the generic-core+MCTS incumbent mirror almost anywhere.
Mine: the smallest slice that keeps it (own 0.27, lowest in the workspace): only when behind within reach, or even, close, with Reiatsu high.
Also scanned (capped, own 0.67-0.84, 0.975-0.99): ost startup/active/evade/down slices, so ost cues fire too broadly to stay under the cap.
Dev seed0 800 x100: 0.96 (gain +0.46, z 8.9, own 0.27). Second block seed0 900 x50: 0.99 (gain +0.49, z 7.0, own 0.26).
Not a repeat: a new, narrower conjunction; no gain over b0/b1 (ceiling ~0.98). Risk: whole-replacement in disguise; a lookup entry would do.
