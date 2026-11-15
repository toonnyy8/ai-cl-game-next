# Ichigo's arms from her kit study (PLAN4 checkpoint 2a, implementation batch, 2026-11-15)

The user took every strategy of `sp/kits/ichigo/strategies.md` (「全部採用」, PLAN4 "Checkpoint 2a", DEVLOG §793): `all` (= T1 the sealed band),
S1 answer, S2 brawl, S3 economy, S4 punish, S5 kessa-lunge, T2 keep (KI only), T3 inside 3 m (IH only). This batch writes each as an arm
(`arms5/ichigo/arms.lisp`, one style function `ichigo-ki-r2b2a1-style`), gives it a job map (`arms5/ichigo/jobs.py`, `jobs-ki.json`,
`jobs-ih.json`) and proves it one-job (`arms4/proof.py desc`). Nothing enters strategy.lisp's lookup or tables (a later batch).

## Code (off by default: no key, the same play)

- `cpu-ki-ichigo.lisp`: three style keys (KNOBS.md §6.7a). `:iks-kessa-lunge-lo` / `-hi` replace `*iks-kessa-lunge-band*`'s ends
  (S5). `:iks-ns-wait-p1` replaces the NS-whiff punish wait under pointer 1 (S4: NS1a at f10, NS3a at f24, catalogue W), read by the new
  `iks-ns-wait`. Host check `style-knob.lisp`: 78 keys, 35 `iks-`.
- **S1's code question** ("an arm must be allowed to override its pairing's `:with` exchange keys") needs no code. STRAT-WITH (strategy.lisp)
  leaves out of every unit any key the arm names anywhere ("ARM's own keys win"). Seen in play: against Hisagi the IH unit sets `:clash-p
  0.0`, and the probe arm s1a's `:clash-p 1.5` gave +34 clashes a match over arm 0 (seeds 201-220).
- `tools/simgate/strat-run.lisp`: an `idesc` line under STRAT_DESC (a separate block, read only): cancels, her first action after each, and
  whether it is the SA; her AS routes and the AS1 ones; her move starts out of her neutral while his move is past its active frames; her
  awakened NS routes and the NS3 ones; steps at 3.4-6.0 m.
- `arms4/proof.py`: reads `idesc` (KEEP, `arm_desc`), five new descriptors in their own block: `sa_x`, `as1`, `k_p3` (pooled shares), `punish`
  (a match) and `b34` (share of steps). Their distinctness tolerances (`sa_x`, `as1` and `k_p3` 0.05; `punish` 15 % of the larger, at least
  0.15; `b34` 0.03) widen the test for every later run: one more way to differ. `--cols` prints extra columns.

## Design probes (dev seeds 201-220, both seats, 40 matches an arm and opponent; not the proof seeds)

Three rounds (scratch arm files; 22 candidates against Kenpachi's and Hisagi's `none`, with the pairing's `:with`). What they showed:
- **S1**: the study's values (clash 1.5, SA 1.5, margin 0.5) sit at or under the KI unit's (1.7 / 1.6 / 1.5), so an arm on `all` with
  them answers *less* than arm 0 against Kenpachi (s1a: clash -1.0 a match). The clash count moves only when she stands where his J comes:
  brawl's close play (s1c / s1e / s1h: clash x1.5-1.7 vs K, x2.6 vs H). A patient answer posture (the bait hover pulled in 0.3-0.5 m) moved
  clashes x1.1 vs K. **`sa_x` moved by no candidate** (-0.06 to +0.05; one +0.15 vs K from an economy arm with the clash off): the SA after a
  cancel comes only when the shared exchange layer sees his turn (XCH-SA-NOW-P), and her clash makes her the NS side only against his J.
- **S3**: `:iks-steer-to 2` moves `as1` far (+0.47 to +0.68). `:ns` is the generic CPU's (inert at HARD for her, KNOBS.md §2.3). `sp` moved
  -5 to -6 a match vs K (x0.89-0.90) and ~0 vs H with every lever tried (the NS punish off, the clash and carry off, the confirm halved).
- **S4**: the study's keys over arm 0 change little (arm 0 already has `:iks-ns-wait 24` and punish / confirm 0.9 / 0.95). The `:space`
  mode's hover at the edge of his reach moved `punish` x1.8 vs K. Against Hisagi arm 0 already punishes from neutral about 17 times a match
  (his chain whiffs in its dead zone) and no candidate raised it. `:iks-ns-wait-p1 10` was identical to its absence on these 40 matches
  (a pointer-1 NS punish needs his NS started beyond 3.65 m and her within 3.4 m: rare).
- **S5**: the band keys are live (s5a 4.2-5.5 and s5b at the default band played different matches) but `k_sp` stayed within x0.8-1.2.
- **T3**: `:iks-hover-add` is inert in brawl's mode (as arms4 note 2 and cells-k found): t3a is brawl, not distinct from it. Hovering
  modes with the add (t3d / t3e: the `:space` mode, patience off) were distinct but missed `b34` (-0.03).

## Pre-registered (committed before the proof run on seeds 1-100)

Played whole against his `none`, HARD, seeds 1-100 both seats (200 matches), a 1-arm `:rb-sp2` table (keep-state, period 30) with the
pairing's `:with` unit (`arms4/x-units/d-x-ki-i.lisp`, `d-x-ih-i.lisp`), as `proof.py desc` plays it. One run per opponent: vs Kenpachi
`all answer brawl economy punish kessa-lunge keep`, vs Hisagi `all answer brawl economy punish kessa-lunge inside` (T2 KI only, T3 IH only).
Pass = the descriptor (both opponents where it plays both) + distinct from every sibling in that run + K.O. >= 0.50. **The bars are the kit
study's, verbatim** (S2 / T2 keep their arms4 registrations).

| Arm | Strategy | Keys over the common base | Job (`:rb-sp2`) | Descriptor (vs arm 0) | Probe 201-220 (vs K; vs H) | Predicted |
|---|---|---|---|---|---|---|
| `a4-i-all` | T1 / arm 0 | none | everywhere else | arm 0 | | |
| `a5-i-answer` | S1 | brawl's + `:clash-p 1.7 :xch-sa-p 1.6 :xch-carry-p 0.3 :clash-margin 0.5` | G2 `(:ost :atk) (:dm :m-close)`; G5 `(:xch :yes)` | `clash` >= x1.3 **and** `sa_x` >= +0.15 | clash 19.6 / 12.8, sa_x .331 / .292; clash 74.9 / 29.2, sa_x .152 / .194 | clash passes, **sa_x fails** both |
| `a4-i-brawl` | S2 | as built | G2 `(:ost :free)` (as shipped) | `close` >= +0.10 | .881 / .709; .779 / .597 | passes |
| `a5-i-economy` | S3 | `:iks-steer-to 2 :ns 0.2 :iks-retreat-p 0 :iks-gap-p 0` (verbatim) | G3 `(:mcell :no) (:ocell :yes / :p2up)` | `as1` >= +0.25 **and** `sp` <= x0.85 | as1 .810 / .158, sp 49.5 / 54.7; as1 .751 / .280, sp 56.8 / 57.1 | as1 passes, **sp fails** both |
| `a5-i-punish` | S4 | `:iks-mix-space 1` (others 0) `:iks-ns-wait 24 :iks-ns-wait-p1 10 :iks-punish-p 1 :iks-confirm-p 1 :iks-gap-p 0` | G2 `(:ost :atk) (:dm :m-mid)`, `(:ost :evade) (:dm :m-close / :m-mid)` | `punish` >= x1.5 | 1.28 / 0.70; 15.7 / 17.2 | passes vs K, **fails vs H** |
| `a5-i-kessa-lunge` | S5 | `:iks-kessa-lunge-lo 4.2 :iks-kessa-lunge-hi 5.5`; awakened: `:iks-mix-space 1` (others 0) `:iks-gap-p 0 :iks-wait-max 150` | G1 `(:form :yes) (:dm :m-mid / :m-far)` (B4's narrowing) | `k_sp` >= x1.3 **and** `k_p3` >= +0.20 | k_sp 3.77 / 4.76, k_p3 .957 / .834; k_sp 3.62 / 3.27, k_p3 .788 / .748 | **fails** both; k_p3 vs K is infeasible (arm 0 .83 + .20 > 1) |
| `a4-i-keep` | T2 (KI) | as built | G8 `(:time :t-late) (:lead :ahead)` | `p2` >= +0.20 **and** `mean_d` >= +0.5 m | p2 .662 / .138, mean_d 3.14 / 2.35 | passes |
| `a5-i-inside` | T3 (IH) | brawl's + `:iks-hover-add -1.0` (verbatim) | G1 `(:form :no) (:dm :m-mid)`; G10 `(:optr :yes) (:dm :m-mid)` | `b34` <= -0.10 | .138 / .262 | b34 passes, **not distinct from brawl** |

- S1's keys take the study's carry (0.3) and margin (0.5), and for the clash and SA chances the larger of the study's and the KI unit's,
  so S1 never answers less than arm 0. The study's keys on arm 0's patient play answer less against Kenpachi (s1a). The close play is
  brawl's: the study's "inside 3.2 m".
- S4 uses the `:space` mode instead of the study's `:iks-mix-whiff 1`. At HARD the whiff mode baits at 2.3-2.7 m, inside his reach, where
  the start-time punish never fires. The space mode hovers at 3.7-4.2 m, the study's "edge of his reach". It is one arm for both opponents:
  his form picks the band, and Hisagi's Shikai reads as `:base`.
- S5's awakened rule adds `:iks-gap-p 0` (else the shut-gauge lunge takes pointer 3 first) and `:iks-wait-max 150` (else the episode goes
  to the generic CPU after the base's 40 frames, before the band is reached).
- Known flaws, registered as written: S5's `k_p3` +0.20 vs Kenpachi is above 1.0. S1's `sa_x` measures the shared exchange layer's answer
  more than her choice.

**Job maps and vacuity** (`jobs.py`: the offline firing share on judgements the shipped T0 tables logged, seeds 501-540 both seats; fire /
lasting, KI; IH): answer .48 / .49; .19 / .20. brawl .31; .20. economy .14 / .15; .23 / .25. punish .17; .38. kessa-lunge .26 / .58; .45 / .75.
keep (KI) .02 / .97 (latches, rare). inside (IH) .39 / .40. None is over 60 %. The first economy map (G3 my cells 0, any his) fired .55 (KI)
and .74 (IH, VACUOUS), so it was narrowed to "my cells 0 x his >= 1" before this registration.

**Builds**: the probes and the job scores ran on this branch before main's clash dead-zone fix (336830ca), so their vs-Hisagi numbers met
the old Hisagi. The registration was committed (e2ecdf1c), main was merged (56ac213d), and then the proof ran on that build.

## Results (`proof.py desc`, sim build `95ac116d248f` = e2ecdf1c + main 336830ca, seeds 1-100 both seats, 200 matches an arm; `ichigo/proof-vs-*.json` / `.txt`)

| Arm | vs Kenpachi: descriptor (arm 0) | K.O. / K.O. win | vs Hisagi: descriptor (arm 0) | K.O. / K.O. win | Distinct | Verdict |
|---|---|---|---|---|---|---|
| `a4-i-all` | arm 0 | 1.00 / 1.00 | arm 0 | .99 / .905 | yes | arm 0 |
| `a5-i-answer` | clash 19.58 (12.96) x1.51 PASS; sa_x .302 (.262) +.04 FAIL | 1.00 / 1.00 | clash 67.6 (30.0) x2.25 PASS; sa_x .158 (.258) -.10 FAIL | .98 / .665 | yes | **fails** (sa_x) |
| `a4-i-brawl` | close .887 (.709) +.18 PASS | 1.00 / 1.00 | close .765 (.579) +.19 PASS | .985 / .87 | vs K yes; vs H **~inside** | passes vs K; vs H passes only without `inside` beside it |
| `a5-i-economy` | as1 .806 (.132) PASS; sp 49.5 (53.8) x0.92 FAIL | 1.00 / 1.00 | as1 .763 (.250) PASS; sp 57.0 (55.7) x1.02 FAIL | .845 / .79 | yes | **fails** (sp) |
| `a5-i-punish` | punish 1.255 (.775) x1.62 PASS | 1.00 / 1.00 | punish 14.97 (16.93) x0.88 FAIL | .985 / .94 | yes | passes vs K, **fails vs H** |
| `a5-i-kessa-lunge` | k_sp 3.78 (4.47) x0.85 FAIL; k_p3 .948 (.846) FAIL | 1.00 / 1.00 | k_sp 3.79 (3.24) x1.17 FAIL; k_p3 .806 (.775) FAIL | .995 / .975 | yes | **fails** |
| `a4-i-keep` (T2) | p2 .657 (.153) PASS; mean_d 3.13 (2.34) PASS | 1.00 / .935 | | | yes | **passes** (KI) |
| `a5-i-inside` (T3) | | | b34 .146 (.270) -.12 PASS | .99 / .875 | **~brawl** | **fails** (not distinct from brawl) |

Every outcome is the one predicted at registration. Every arm ends its matches (K.O. >= .845). **Passing:** brawl (vs K, and vs H on its own
descriptor), keep (T2), punish vs Kenpachi only. **Failing:** answer (`sa_x`), economy (`sp`), kessa-lunge (both parts), punish vs Hisagi,
and inside (T3, the same play as brawl: the hover add is inert in brawl's mode). Arm 0 vs Kenpachi reproduces arms4's run of the same arm
exactly (2.343 m, .709 close, p2 .153, p3 .707, k_d 2.340, 53.8 SP), so the new keys left her play unchanged.

What the failures say:
- **`sa_x`, `sp` and `k_sp` are not moved by the study's keys or by any lever probed.** The SA after a cancel is the shared exchange
  layer's answer to his turn. Her SP count is set by the punish / confirm NS and the AS segments, not by `:ns` or the steer alone. KESSA's
  SP rate is set by how often he is calm inside the band. A new descriptor or a code change would be a new registration on fresh seeds.
- **punish vs Hisagi**: arm 0 already punishes his dead-zone whiffs from neutral 17 times a match, and the space hover (3.7-4.2 m) sits in
  his chain band, so it punishes less. A Hisagi-specific punish arm would need the hover inside his dead zone (an IH targeted arm).
- **T3** = S2 in IH. Drop T3, or give it a behaviour brawl does not have (e.g. a hover inside his dead zone, which t3d / t3e tried: distinct
  but `b34` -0.03).

## Checks (this branch at 56ac213d + the result files)

- Host tests: duel-rules 3647 checks ALL PASS (style-knob: 78 keys, 35 `iks-`), duel-control 124, input 33 and cine 18 ALL PASS, touch 100 / 0
  failures. pkgcheck: only `DUEL::APP`. `./build.sh duel` exit 0 (vendor restored), smoke exit 0.
- G2: `tools/simgate.py --cvc` PASS (ii 41, ik 42, kk 31 lines) and `tests/style-gates.py cvc dist/duel` PASS: identical to
  `tests/style-cvc-ref.txt`.
- identity.py, the shipped HARD lookup = the raw T0 file, seeds 501-510 both seats: KI 2 chunks identical (460 lines), IH 2 identical (579), II
  2 identical (616).
- The idesc counters only read: `a5-i-answer` vs Kenpachi and `a5-i-kessa-lunge` vs Hisagi, seeds 501-510, with and without STRAT_DESC: hash,
  state and gate rows identical (178 / 253 lines).
- snaptest straight = pollute, HARD, 2 matches each: KI, IH, II (577 / 714 / 832 rollouts). Only the timing and cons lines differ (`brush`
  ms, `stats` cons/frame, `duel mcfull` ms); 0 sim lines differ. fulltest 0 differ: IK 4007 (21 checks), 5013 (0), 3015 (50), `FT_LAYER=t`
  HARD 5013 (630 checks, 620 strategy).
- `tests/sp-costs-check.py`: all checks pass.
