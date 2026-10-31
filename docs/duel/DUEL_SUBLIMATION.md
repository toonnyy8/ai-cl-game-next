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

## 2. Open points

Ichigo and Hisagi have no re-awakening (the user); `drive-full-p` is the flag a kit can read if one ever does. The CPU does not wait for SUBLIMATION on purpose (its awakening roll is unchanged).

## 3. Kenpachi's Bankai

`bankai-allowed-p (free drive-full)`: P in cup 3, free as for the awakening, **with a full SPIRIT DRIVE** (it was: at most 4 of his Konpaku, DUEL_KEN_BANKAI §1.1). Asked whether the entry still costs souls (it set his Konpaku to 1, so 9 souls paid 8), the user: 「改成不扣」 (2026-10-31). `bankai!` keeps his Konpaku; the CPU's finisher-only HARD filter (`*ken-ai-bankai-strict*`) is set to 0 for every difficulty, since there is nothing to save. Ichigo and Hisagi have no re-awakening (the user, 2026-10-31: 「他們沒有再覺醒」): nothing to port. Callers: `fighter.lisp` (P), `combat.lisp` `bankai-ready-p`, `onehand.lisp`, `ai.lisp` `ai-bankai`, `ken.lisp` `ken-bankai-gate`.

## 4. Knobs

`*sub-max*` 100, `*drive-max*` 100, `*sub-dmg*` 0.20, `*sub-taken*` 0.20, `*sub-speed*` 0.10, `*sub-fs*` 0.30, `*sub-keep*` 0.5, `*drive-add*` 0.5 (tuning.lisp). `*bankai-konpaku*` is now only the debug scene's cap.

## 5. Not done

The CPU timing its awakening around SUBLIMATION; the manual's tutorial text beyond the awakening section; the learner / ASSIST / ENDLESS / ROGUE (frozen) were not touched.

## 6. HUD (webhud slots 22 / 23, `hud.js`, `hud.css`)

No second bar. The awakening bar full, SUBLIMATION piles **pink** on top of it from the left (right on P2). On the awakening the bar is emptied and SPIRIT DRIVE fills it **red** from 0, glowing when full (slot 7 is the DRIVE ‰ once awakened). The seal ring on the phone follows slot 7. The awakening bar's label reads EVOLUTION when ready (§8).

## 7. Checks (2026-10-31)

Host tests (`tests/duel-rules/sublimation.lisp`, 11 286 checks all pass in the suite: the fill and the overflow, `sub-frac` at s 1 / 0.4 / 0, the taken multiplier, 100 x 1.2 x 0.8 = 96, the Bankai rule; the two old Bankai checks rewritten), pkgcheck clean, the build. Scripted scene `tests/scripts/duel-sublimation.json` (debug 84020–84070 on the 84000 / 84003 scenes): the attacker's multiplier 0.504 at SUBLIMATION 0, 0.6048 at 100 (x1.2) and 0.57456 at s 0.4 + DRIVE 100 (f 0.7); the taken multiplier 1.0 -> 0.8; the real awakening at SUBLIMATION 50 freezes s 0.5 (f 0.25) and empties the awakening gauge; speed x1.10 at f 1; in cup 3 awakened, P with DRIVE 52 does nothing, with DRIVE 100 the form becomes BANKAI (Konpaku 9 -> 1). G2 `--cvc` moved in all three pairs (the CPU waits at a full gauge now and then): II 29 -> 30 lines (P1 4-0, 296.6 s), IK 18 -> 25 (P2 0-5, 245.1 s), KK 19 -> 17 (P2 0-4, 172.1 s); `tests/style-cvc-ref.txt` regenerated. No balance gates (the user, 2026-10-29): the long II / IK times are not judged.

## 8. Konpaku and the HUD after BLEACH Rebirth of Souls (the user, 2026-10-31)

「改成不扣」: see §3. 「幫我參考 bleach ROS 的附圖設計 HUD」, asked and answered: how far 「照圖重排」; the souls 「魂魄是由大數字跟旁邊的九個格子組成的」; the phone 「手機維持現在的直向排法，只換造型與配色」. Desktop (not `hphone`), DUEL_WEBUI §15: the Reishi bar from the edge, the soul count a big italic number at its inner end with 魂魄 beside it and nine slanted cells under the bar's inner end (spent cells grey, the Kikon's stake blood), the guard gauge (cyan, blood when broken) under the bar, the awakening as a small bar with EVOLUTION at the outer end (SUBLIMATION pink over it, DRIVE red), the flash step (the REVERSE gauge) and the kit meter at the bottom corners. Slots 24 / 25 are the guard gauge ‰ and its break. Portraits are not drawn (the screen has none behind the bars). The phone keeps its plates (flames, the flash step beside the awakening bar when there is no deck).

Reverted the same day: 「改回原本的樣子」: the HUD returned to the plates before the ROS layout (the pink / red awakening bar, §6, and the Konpaku rule stay); the ROS version is b54a8d4 (DUEL_WEBUI §15). Slots 24 / 25 are gone again.

Labels (the user, 2026-10-31: 「加「SUBLIMATION」「DRIVE」字樣」): beside the awakening bar, `SUBLIMATION` (pink) while the full bar piles it, `SPIRIT DRIVE` (red) while it fills, `DRIVE MAX` when full; `覺醒 READY` as before when neither. The label is placed absolutely so a long one does not shrink the bars (hud.js / hud.css `.awk`, slot 23).

## 9. SPIRIT DRIVE's unlocks, and Ichigo's pointers (the user, 2026-10-31)

User: 「我想在 SPIRIT DRIVE 全滿時解放追加的 J 連段與對應的 AS4 跟 NS4」. Asked, answered: NS4 / AS4 = 「第 4 個指針」; this round 「先做 Ichigo」; J 「追加 1 段，J6 之後按 SP 接 AS4」. The theme: 「把原本指針二的月牙天衝改成指針四，然後指針二的主題變成超速連斬：1. NS2 展出由慢至快的五連斬。2. AS2 則是參照原版利捷覺醒 L 的衝刺連斬，在穿過對手的瞬間會先斬成一次斬擊，穿過後會在接上數道斬擊」. The table I proposed (NS2 5 cuts S 24 / 20 / 16 / 12 / 8, dmg 30 / 30 / 35 / 35 / 60; AS2 two segments 60 + 3 x 25; NS4 / AS4 as below), the answer 「NS2 傷害調降」 (no figure: **20 / 20 / 25 / 25 / 40**, a knob), the Getsuga sealed until DRIVE is full 「是，月牙天衝 DRIVE 滿才能用」, the CPU 「這輪不調」. Then: 「覺醒前的狀態也幫我將月牙天衝改成指針三，並設計成覺醒量表沒滿時封印指針三」.

| Form | Ptr 1 | Ptr 2 | Ptr 3 | Ptr 4 |
|---|---|---|---|---|
| Shikai | the cleaver | **the rush** (RANGETSU: NS `ic-n3a`, AS2 = SOSEN > RANGETSU > TSUKI-OTOSHI, 3 segments), stance `:ic-st-rush` | **the Getsuga** (NS `ic-n2a`, AS3 = SOGA > the crescent), stance `:ic-tsuki`, **sealed until the awakening gauge is full** | none |
| KESSA | the blood chains | **超速連斬** (new): stance `:ic-k-st-haste` (low, leaning, the slab trailing), NS2 `ic-k-h1..h5` five cuts S 24 / 20 / 16 / 12 / 8, dmg 20 / 20 / 25 / 25 / 40 (the first four flinch, the last staggers), AS2 NUKI-GIRI (`ic-k-hs-as2`: a :through dash 2 m past him, 60 on the way) > KAGE-RENZAN (`ic-k-hs-as2b`: turns back, three cuts of 25, the last a knockdown), Kikon `ic-haste-kikon-cine` (new) | 千影 (the clones) | **the Getsuga**, **sealed until SPIRIT DRIVE is full**: NS4 = the old NS2 (two charges > the 漆黒 crescent), AS4 four segments (KOKUEN x2 > SOGA > the crescent, the last a launch), stance `:ic-tsuki`, Kikon 漆黒の月牙天衝 |

- **Seals** (`:core :locks` alist, `core-pointer-locked-p`, :awaken-full / :drive-full): `core-next-as` steps down to the pointer below while the AS's is sealed (Shikai: J5 + SP is AS2 while the gauge is not full); it is also capped by the kit's AS count (so a kit with three AS never gets a fourth: `*core-pointer-max*` is 4). KESSA: `:as-by-press (1 1 2 2 3 4)`, `:as-writes (1 2 3 4)`.
- **J6** (`ic-k-na6`, S 12, 55, a 2 m lunge, `:ender`): the string `ic-k-j3 > ic-k-na6` exists, refused by KESSA's `:link-ok` hook `ichigo-link-ok` unless `drive-full-p`. J6 + SP is AS4.
- **HUD**: a fourth pointer seal (hud.js, the phone's circle at 202°), `webhud` slot 24 = the sealed pointers' bit mask, a sealed seal dimmed and dashed; the pointer table in hud.js / menu.js updated.
- **Side effects, to know**: the Shikai's Getsuga used pointer 2's Kikon count profile and now uses pointer 3's (one Konpaku less), the rush the other way (`core-kikon-count` is by index); "AS n has n segments" no longer holds for the Shikai (AS2 has three, AS3 two); KESSA has no Getsuga until DRIVE is full; the CPU is untouched (its `:ns-range` moved to pointer 3).
- **Checks**: host tests 11355 pass (the pins moved to the new orders; the shared-hook pin lets KESSA have `:link-ok`), pkgcheck, build; the scripted scene `tests/scripts/duel-ichigo-pointers.json` (debug 86100–86120, ichigo.lisp `ichigo-sub-debug`): the Shikai J x5 + SP is AS2 (gauge empty) and AS3 (gauge full); KESSA J x5 + SP is AS3, J6 is refused at DRIVE 0, accepted at DRIVE full (55) and J6 + SP is AS4; NS2 hits 20 / 20 / 25 / 25 / 40; J1 J2 J3 + SP is AS2: NUKI-GIRI 60, then three 25s; NS4 and AS4's four segments (the crescent 60). G2 `--cvc`: KK identical, II 30 -> 22 lines (215.4 s), IK 25 -> 20 (196.1 s): regenerated. No balance gates.
- **Open**: the CPU does not use pointers 2 / 4 of KESSA or J6; the haste Kikon is built from streaks, review its still (`86110`); Ichigo's other forms and the other fighters have no unlocks.
