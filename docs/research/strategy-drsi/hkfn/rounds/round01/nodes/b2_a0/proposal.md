# b2_a0 (round 1): punish the move Kenpachi whiffed into Hisagi's wake-up

**Job (one line):** on Hisagi's first free frame after a knockdown, if Kenpachi is perceived still recovering from a move whose
recovery outlasts J1's (else the pointer's NS's) startup and he is in reach, hit him with that move instead of the generic wake-up Hoho.

## Mechanism
- `hisagi-hk-style` runs `hkw-step` first, else `hisagi-merged-style` unchanged. State: `hks` (includes `hms`) in `brain-style`.
- `hkw-step`: own state goes {:air :down :wakeup} -> {:idle :run} (first free step) and `snap-recovering-p s`: pick `hkw-fits-p` J1
  (reach+slide-0.3 >= d >= min-reach+0.1, `snap-left-seen` >= startup + `*hkw-lead*` 0) else the pointer's NS; one `brain-roll` on
  `*hkw-p*` (EASY 0.3 / NORMAL 0.6 / HARD 1.0) per such frame; press via `cai-press :quick` / `hr-sp`, then `hr-taken`.
- Nothing global, no `cai-defstyle`; only cpu-hk-hisagi.lisp and the MANIFEST line changed.

## Evidence
- Debug logs (live KH, HARD): about 2/3 of Hisagi's first free frames find Kenpachi in KE-Z-N1A / KE-Z-J1 / N2A recovery 0.9-1.4 m away: his
  code presses NS1a / J1 into the wake-up's invulnerable frames and the move whiffs. The baseline spends that frame on the Hoho. In only ~3 of
  15 logged frames does the recovery (as seen, 8 frames old) still outlast J1's 14 frames (left 14, 17, 23), but that moved live KH 0.04 -> 0.19-0.25.
- Failed ideas, all at --scale 0.5 on dev 300 (baseline 0.2163):
  1. The wake-up roll (stick back while down; 4 m, invulnerable): 0.127 (loses the Hoho vs meaty J1 everywhere; live 0.078).
  2. A learned "bait vs meaty" kind, then an NS strike / roll against the bait: 0.2166 (no change; my "bait" read was wrong: the log shows
     idle Kenpachi at d=1.74, against the body, and the live KH rarely stands at 2.3 m on the wake-up).
  3. The same punish with lead -5 (accept landing as he recovers): 0.2626 (live 0.216), no gain over lead 0 (0.2681, live 0.245).
  4. Adding "NS strike on an idle Kenpachi in reach unless a meaty move was seen": 0.1305 (stand-in 0.019, arms 0.18): a meaty J1 is not visible on the first frame.
- Not a duplicate of the KI codes: one reaction at one moment (the wake-up) on top of the merged style.

## Measurement (dev seed0 300, scale 1, 1,220 matches; baseline dev 0.195, search 0.216)
{"score": 0.2357, "groups": {"live": 0.1881, "past": 0.1368, "arms": 0.4119, "standin": 0.2059}}
Live KH (kh-t0) 0.185 (baseline ~0.04); arms ~ baseline; stand-in 0.206 (baseline ~0.23, noise); past 0.137 (baseline ~0.14).
At --scale 0.5: 0.2681 (live 0.245) vs the baseline 0.2163 (live 0.039).

## Expected benefit / risks
- Helps only against the live-KH-type Kenpachi (NS1a / J1 whiffed into the wake-up). Does not answer the bait, the meaty J1, the Step-in or
  the stand-off breaker; the keep rule's live >= 0.2985 and total >= 0.3153 are unlikely to be met alone.
- Risk: the 14-frame J1 can trade with a Kenpachi who is free sooner than the 8-frame-old snapshot says.
- Headroom: the visible recovery is mostly short; a faster opener than J1 / NS would widen it.
