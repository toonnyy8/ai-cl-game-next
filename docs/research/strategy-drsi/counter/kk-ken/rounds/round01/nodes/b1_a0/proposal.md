# b1_a0 (kk-ken, round 1): ken-ki-style when close and not ahead, or Reiatsu low

Slice: ((:dj :in)(:lead :even)) OR ((:dj :in)(:lead :behind)) OR ((:mr :low)). Strategy: `:fn ken-ki-style`.
History: sibling b0 claims :lead behind/even (0.97, own 0.25). This cell slices by distance/resource instead.
Single-cue dev scans (seed0 800 x100): :dj out/afar 0.42 (style CPU loses at range), :dj reach 0.47, :dj in 1.0 but own 0.86 (capped),
:ost busy 0.995 (own 0.88, capped), :mr low 0.78 (own 0.21), :mr high+free 0.60, :ost active/startup 0.64, :dj in + :lead ahead 0.68.
Finding: the style CPU's edge is in close fighting; at range the incumbent is as good or better. Close+not-ahead (own 0.28) 0.935;
adding :mr low gives final.
Final dev: 0.98 (own 0.40, gain +0.48, z 9.7); second block seed0 900 x50: 0.99 (own 0.36).
Risk: effectively a stronger-general-tactic replacement; a lookup entry would do. Not a repeat of b0 (different cues; overlap in the not-ahead part).
