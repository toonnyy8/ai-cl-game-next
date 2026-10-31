# DUEL_SUBLIMATION — SUBLIMATION (昇華) and SPIRIT DRIVE, the awakening gauge's later stages (2026-10-31)

User's request (verbatim, 2026-10-31): 「我想開啟共用的新系統 SUBLIMATION(昇華) 與 SPIRIT DRIVE
* SUBLIMATION：當覺醒量表全滿後會繼續累積第二階量表，當第二階段累集越多時會讓角色性能得到全面提升(傷害增加、傷害減輕、移動速度上升、靈力積蓄量增加)。覺醒後提昇的性能就會固定為覺醒前已累積的 50%，不再增加。並由 SPIRIT DRIVE 接手。
* SPIRIT DRIVE：覺醒後的二階量表，累集越多時會讓角色性能得到全面提升(傷害增加、傷害減輕、移動速度上升、靈力積蓄量增加)。但提昇上限幅度為覺醒前的 50%，部份角色全滿時會開放再覺醒（e.g. 劍八）」

Asked (AskUserQuestion), answered:

| Question | Answer (verbatim) |
|---|---|
| Boosts at a full gauge (B) | 「傷害+20% 減傷20% 移速+10% 閃步量表+30%，我剛剛忘記現在已經沒有靈力了」: the fourth boost is the **flash-step** gauge's gain (the Reiatsu gauge is gone, DUEL_CORE §6) |
| SPIRIT DRIVE's cap | 「以滿 B 為基準」 |
| Fill and decay | 「同覺醒量表的來源，倍率 ×1.0，不衰減」 |
| Scope | 「一起做劍八：卍解改成 DRIVE 滿才能按」 |

Then, mid-build: 「不用下面第二條量表，SUBLIMATION 直接在原量表上累積粉色量表，SPIRIT DRIVE 則是直接清空覺醒槽改使用紅色量表從 0 填充」 (§6).

## 1. Rules (all fighters, `rules.lisp` pure, `combat.lisp`)

- **Fill**: the awakening gauge's sources (damage dealt / taken, Konpaku lost, WHITE's regen) at x1.0. Before the awakening they fill the awakening gauge, and what is above `*awaken-max*` (and everything once it is full) fills **SUBLIMATION** (0–`*sub-max*` 100). After it, the same sources fill **SPIRIT DRIVE** (0–`*drive-max*` 100). Neither decays. (`awaken-overflow`, `awaken-fill!`.) Not awakening is therefore a choice: a full gauge keeps paying.
- **Bonus fraction** (`sub-frac`, of B): before the awakening `sub / 100`; after it `*sub-keep*` 0.5 x s + `*drive-add*` 0.5 x `drive / 100`, s = the SUBLIMATION fraction frozen at `awaken!`. So the awakening keeps half of what was piled up, and a full DRIVE adds half of a **full** B whatever s was (the user's answer), at most (0.5 s + 0.5) B.
- **Boosts at fraction 1** (`*sub-dmg*` 0.20, `*sub-taken*` 0.20, `*sub-speed*` 0.10, `*sub-fs*` 0.30): damage dealt x(1 + 0.2 f) (in `apply-hit`'s attacker multiplier; a `:flat` window ignores it), damage taken x(1 - 0.2 f) (`sub-taken-mods`), walk and run speed x(1 + 0.1 f) (`sub-speed-mult`), flash-step gained from hits x(1 + 0.3 f) (`pay-gauges`; AS1's steal and Hoho are not "gain from hits").
- Every kit, the CPU too; the gauges live in `gauges` (`sub`, `sub-s`, `drive`), reset with the match. A `:no-awaken` form (Hisagi's Bankai) never awakens, so only the pre-awakening part exists for it unless its kit is already awakened.

## 2. Open points (to ask)

Ichigo and Hisagi have no re-awakening yet; `drive-full-p` is the flag a kit can read. The CPU does not wait for SUBLIMATION on purpose (its awakening roll is unchanged).

## 3. Kenpachi's Bankai

`bankai-allowed-p (free drive-full)`: P in cup 3, free as for the awakening, **with a full SPIRIT DRIVE** (it was: at most 4 of his Konpaku, DUEL_KEN_BANKAI §1.1). The entry still sets his Konpaku to 1, so from 9 souls he now pays 8: a trade the CPU's `ken-bankai-gate` keeps filtering by its Konpaku rules (HARD only as a finisher or with little to lose). Callers: `fighter.lisp` (P), `combat.lisp` `bankai-ready-p`, `onehand.lisp`, `ai.lisp` `ai-bankai`, `ken.lisp` `ken-bankai-gate`.

## 4. Knobs

`*sub-max*` 100, `*drive-max*` 100, `*sub-dmg*` 0.20, `*sub-taken*` 0.20, `*sub-speed*` 0.10, `*sub-fs*` 0.30, `*sub-keep*` 0.5, `*drive-add*` 0.5 (tuning.lisp). `*bankai-konpaku*` is now only the debug scene's cap.

## 5. Not done

Ichigo's and Hisagi's re-awakenings; the CPU timing its awakening around SUBLIMATION; the manual's tutorial text beyond the awakening section; the learner / ASSIST / ENDLESS / ROGUE (frozen) were not touched.

## 6. HUD (webhud slots 22 / 23, `hud.js`, `hud.css`)

No second bar. The awakening bar full, SUBLIMATION piles **pink** on top of it from the left (right on P2). On the awakening the bar is emptied and SPIRIT DRIVE fills it **red** from 0, glowing when full (slot 7 is the DRIVE ‰ once awakened). The seal ring on the phone follows slot 7. Only colour tells the stages apart; a label is open.

## 7. Checks (2026-10-31)

Host tests (`tests/duel-rules/sublimation.lisp`, 11 286 checks all pass in the suite: the fill and the overflow, `sub-frac` at s 1 / 0.4 / 0, the taken multiplier, 100 x 1.2 x 0.8 = 96, the Bankai rule; the two old Bankai checks rewritten), pkgcheck clean, the build. Scripted scene `tests/scripts/duel-sublimation.json` (debug 84020–84070 on the 84000 / 84003 scenes): the attacker's multiplier 0.504 at SUBLIMATION 0, 0.6048 at 100 (x1.2) and 0.57456 at s 0.4 + DRIVE 100 (f 0.7); the taken multiplier 1.0 -> 0.8; the real awakening at SUBLIMATION 50 freezes s 0.5 (f 0.25) and empties the awakening gauge; speed x1.10 at f 1; in cup 3 awakened, P with DRIVE 52 does nothing, with DRIVE 100 the form becomes BANKAI (Konpaku 9 -> 1). G2 `--cvc` moved in all three pairs (the CPU waits at a full gauge now and then): II 29 -> 30 lines (P1 4-0, 296.6 s), IK 18 -> 25 (P2 0-5, 245.1 s), KK 19 -> 17 (P2 0-4, 172.1 s); `tests/style-cvc-ref.txt` regenerated. No balance gates (the user, 2026-10-29): the long II / IK times are not judged.
