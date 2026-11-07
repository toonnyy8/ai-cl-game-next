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

- **Fill** (since 2026-11-01 only attacking fills SUBLIMATION / DRIVE: §18; as first built:): the awakening gauge's sources (damage dealt / taken, Konpaku lost, WHITE's regen) at x1.0. Before the awakening they fill the awakening gauge, and what is above `*awaken-max*` (and everything once it is full) fills **SUBLIMATION** (0–`*sub-max*` 100). After it, the same sources fill **SPIRIT DRIVE** (0–`*drive-max*` 100). Neither decays. (`awaken-overflow`, `awaken-fill!`.) Not awakening is therefore a choice: a full gauge keeps paying.
- **Bonus fraction** (`sub-frac`, of B): before the awakening `sub / 100`; after it `*sub-keep*` 0.5 x s + `*drive-add*` 0.5 x `drive / 100`, s = the SUBLIMATION fraction frozen at `awaken!`. So the awakening keeps half of what was piled up, and a full DRIVE adds half of a **full** B whatever s was (the user's answer), at most (0.5 s + 0.5) B.
- **Boosts at fraction 1** (`*sub-dmg*` 0.20, `*sub-taken*` 0.20, `*sub-speed*` 0.10, `*sub-fs*` 0.30): damage dealt x(1 + 0.2 f) (in `apply-hit`'s attacker multiplier; a `:flat` window ignores it), damage taken x(1 - 0.2 f) (`sub-taken-mods`), walk and run speed x(1 + 0.1 f) (`sub-speed-mult`), flash-step gained from hits x(1 + 0.3 f) (`pay-gauges`; AS1's steal and Hoho are not "gain from hits").
- Every kit, the CPU too; the gauges live in `gauges` (`sub`, `sub-s`, `drive`), reset with the match. A `:no-awaken` form (Hisagi's Bankai) never awakens, so only the pre-awakening part exists for it unless its kit is already awakened.

## 2. Open points

Ichigo and Hisagi have no re-awakening (the user); `drive-full-p` is the flag a kit can read if one ever does. The CPU does not wait for SUBLIMATION on purpose (its awakening roll is unchanged).

## 3. Kenpachi's Bankai

`bankai-allowed-p (free drive-full)`: P in cup 3, free as for the awakening, **with a full SPIRIT DRIVE** (it was: at most 4 of his Konpaku, DUEL_KEN_BANKAI §1.1). Asked whether the entry still costs souls (it set his Konpaku to 1, so 9 souls paid 8), the user: 「改成不扣」 (2026-10-31). `bankai!` keeps his Konpaku; the CPU's finisher-only HARD filter (`*ken-ai-bankai-strict*`) is set to 0 for every difficulty, since there is nothing to save. Ichigo and Hisagi have no re-awakening (the user, 2026-10-31: 「他們沒有再覺醒」): nothing to port. Callers: `fighter.lisp` (P), `combat.lisp` `bankai-ready-p`, `onehand.lisp`, `ai.lisp` `ai-bankai`, `ken.lisp` `ken-bankai-gate`.

## 4. Knobs

`*sub-max*` 100, `*drive-max*` 100, `*sub-attack-mult*` 1.5 (§18, §18.1), `*sub-dmg*` 0.20, `*sub-taken*` 0.20, `*sub-speed*` 0.10, `*sub-fs*` 0.30, `*sub-keep*` 0.5, `*drive-add*` 0.5 (tuning.lisp). `*bankai-konpaku*` is now only the debug scene's cap.

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

## 10. KESSA's skin and red flames (the user, 2026-10-31)

「血鎖一護的膚色更貼近紅棕色，而且手腕腳踝跟頸部圍繞的是飄盪的紅色燄氣」 (a reference picture: a red-brown torso, red flame ribbons round the neck, wrists and ankles). Art only: `(body-variant :ichigo-kessa :ichigo :palette ((:skin #xA9583F)))` (ichigo-art.lisp), KESSA's kit and his clones use it; `ichigo-red-wisps` (ichigo-look.lisp, called from `ichigo-draw`): at both wrists, both ankles and the neck three tongues of three links, swaying against his motion, a red body in alpha blend and a hot orange core, narrowing to a point. Sim byte-identical: G2 `--cvc` unchanged (II 22, IK 20, KK 17 lines). Checked in a still (behind camera); the front face colour was not seen. Not done: the awakening cinematic's body is still the Shikai's look, the wisps are straight links (smoother ribbons would need a strip primitive).

## 11. The Getsuga flame: a preview only (the user, 2026-10-31)

「我希望調整月牙天衝的特效設計，變成更加自然滑順的燄氣效果。請在實作進遊戲前先以純粹的角色模組展現給我確認」 (two references: the dark-blue glassy ribbons of a Kurosaki figure, and a black crescent sweep with torn tapered tips). **Nothing in the game uses it.** `ic-flame-cine` (ichigo-look.lisp, debug 86130, `ichigo-sub-debug`): KESSA alone on a white card, side-on; `ic-flame-tongues` draws the crescent as 46 smooth toon flame tongues along a 3.4 rad arc (the engine's `%tongue` ribbons, edge wobble 0.02), black (`+pal-black-smoke+`) with a violet-blue rim tongue on every second one, each flowing back off the arc and curling toward the tips, longest at the middle; the loop (90 f): gathering to f14, thrown f14-24, flying on and thinning from f62. Stills: `getsuga-flame-preview.png` (frames 10 / 18 / 26 / 34 / 46 / 62). To confirm before it replaces `vfx-ic-crescent` for the Getsuga (the hazard looks `ichigo-getsuga-look` / `ichigo-juji-look`, the cinematic `ic-kessa-getsuga-cine`). Open: the arc's thickness and length, the rim colour, whether the tips should be torn, the ground contact, a hit burst.

### 11.1 The sheets go into the game (the user, 2026-10-31: 「幫我讓月牙蓄力後的斬擊帶著片狀絲帶的焰氣特效」)

KESSA's Getsuga crescent after the charges (NS2 / NS4's third press and AS4's last segment, the hazards `ichigo-juji-look`, and its forming look `ichigo-form-look`) is now drawn by `ic-getsuga-flame` (ichigo-look.lisp): `ic-flame-sheets`, nine wide flat flame ribbons along the arc (broad at the base, narrowing to a point, flowing back and curling at the tips, a blue-violet sheet riding every other black one), plus 20 thin tongues between them (`ic-flame-tongues`). The Shikai's Getsuga is unchanged. The preview cinematic (debug 86130) draws the same. Art only: G2 `--cvc` unchanged. Seen in a still of NS4's cut (the black ribbons round the hit); the flight of the thrown crescent was not isolated. Open: the sheets' width and length, the rim, the swing's own trail on the blade.

### 11.2 The swing's trail, and red-black (the user, 2026-10-31: 「連揮刀拖尾也要，然後卍解的月牙顏色是紅黑色不是藍黑色的」)

`ichigo-swing-trail` (ichigo-look.lisp, from `ichigo-draw`, KESSA only): while he swings `*ic-trail-moves*` (the cuts after the black-flame charges `ic-k-n2c` / `ic-k-as2b`, the charged SAs `ic-k-sa-g1` / `-g2`, the wave's follow-up strikes), three flame ribbons stream back off the slab (from points at 45 / 72 / 99 % of hand .. tip) against the tip's step, a black one and a thinner blood-red one each, the longer the nearer the tip; the step is kept per side per tick (`*ic-trail*`: ICHIGO-DRAW runs more than once a frame). The Getsuga's colour: the rim sheets and tongues are blood red (`+pal-blood+`) on every black one, with an ember core on every third, not the blue-violet of the first preview. Art only (G2 `--cvc` unchanged). Seen in NS4's cut; the trail itself is faint in a still (it scales with the tip's speed). Open: its strength, the Shikai's Getsuga swing.

### 11.3 No hair-like strands (the user, 2026-10-31: 「月牙本身不要有像髮絲的焰氣」)

`ic-getsuga-flame` is the nine broad sheets only: the row of thin tongues (`ic-flame-tongues`, which read as strands of hair) is gone from the crescent (the function stays, used by nothing now); the blood-red rim sheet on each black one is 0.8 of its width (it was 0.45, a thin red thread), the ember core 0.3 (0.18). Art only (G2 `--cvc` unchanged). The swing trail's ribbons (§11.2) are unchanged.

### 11.4 The crescent back to its clean look (the user, 2026-10-31: 「月牙還是原本乾淨的樣子就好」)

KESSA's Getsuga crescent (`ichigo-juji-look`, `ichigo-form-look`) is `vfx-ic-crescent` again, as before §11.1. Kept: the swing's trail (§11.2: the ribbons off the slab, `ichigo-swing-trail`), KESSA's skin and red wisps (§10). Left in the code, used by nothing in play: `ic-getsuga-flame`, `ic-flame-sheets`, `ic-flame-tongues` and the preview cinematic (debug 86130). Art only: G2 `--cvc` unchanged.

## 12. The Shikai's J5 sealed, KAGE-RENZAN's held pose, the phone's gauges, the neck flames (the user, 2026-10-31)

- **J5 sealed with the Getsuga** (「始解封印月牙時請連同 J5 一起封印」): the Shikai's fifth J (`:ic-j3`, which opens AS3) is refused by the base kit's `:link-ok` hook `ichigo-link-ok` (now shared with KESSA's J6) unless the awakening gauge is full; sealed, the string ends at J4 and J4 + SP is AS2. The shared-hook pin in tests/duel-rules/hisagi.lisp now lets Ichigo's kits have `:link-ok`. G2 `--cvc`: II 22 -> 23 lines (P1 2-0, 225.3 s), IK and KK unchanged; regenerated.
- **KESSA's AS2b KAGE-RENZAN** (「請固定住當時穿過對手的姿勢，然後在對手身上爆開連斬，現在會轉過身在揮刀的姿勢不是我想要的畫面」): he no longer turns. The segment holds one pose, `:ic-k-pass` (a low lunge, the slab swept behind him: a one-key clip, ichigo-art.lisp), for 38 f; its own hit windows are gone; at f8 / 14 / 20 `ichigo-renzan-1..3` throw a strike of the windows of `:ic-k-rz-a` (25, a flinch; `-b` a knockdown on the third), thrown from where he stands at the opponent (`ichigo-strike`, an `:ic-hit` hazard of 3.4 m, 360 deg, so his facing away does not matter) and a slash bursts on the opponent's body (`ichigo-renzan-look`: a black-red slash and a white core at 0.7 / -0.8 / 1.5 rad across him, a flash). Checked: J1 J2 J3 + SP + SP: NUKI-GIRI 60, then three 25s (a five-hit combo, 88 damage), and a still of the held pose with the burst on Kenpachi.
- **The phone's gauges** (「手持模式的 SUBLIMATION 跟 SPIRIT DRIVE 顯示有問題」): the phone has no awakening bar, only the 爆 seal's ring: it now carries SUBLIMATION in pink over the awakening ring (`.sbg`, `--sb`) and SPIRIT DRIVE in red (breathing when full), from `els.rv`'s `data-m`. Debug 86104 / 86105 / 86106 set the deck's scenes (Shikai with the gauge full and SUBLIMATION 60, KESSA with DRIVE 60, DRIVE full; run with `--mobile --size 390x844`). Seen in stills (the pink ring, the red ring). The ring has no label; the ring's text is not drawn.
- **The neck flames** (「脖子的焰氣不動時請向四方擴散，不要只往上」): six tongues round the neck, turning slowly, spreading on every side while he stands still (`still` = 1 - speed / 2), a little up; moving, they trail back against him. The limbs' tongues are as before. Seen from behind: flames to both sides of the neck.
- **Clip inventory**: `:ic-k-pass` added to `*clips-5*` (tests/duel-rules/core.lisp).

### 12.1 AS2a's dash shortened, NS2's rhythm faster (the user, 2026-10-31: 「AS2a 跑太遠了」「NS2 的加速節奏要再更快」)

- **NUKI-GIRI** (`ichigo-haste-dash`): the dash goes 0.8 m past him over 12 f (it was 2 m over 14, capped 8 m; now capped 6 m).
- **超速連斬 NS2** (`ic-k-h1..h5`): startup 22 / 15 / 11 / 8 / 6 f (was 24 / 20 / 16 / 12 / 8), recovery 14 / 11 / 9 / 8 / 20 (was 18 / 14 / 12 / 10 / 22); damage unchanged (20 / 20 / 25 / 25 / 40). Scripted scene: all five cuts in 90 f of presses (it was 122), the hits 22 / 18 / 15 / 13 f apart. The first stays above the 14 f tell rule. The scene's presses were retimed (`ichigo_pointers_script`). G2 `--cvc` unchanged (the CPU does not use it).

### 12.2 NS2 must connect, and the speed-up grows (the user, 2026-10-31: 「NS2a 跟 NS2b 接不起來」「NS2 的修改要求不是整體變快，是越後面的加速要提升更多」)

- **Why NS2a > NS2b did not connect**: the cuts were flinches (18 f of stun) and the next cut landed 23 f (before 27 f) after the last: the victim was free for the gap. Now the cuts are `:stagger` (26 f; the fifth too), and the gaps are shorter than that.
- **The rhythm** (not "all faster", but each step quicker than the one before): startup 22 / 17 / 12 / 6 / 3 f (steps -5 / -5 / -6 / -3, the last at the floor), recovery 12 / 10 / 8 / 6 / 20; damage 20 / 20 / 25 / 25 / 40. Measured hit to hit in the scripted scene: 25, 19, 13, 10 f (the first cut's hit at f22). All five connect (the scene's presses retimed: 0 / 0.5 / 0.85 / 1.15 / 1.35 s). G2 `--cvc` unchanged. Not seen: the stun of the victim frame by frame (the log shows the five hits, not the combo's HUD).

### 12.3 The cuts' motion speeds up too (the user, 2026-10-31: 「不只起手跟後搖，還有斬擊的動作模組也要加快」)

The first rhythm only moved the startup and recovery frames; the clips played at their authored speed only where it happened to fit (the third cut's `:ic-k-cut` (authored S 8) even played at 0.67 of it, slower). Now each cut's clip plays at authored S / startup, and the clips are chosen so that speed climbs: cut 1 `:ic-k-f1` (authored 18) over 22 f = x0.82 (the slow tell), cut 2 `:ic-k-f2` (20) over 17 = x1.18, cut 3 `:ic-k-f3` (21) over 12 = x1.75, cut 4 `:ic-k-f2` over 6 = x3.3, cut 5 `:ic-k-f1` over 3 = x6 (a blur: the whole swing, active and follow-through included, plays at the same x). Frames, damage and hits unchanged (the same five hits; G2 `--cvc` unchanged). Not seen frame by frame: the last cuts at x3-x6 are very fast, a still of them would help; soften if they read as a snap.

### 12.4 The swing trail removed (the user, 2026-10-31: 「幫我將揮刀拖尾移除」)

§11.2's `ichigo-swing-trail` (the flame ribbons off the slab, `*ic-trail-moves*`, `*ic-trail*`) is deleted from ichigo-look.lisp and no longer called from `ichigo-draw`. Kept: KESSA's skin and red wisps (§10), the clean crescent (§11.4). Art only: G2 `--cvc` unchanged.

## 13. KESSA's J swing as a whole-body chain (the user, 2026-10-31: 「將一護卍解的 J 揮刀動作做的更加自然流暢，現在的動作大多看起來像單純靠轉動手腕揮劍」)

Cause: the J clips (`:ic-k-jab` J1, `:ic-k-back` J2, the long `:ic-k-cut` J3 / J4) moved the slab by the shoulder and wrist while the legs and torso barely changed between the wind-up and the hit (the wrist alone went to -126 / -153). Now each is a kinetic chain with the hit pose (the `:s` snap, so the reach and the tip's place) **unchanged**: a loaded wind-up (weight on the back leg, the knees bent, pelvis and chest wound farther, the elbow folded 60+ and the wrist level instead of cocked), then the **hips unwind first** (frame 6: pelvis back, chest still wound), the chest follows one frame later with the root travelling forward and the front leg taking the weight (frame 7: the elbow opening), the hit, and a carried-through key (frame 11) with the wrist loosened (-100, then -95 / -84, was -139 / -116) so the follow-through comes from the shoulder and chest. J2's low drag has the same order. Not changed: J3 `:ic-k-wrap-j` (already a full-body turn), J4 `:ic-k-uchi`, the K clips. Stills: `tests/` has none; debug 86140+f (the frame f, 0-49) after 86190+n (the clip: jab back wrap-j cut uchi f1 f2 f3) holds a clip's frame on a white card (`ic-clip-cine`, `*ic-pose-ang*` turns the camera 90 deg with 74989). Art only: G2 `--cvc` unchanged. Seen: J1 frames 0 / 3 / 5 / 7 / 8 / 10 / 12 / 15 before and after (the wind-up now loads the legs and torso); J2 not looked at frame by frame.

## 14. KESSA's press table 1 2 2 3 3 4, and J6 > AS4 chaining (the user, 2026-10-31)

「幫我將卍解後的指針從 1 1 2 2 3 4 改成 1 2 2 3 3 4」 and 「從 J6 接續到 AS4 時連擊串不起來」.
- **Press table**: KESSA's `:as-by-press` is `(1 2 2 3 3 4)`: J1 + SP is AS1, J2 / J3 AS2 (超速連斬), J4 / J5 AS3 (千影), J6 AS4 (the Getsuga, still sealed with SPIRIT DRIVE). (Before: J1-2 AS1, J3-4 AS2, J5 AS3, J6 AS4.) The Shikai's table is unchanged (1 1 2 2 3).
- **Why J6 > AS4 did not chain**: AS4's two charges (KOKUEN) had no hit window, so SOGA, the third segment, landed about 50 f after J6's hit, long past its 26 f stagger; J6 was also an `:ender`, pushing him off. Now the two charges are black-flame cuts (`:ic-k-as4` S 8, `:ic-k-as4b` S 7, 15 stagger each, 2.8 m) and J6 is no ender. Scripted scene: J6 55, KOKUEN 15, KOKUEN 15, SOGA 50, the crescent 60, each hit within the last one's stagger at close presses (SOGA's startup is 18 f). Pins in tests/duel-rules/sublimation.lisp; triangle.lisp lets KESSA's last J be no ender. G2 `--cvc`: II 23 -> changed (regenerated), IK and KK unchanged.

## 15. PRACTICE's P1 AWAKEN row, and NS2e launches (the user, 2026-10-31)

- **P1 AWAKEN** (「練習模式的數值調控增加覺醒量表等級」): a pause row after GAUGES (flow.lisp `:p1-aw`, `*practice-aw-levels*`): `0 / 50 / FULL / SUBLIMATION 50 / SUBLIMATION FULL / DRIVE 50 / DRIVE FULL` (left / right cycles, in force at once and again after RESET POSITION). 0 / 50 / FULL set the awakening gauge (SUBLIMATION 0); SUBLIMATION 50 / FULL the gauge full and SUBLIMATION at that; DRIVE 50 / FULL set SPIRIT DRIVE once he is awakened (the gauge is set full until he is: press the awakening, the level then lands). A fighter already awakened keeps his gauge for the pre-awakening levels. GAUGES INFINITE still holds the awakening gauge full. The page's label: P1 覺醒 (hud.js). Scripted: `tests/scripts/duel-practice.json` (the rows after GAUGES shift by one: P1 HP row 7, CAMERA row 13; a new tail sets SUBLIMATION 50 then FULL; the log lines `duel practice awaken level ...` and the still `practice-pause-awaken`): 0 / 50 / FULL / SUBLIMATION 50 (gauge 100, sub 50) / SUBLIMATION FULL (100, 100) as written.
- **NS2e** (「NS2e 改成將對手擊飛，然後延長自身後搖」): `:ic-k-h5` (the fifth 超速連斬 cut) is now `:on-hit :launch` (it staggered), its recovery 20 -> 42 f, and it no longer opens an SA gap (nothing follows a launch: the host pin that a segment something follows must not launch caught it). Checked: the cut hits for 40 and the opponent is AIR in the next frames, Ichigo stays in the move ~40 f longer. G2 `--cvc` unchanged. Not seen: the launch's height and the long recovery's look.

## 16. Ichigo's sealed pointers taken out again (the user, 2026-11-01)

User: 「抱歉，我還是想要將一護的系統調回原本沒有封印的狀態，請先跟我討論哪些東西需要還原」. Discussed with a table of the pieces; answers: the Shikai 「完全回到原本」, KESSA 「完全回到原本」, SPIRIT DRIVE itself 「保留」.
- **Back to the tables of before §9** (2026-10-30): Shikai pointers 1 cleaver / 2 the Getsuga / 3 the rush, `:as-by-press (1 1 2 2 3)`, no `:locks`, J5 always there (the `:link-ok` hook and `ichigo-link-ok` are gone); KESSA pointers 1 chains / 2 the Getsuga (NS2 charges, AS2 SOGA > the crescent) / 3 the clones, `:as-by-press (1 1 2 2 3)`, no pointer 4, no J6 (the string J5 > J6 is gone), no AS4, no 超速連斬 pointer. The HUD's pointer tables (hud.js) and the character card (menu.js) are back; the fourth seal's markup stays, hidden for a kit with three.
- **Kept**: SPIRIT DRIVE itself (§1-§8: the gauges, SUBLIMATION's pink and DRIVE's red, the +20 / -20 / +10 / +30 boosts, Kenpachi's Bankai at a full DRIVE, the labels, the phone's ring), KESSA's skin and red wisps (§10), the clean crescent (§11.4), the J clips' body chain (§13), the practice row P1 AWAKEN (§15), the generic parts of the core (`:locks` / `core-pointer-locked-p` / the four-pointer `*core-pointer-max*` and the AS cap by the kit's AS count: no kit uses them now), the debug scenes 86100+.
- **Left in the code, used by nothing**: the moves `ic-k-h1..h5`, `ic-k-hs-as2` / `-b`, `ic-k-rz-a/b`, `ic-k-as4` / `-b`, `ic-k-na6`, the clips `:ic-k-st-haste` / `:ic-k-pass`, `ic-haste-kikon-cine`, `ichigo-renzan*`, `ichigo-haste-dash` (the record of §9 / §12 / §14: the rhythm, the strikes at the victim, the held pose), so they can be put back from here or from the commits 927aafe .. bbeee33.
- **Checks**: host tests 11294 pass (the Ichigo pins back to the old tables, new pins: no locks, `(1 1 2 2 3)`, no `:link-ok`), pkgcheck, build; scripted: the Shikai's J x5 + SP is AS3 (pointer 3) with the gauge empty, KESSA J x3 + SP AS2 (pointer 2), J x5 + SP AS3. G2 `--cvc` returned to the lines of §522's SUBLIMATION commit (II 30 lines, IK 25, KK 17); `tests/style-cvc-ref.txt` regenerated. The scene script `duel-ichigo-pointers.json` is deleted (it tested the removed tables).

## 17. Temporary pointer switch with SUBLIMATION / SPIRIT DRIVE (the user, 2026-11-01)

User: 「我想嘗試在 DRIVE 全滿時追加新系統：在 NS 攻擊可以通過左右鍵/左滑右滑臨時切換指針並改成使用對應的 NS 攻擊，當 NS 攻擊結束就會切回來，且在臨時切換下不能再度切換。」
Answers: SP moves lock movement so no input conflict; 「在 NS 每下打完後都能切」; the cost 「可以，我挺中意這個設定的」 (0.25 B each); all three
characters; 「既然要消耗 DRIVE，那就不需要 DRIVE 滿了」; 「SUBLIMATION 也一樣能透過消耗量表發動」; AskUserQuestion: 0.25 B, the target's segment 1,
the whole target route, left = previous / right = next, cyclic.
- **Rule** (`core-switch-target`, `core-latch-step`, core-sim.lisp): in an NS segment's gap, the stick left / right (relative to the opponent, |strafe| > 0.5) + SP
  latches `:sw`; once the segment's active frames are over, the previous / next pointer's NS from segment 1 starts (`fighter-sp-ptr` = it, so its Kikon is that
  pointer's). `fighter-ptr` is never changed, so the pointer is back by itself; `fighter-tmp` marks the route and blocks a second switch until the route ends
  (an SA / AS / neutral clears it). Not from neutral (a held stick would spend it by accident).
- **Cost / condition**: `*drive-switch*` 0.25 x the gauge max; SPIRIT DRIVE after the awakening, SUBLIMATION before it; at least that much left. A human only (`(not (brain e))`: the CPU never, so `--cvc` is untouched).
- **HUD**: the pointer slot shows the temporary pointer. The phone uses the joystick's left / right + the SP tap.
- **Debug**: 86107 KESSA with DRIVE 20, 86108 Shikai with SUBLIMATION 60 (86105: KESSA DRIVE 60).
- **Checks**: host tests 11295; pkgcheck; scripted `duel-drive-switch.json`: D+SP in KESSA's NS1 gap -> NS2 (pointer 1 -> 2), A+SP -> NS3 (1 -> 3), a second D+SP is the plain next segment, no stick the plain next segment, Shikai SUBLIMATION 60 switches, DRIVE 20 refused.

### 17.1 The charge carries over, and NS3's clones replay a temporary route (the user, 2026-11-01)

User: 「如果確認真的沒生效就改，然後分身也要重現其他 NS 的動作」 (after the scripted check: NS2 > NS3 gave the plain SA, the clones x0.10).
- **Charge**: a switch out of an NS2 segment keeps its charged SA (`fighter-csa`) for the next SA of the route, so NS2 > NS3 > J is the charged SA (x1.4 / x1.7) and the string after it carries the x (cleared by an SA, an AS or neutral).
- **Clones**: while a temporary route is on, NS3's live clones also play its NS segments (`clone-replay-watch`, x0.1; NS3's own segments excluded: they are the clones' theme). Before only his J / AS were replayed.
- **Checks**: scripted: ptr 2, SP, D+SP, J, J2 -> `IC-K-SA-G1`, `clone replays IC-K-J2 x0.14` (before: `IC-K-SA`, x0.10); ptr 3, SP, D+SP -> `clone NS-A replays IC-K-N1A x0.10`; the NS3 > NS2 case as before.

### 17.2 KESSA's SA uses J1's motion (the user, 2026-11-01)

User: 「他們的動作都只是不同的 J1 為什麼還有特製動作？」 -> 「做法一」. KESSA's plain SA `ic-k-sa` played its own `:ic-k-f1` (a lunge); the charged SAs already played J1's `:ic-k-jab` / J2's `:ic-k-back`. Now `ic-k-sa` plays `:ic-k-jab` (`:clip-s 8`) like the charged one; its numbers (S 10, slide 3.0 m, reach 2.6, 50, stagger) are unchanged, so the lunge is the move's `:slide`, not a clip. The Shikai's SA was not touched. Scripted: ptr 1 SP, J -> `IC-K-SA` hits 50 (f+10).

### 17.3 The thumb's switch: a sideways flick in an NS gap (the user, 2026-11-01)

User: 「我目前手持模式沒辦法使出切換 NS」 (one thumb cannot hold a direction and tap SP), then 「直接將滑動識別為切換+NSa」.
In the one-hand deck a sideways flick (|dx| > 1.73 |dy|, the recogniser's up-cone) while P1 is in an NS segment and `core-switch-ready-p` holds is read as the SP press with the flick's direction as the stick (`switch-flick-p`, onehand.lisp `touch-button`: :quick + :mod down, :step suppressed): right = the next pointer, left = the previous, its NSa starts after the segment's active frames, the same cost and rules as §17. Without the gauge (or outside an NS) the flick stays a Step. Scripted (`duel-drive-switch-phone.json`, --mobile --size 390x844, debug 86105 / 86107): SP tap then flick right -> `NS pointer 1 -> 2`, flick left -> `1 -> 3`, DRIVE 20 -> no switch.

### 17.4 Pointer shown back in neutral; the practice's infinite gauges (the user, 2026-11-01)

- 「臨時指針切換後的印章顯示問題，再切換後如果回到中立狀態沒有再次攻擊就不會切回來」: `fighter-tmp` was only cleared by the next move, so the HUD kept the temporary pointer in neutral. `to-idle` now clears `tmp` / `csa`, and the HUD shows `tmp` only while he is in a move.
- 「練習模式如果將 gauges 設定成無限，那 sublimation 跟 drive 也應該要是無限」: GAUGES INFINITE (flow.lisp `practice-step`) also keeps SUBLIMATION full (before the awakening; `sub-full` set) and SPIRIT DRIVE full (after it).

### 17.5 Before the awakening: SUBLIMATION must have been full once (the user, 2026-11-01)

User: 「然後讓 sublimation 全滿過的話，覺醒前也開放使用切換系統，且扣除量表時不會扣到覺醒量表」. `gauges-sub-full` latches when SUBLIMATION reaches its maximum (`awaken-fill!`; the practice rows set it at SUBLIMATION FULL / INFINITE); before the awakening the switch needs that latch and 0.25 B of SUBLIMATION left, and pays only SUBLIMATION (the awakening gauge stays full). After the awakening it is SPIRIT DRIVE >= 0.25 B as before. (Before: any SUBLIMATION >= 0.25 B opened it.) Scripted: Shikai SUBLIMATION 60 with the latch (debug 86108) switches; the same without it (86109) does not; DRIVE 20 does not.

### 17.6 Back to any 25% (the user, 2026-11-01)

User: 「幫我改回只要有 25% 就能使用」. Reverses §17.5's condition: before the awakening the switch needs only SUBLIMATION >= 0.25 B (still paid from SUBLIMATION alone, the awakening gauge untouched). `gauges-sub-full` and its setters (`awaken-fill!`, the practice rows, debug 86108) are removed; debug 86109 (the "never full" refusal scene) is gone. Scripted: Shikai SUBLIMATION 60 (86108) switches; DRIVE 20 (86107) does not.

### 17.7 Routes the switch opens (the user, 2026-11-01)

User: 「透過切換系統可以組合出更多有趣的連動技能，像一護就能將分身與月牙蓄力結合。而修兵始解能在 NS1 打完遠程後用 NS3a+SA 拉到近身攻擊，或是使用 NS3b + SA 補足遠程傷害，卍解也能直接用 NS1a 控制距離再切換成 NS2 的聚拉高輸出。」, then 「幫我紀錄並用腳本測試」. These are the intended routes. Script `tests/scripts/duel-switch-routes.json` (Hisagi; debug 83600+d Shikai with SUBLIMATION 60, 83700+d the Bankai's ranged mode with DRIVE 60, d / 10 m from an idle Kenpachi; 83099 logs the distance) and `duel-drive-switch.json` (Ichigo, debug 86105). Damage as logged:

| Route | Start | Hits (damage) | Total | Note |
|---|---|---|---|---|
| Ichigo KESSA ptr 3: NS3a, A+SP (NS2a), J, J2, J3 | 1.4 m | NS3a 18 + clone, NS2a (clone replays x0.10), SA-G1 55, J2 30 + clone 4, J3 30 + clone 4 | | clones and the charge together (§17.1) |
| Ichigo KESSA ptr 2: NS2a, D+SP (NS3a), J, J2 | 1.4 m | the charged SA x1.4, the clone's J2 replay x0.14 | | §17.1 |
| Shikai: NS1a, A+SP (NS3a), J (SA 引寄), J2 | 6.0 m | 62, NS3a whiffs, 40, 30 | 132 | SHIBARI reaches 4.5 m; 引寄 still drags him to 0.9 m |
| Shikai: same | 4.5 m | 62, 40, 40, 30 | 172 | |
| Shikai: NS1a, NS1b, A+SP (NS3a), J, J2 | 4.5 m | 62, 56, 40, 40, 30 | 228 | |
| Shikai: NS1a, A+SP (NS3a), SP (NS3b), J (SA 放電) | 6.0 m | 62, NS3a whiffs, 25, 60 | 147 | stays at 6 m |
| Shikai: same | 4.5 m | 62, 40, 25, 60 | 187 | |
| Shikai: NS1a, NS1b, A+SP (NS3a), SP (NS3b), J (SA 放電) | 6.0 m | 62, 56, NS3a whiffs, 25, 60 | 203 | |
| Shikai: NS1a, NS1b, NS1c, A+SP | 6.0 m | 62, 56, 80, NS3a starts (whiffs) | | a switch after the last segment works too |
| Shikai base: NS1a, NS1b, NS1c | 6.0 m | 62, 56, 80 | 198 | |
| Bankai base: WA, OGI, ISSEI | 2.5 m | 26, 31, 48 | 105 | WA pushes him to 4.5 m |
| Bankai: WA, D+SP (NS2a TABA), SP (TATAKI), SP (OMEGURI) | 2.5 m | 26, 50, TATAKI whiffs, 86 | 162 | TATAKI reaches 3 m; he stays at 4.5 m |
| Bankai: WA, D+SP (TABA), J (the gathered SA), J2 | 2.5 m | 26, 50, 45, 29 | 150 | |

Every route connects. Two whiffs follow from the reaches, not from the switch: NS3a SHIBARI (4.5 m) against a victim NS1 left at 6 m, and the Bankai's TATAKI (0-3 m) against one WA pushed to 4.5 m. Nothing was changed.


## 18. SUBLIMATION and DRIVE filled by attacking (the user, 2026-11-01)

User: 「進入 SUBLIMATION 跟 DRIVE 後，改成以『進攻』作為提昇量表的手段」. Asked (AskUserQuestion), answered: what counts 「傷害 + 讓對手失去魂魄 + 爆氣都加，橙色爆氣造成傷害時回覆量提昇」; the rate 「×3（約 950 點滿）」.

- **The awakening gauge** keeps its four sources (damage dealt / taken, Konpaku lost, WHITE's regen) unchanged.
- **Once it is full (SUBLIMATION) and after the awakening (DRIVE)**, only attacking fills (`awaken-overflow`'s new XS, `sub-attack-gain`):
  - damage dealt (the real damage, not the move's base) at `*awaken-dealt*` 0.035 x `*sub-attack-mult*` **1.5** = 0.0525 a point, about 1905 damage to fill (3.0 / 0.105 / about 950 until §18.1); ORANGE multiplies it by `*orange-gain*` 1.5;
  - Konpaku taken from the opponent: `*awaken-per-konpaku*` 10.5 each to the **attacker** (a Kikon or a Soul Break; the loser's awakening gauge still gets its 10.5);
  - a WHITE Burst's regen, 1.4 a second as before.
- Taking damage and losing Konpaku no longer fill them. The awakening gauge's overflow past 100 is dropped (it went to SUBLIMATION before).
- Knob: `*sub-attack-mult*` 1.5 (3.0 until §18.1; tuning.lisp). The Konpaku and WHITE rates stay x1.0 (the ×3 answer was asked about damage).
- **Checks**: host tests 11298 pass (`tests/duel-rules/sublimation.lisp`: the fill rewritten for X / XS, `sub-attack-gain` 100 dmg 10.5, ORANGE 15.75, 2 Konpaku 21, about 952 damage to fill); pkgcheck clean; build. Scripted `tests/scripts/duel-sublimation.json` (two new scenes at DRIVE 50): Kenpachi's J1 (35 base, about 14 real) at SUBLIMATION 0 -> 1.5; Ichigo's J1 on him at SUBLIMATION 0 -> 0 (before: it rose); at DRIVE 50 his J1 -> 51.6, Ichigo's J1 on him -> 50.0. G2 `--cvc` moved in all three pairs: II 30 -> 31 lines (P1 5-0, 311.0 s), IK 25 -> 18 (P2 0-4, 174.5 s), KK 17 lines changed (P2 0-4, 172.1 s); `tests/style-cvc-ref.txt` regenerated. No balance gates.

### 18.1 The attack rate x1.5 (the user, 2026-11-01: 「幫我將 3 倍改成 1.5 倍」)

`*sub-attack-mult*` 3.0 -> **1.5**: damage dealt fills SUBLIMATION / DRIVE at 0.035 x 1.5 = 0.0525 a point, about 1905 real damage to fill (ORANGE x1.5 on top: 0.07875). The Konpaku (10.5 to the attacker) and WHITE (1.4 a second) rates are unchanged. Checks: host tests 11298 pass (the pins 5.25 / 7.875 / about 1905); pkgcheck, build; scripted `duel-sublimation.json`: Kenpachi's J1 at SUBLIMATION 0 -> 0.7 (1.5 at x3), at DRIVE 50 -> 50.8 (51.6); taken still 0 / 50.0. G2 `--cvc` moved: II 31 -> 28 lines (P1 3-0, 279.9 s), IK 18 lines changed (P2 0-5, 182.4 s), KK 17 lines changed (P2 0-4, 172.1 s); `tests/style-cvc-ref.txt` regenerated. No balance gates.

## 19. KESSA's NS2c named GETSUGA TENSHO (the user, 2026-11-02)

User: 「還有一護卍解的 NS2c 是月牙天衝而不是月牙十字衝，能跟我說下 NS2 的當前設定嗎」; shown the table (NS2a charge 1: S 20 / R 14, its SA 55 and the string x1.4; NS2b charge 2: 16 / 14, its SA 80 and x1.7; NS2c the wave: S 20 / R 26, 150, knockdown, 3.6 m wide, 14 m/s over 12 m, guard 22; x0.95 KESSA), then 「好，如你所說處理名字就行」. `:ic-k-n2c` was copied from the Shikai's JUJISHO with its callout; it is drawn as one small 漆黒 crescent already. Its callout is now **GETSUGA TENSHO** (as KESSA's AS2b). Numbers unchanged; the code's `juji` names (`ichigo-juji-look`, `ichigo-juji`) stay, shared with the Shikai. A callout is a displayed string only (G2 `--cvc` identical; host tests 11299 pass with the callout pinned in `sublimation.lisp`).

## 20. SUBLIMATION and DRIVE fill twice as fast (the user, 2026-11-07)

User: 「並幫我將 sublimation 跟 drive 的累積速度改成目前的 2 倍」.

- New knob `*sub-gain*` 1.0 -> **2.0** (tuning.lisp): `awaken-overflow` multiplies XS by it before adding it to SUBLIMATION or DRIVE, so
  every source doubles together. That means damage dealt (0.0525 -> 0.105 a point, about 1905 -> **about 952** real damage to fill;
  ORANGE x1.5 on top), Konpaku taken (10.5 -> **21** each) and WHITE's Burst refill. The awakening gauge's own rates (`*awaken-dealt*`,
  `*awaken-taken*`, `*awaken-per-konpaku*`) are unchanged. §18.1's `*sub-attack-mult*` 1.5 stays; the x2 sits on top of it.
- Tests: `tests/duel-rules/sublimation.lisp`. The two overflow lines now read 30 + 2 x 6 = 42 (SUB) and 2 x 12 = 24 (DRIVE), and
  `*sub-gain*` is pinned at 2.0. The manual's SUBLIMATION entry says about 950 damage and 21 a Konpaku.
- A sim change: G2 `--cvc` regenerated together with DEVLOG §614–§615 (the wake-up roll, the AS Kikon's pointer).
