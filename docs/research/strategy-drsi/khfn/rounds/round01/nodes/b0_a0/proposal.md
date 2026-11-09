# b0_a0 (round 1): wake-up bait

Job (one line): after Hisagi's knockdown Kenpachi does not press the meaty J1; he stands at 2.3 m, inside his wake-up Hoho trigger, and punishes the Hoho's end.

## Mechanism
`ken-kh-style` = `ken-ki-style` (his KI code, unchanged) plus one pre-step, `khf-bait-step`. Per knockdown of Hisagi's (one `brain-roll` of
`*khf-bait-p*` as the SNAP first shows him air/down/wakeup; HARD 1.0): while the SNAP shows him down or waking, and for brain-delay + 4 frames
after (his first free frame and Hoho press are not in the SNAP yet), Kenpachi holds at `*khf-bait-d*` 2.3 m (walks in / out by 0.15 / 0.3) and presses nothing.
`*kk-meaty-p*` is bound to 0 around the delegate while the bait is armed, so the KI code's meaty never starts. Once the SNAP shows his Hoho,
the delegate runs and its existing `:hend` plan (J1 timed to his Hoho's last frame) punishes him. State: `khs` includes `kks` (brain-style).
Hisagi is read only through the perceived SNAP state and D.

## Evidence
Baseline, seed 301 vs the live table (HARD): 6 PERFECT HOHOs by Hisagi, each on Kenpachi's meaty J1 (Hisagi's CPU presses a Hoho on his first
free frame when Kenpachi is within 2.4 m; the hit lands inside its window: counter 60, Kenpachi locked 40, then the J1 J2 AS1 / ZANDEN
loop). Damage 1905 to Kenpachi vs 1685 to Hisagi, a loss. With the bait: 0 perfect Hohos, 15 baits, 4 hoho-end J1s, damage 803 / 3065, a win.
The KI code's meaty distance (2.25-2.4 m) was tuned against Ichigo's wake-up Hoho (near 2.2 m); Hisagi's trigger is 2.4 m.

## Not a repeat / near-duplicate
Neither KI code holds at a knockdown: both press the meaty. Member shares move 0.1-0.85 against the baseline's. It adds a state machine
around the delegate (wake-up discipline against a Hoho-on-wake-up opponent), not a retune.

## Measurement (dev block seed0 300, scale 1, 950 matches; baseline at scale 0.5 on the same block: 0.4209, live 0.039)
score 0.8867: live 0.8762, iterates 0.8564, arms 0.9275. Every member 0.82-1.0 (baseline weakest: hk-r1 0.03, h9-kenkite 0.25, h3-press 0.42).
inc_live 0.255 (the live lookup's own share; the baseline's was 0.27 at scale 0.5, so not moved by this file). Host tests ALL PASS, pkgcheck clean
(only the old DUEL::APP note). Scale 0.5 gave 0.8882.

## Risks
- Against an opponent that does not Hoho on wake-up Kenpachi gives up the meaty pressure (not seen: every arm scored 0.82-1.0).
- The 2.4 m trigger is inferred from Hisagi's CPU behaviour in logs, not from his inputs; a CPU that never Hohos just gets a 2.3 m stand-off.
- The closing-in side of the direction hint (chain range, Bankai ranged mode) is untouched; a second mechanism could add there.
