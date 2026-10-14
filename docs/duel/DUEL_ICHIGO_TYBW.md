# SOUL DUEL: Ichigo, TYBW look and motion modules (2026-10-14)

Status: **plan** (§1–§5). The plan is the lead's [G]; the user delegated the calls, see §1.
Skills: `duel-motion-style` (decide, research, plan, measure, draw), `duel-character-rework` (presentation vs sim, the
proofs), `duel-move-modules` (one grammar a form). Research: `docs/research/ichigo-rework/canon-looks.md` (every visual
state, graded A–D), `canon-motion.md` (fight by fight) and `style-refs.md` (other games' and anime's dual-blade and
greatsword styles, the archetype table, the impact tricks). Earlier design: `DUEL_ICHIGO.md` (v1, v2, the playtest
decisions), `DUEL_STRINGS.md` §2 / §12 / §13, `DUEL_DESIGN.md`.

## 1. The request

> 幫我使用這些新的 skill 改進（千年血戰篇）黑崎一護的造型與動作模組，若有認為需要改到招式與判定就進行更改並回報修改理由與改進方向即可。動作模組可以額外搜尋其他遊戲或動漫作品中雙刀與大劍的戰鬥風格，並以此為基礎進行改進並增加演出魄力。
> (the user, 2026-10-14)

Reading: the look and the motion modules of both forms (the dual Shikai, KESSA) are in scope; the motion research
extends to other games' and anime's dual-blade and greatsword styles, and the goal adds **impact (演出魄力)**. Changes to
moves and hit volumes are allowed when the lead judges them needed, reported with the reason and the direction. No
question round: the skill's "ask first" points are answered by the lead and marked [G]. The user's earlier look
decisions stand (DUEL_ICHIGO "v2: built" → "Both forms: the look", "Playtest look decisions": KESSA from the figures, the
pitch-black 漆黒の月牙天衝, the grey-black phantom clones with a white rim).

## 2. Diagnosis (at 3e078ef; the art viewer's 8-frame strips and the FK tip script)

- **Borrowed clips** (the skill's red flag): KESSA's K1 / K2 / K3 play the Shikai's `:ic-f1` / `:ic-f2` / `:ic-drop`
  (`:clip-s` retimed), posed for two blades; `:ic-drop` alone serves five moves (Shikai K3, KESSA K3, 残月返し, the clones'
  heavy link 3, KAGE-UCHI's strike); `:ic-f1` three (K1, KESSA K1, the clones' heavy); `:ic-cross` three (KOGA K2s, SŌGA at
  ×0.39, the JŪJI rush's strike), so SŌGA's 5 m flash-step lunge is drawn as a standing X.
- **The cleaver in the floor**: the right blade's tip goes under the plaza in 15 of `:ic-q1`'s 22 frames, 12 of `:ic-q2`'s,
  28 of `:ic-drop`'s, 27 of `:ic-mine`'s, 18 of `:ic-tsuki-otoshi`'s, 11 of `:ic-f2`'s (down to −0.8 m); during the J links
  the cleaver hangs point-down into the ground ahead of him. KESSA's idle holds Tensa's end 0.37 m under the floor the whole
  loop (every KESSA clip starts there).
- **One arc plane, one hand set**: K3 RAKUGA and TSUKI-OTOSHI are both two-handed overhead drops; K2 SHŌGA and the
  GETSUGA are both the right hand rising; MINEUCHI repeats K1's horizontal right-hand sweep; J1 / J2 are the same
  horizontal left-hand flick and its return.
- **Drawn reach vs the hit volume** (tip at the hit frame vs the volume's edge): K2 SHŌGA −2.15 m (the blade straight up
  overhead at S), K3 −0.70, K1 −0.37; RANGETSU's four slashes −1.5 to −1.9 (the reversed short blade at 0.5–0.9 m for a
  2.4 m arc); MINEUCHI −0.69; KESSA K1 −0.50, K2 −2.33, K3 −0.84. The J's short blade 1.2 m for a 1.4 m edge (reversed
  grip).
- **Stiff**: the hit poses are held arms on a planted stance; no anticipation squat on the J's, no follow-through past
  the hit pose, the K's recover by snapping to the idle; turns are chest twists; the cross hit pose hides both blades
  edge-on from the behind camera.
- **Impact**: no tell or hold beyond the sim's hitstop, no ground reaction on the drops, the cleaver never rests or carries
  its weight (it is waved like a stick).
