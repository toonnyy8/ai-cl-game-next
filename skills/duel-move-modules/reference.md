# Core move modules: evidence and encoding from Ichigo's rework (2026-10-27 → 10-28)

Sources: `docs/duel/DUEL_CORE.md` (§1 scope, §2 the table, §3 the pointer, §4 Kikon / Soul Break, §5b the pointer rule, §6 Ichigo),
the user's note `docs/duel/DUEL_CORE_DOC.zh-TW.md`, `docs/DEVLOG.zh-TW.md` §410–§445. Code: `duel/lisp/core.lisp` (pure, host-tested),
`core-sim.lisp`, `core-ai.lisp`, `kit.lisp` (`core-segments`, `build-core-classes`, `kit-core-move`), `ichigo.lisp`, `combat.lisp`
(`apply-hit`). "G" = generalizable, "P" = project-specific. The old grammar (Lille's stance strings, SP2, the O ender): `git show
e55304e:skills/duel-move-modules/reference.md`.

## 1. The encoding (P)
- **The kit's `:core` plist** (`defkit`):
  - `:ns (n1 n2 n3)`, `:as (a1 a2 a3)`: the first segment of each.
  - `:sa`: the kit's SA.
  - `:as-by-press (1 1 2 2 3)`: the AS by attack presses since neutral.
  - `:stances (clip1 clip2 clip3)`: the idle clip by pointer (`fighter-stance-clip`).
  - `:kikon-cines (c1 c2 c3)`: the Kikon cinematic by pointer, also the Soul Break's (`core-pointer-cine`).
  - `:ns-range (nil (lo hi) nil)`: the CPU's ranged band by pointer.
  - `:mult`: the kit's damage x (pacing).
  - `:no-awaken`.
- **A move's `:params`**:
  - `:ns-next`: the next segment (NS or AS).
  - `:sa`: this gap's own SA.
  - `:kikon-strike`: a wave segment's follow-up.
  - `:charge-mult`: arms the string's x.
  - `:follow-cap` (m/s of the Kikon dash-in), `:look :flash-step`, `:steal-fs`, `:chain` (a look's lash).
  - `:ns-next` is read by `mv-ns-next`; `:sa` by `mv-sa-move`.
- **Classes**:
  - `build-core-classes` tags the J string NA, every segment of `:ns` / `:as` NS / AS, the SAs SA, and a segment's `:kikon-strike`
    its segment's class.
  - One move gets one tag: a strike shared by an NS segment and an AS segment needs a `-as` copy (§437).
- **Copies**: `defmove-copy` keeps the source's `:enter`; on-frames before it are skipped (KESSA's AS3 on-frames at 4 / 2 after an
  `:enter` 6 / 7, §431).
- **The sim side** (`core-sim.lisp`):
  - `core-note-start!` records class, start tick, the hold (`fighter-sp-held`: `t`, or `:rearm` on the phone) and the charge x.
  - `core-move-sp!`, `core-sa-start!` and `core-latch-step` latch presses; the latched move starts when the segment's active
    frames end.
  - `core-verdicts` judges a step's hits as a set.
  - `core-follow-step` runs the Kikon's dash-in: the confirm, the undo, the cues.

## 2. The pointer rule and its table (§5b, P → G)
- The user, 2026-10-28: 「以後每個指針的 NS 與指向他的 AS 以及對應的毀魂技都要有風格與效果上的連動關係」.
- One table per form: pointer × (theme, stance, NS, AS, Kikon cinematic). Ichigo's is DUEL_CORE §5b.
- **G:** state the theme first; fill every cell from it; a cell borrowed from another theme is the thing the user will ask to change
  (KESSA's pointer 1 played the Getsuga until §428).
- An AS's Kikon and Soul Break profile follow the pointer the AS **writes** (§435). The Soul Break at zero Reishi plays the current
  pointer's cinematic (§439).

## 3. The Kikon hold as built (§4, §436–§444, P → G)
- **Start of the hold:** each NS / AS segment starts `fighter-sp-held` = t if the button is down.
  - A let-go on any step clears it (`core-hold-step`), so a mash is not a hold (§418).
  - The phone starts `:rearm`. Since §442, only a contact that went down in the SP zone (`touch-oy` < `touch-split-y`) arms it.
- **Judged at the hit, then confirmed:** after the hit, the button must stay down for `*core-kikon-confirm*` 12 frames of the dash-in
  (after the hitstop, §440).
  - A let-go inside them undoes the follow-up: the hit becomes the ordinary one it would have been (`fighter-kikon-undo`), and the move
    goes on where it hit.
  - The cues wait for the dash-in's first frame, so a tap released in the hitstop shows nothing.
- **G (a hit-frame hold check misreads taps):** a move whose hit lands before a tap lifts (AS3 at 8 f) reads every tap as a hold.
  - Fix: judge after the hitstop. Nothing in the sim moves during it, so the undo there is exact.
- **A wave's Kikon** (§437): the hazard records its segment (`hazard-sp-mv`). Its hit, with the hold kept, starts the segment's
  `:kikon-strike` in phase `:follow`.
- **The CPU's hold is a press length** (`cai-sp`: 40 frames when it wants the Kikon). A rule that lengthens the hold changes the
  CPU's Kikon count and the pace: IK 201.1 s and HI 204.1 s until the CPU held through the confirm (§440).

## 4. Carried effects (P → G)
- **The charge** (§421, §423): a charged SA arms `:charge-mult`. NA links and AS keep it; any opener, NS or `to-idle` drops it; it
  multiplies every hit of the string after the SA.
- **KESSA's clones** (§425, §438):
  - Spawned by the NS3 segments. They replay each J / AS he starts after NS3, 4 / 8 frames behind (`*clone-replay-lags*`, sim ticks,
    since `*match-tick*` freezes in hitstop).
  - Each replay does 10 % of the damage and effects, x the charge.
  - The replaying clone faces the opponent: a thin capsule aimed along his yaw from 1.1 m aside missed.
- **G:** two carried effects in two routes that never meet (the charge in NS2's string, the clones in NS3's) make a written x
  unreachable. Say so to the user; don't silently leave dead code.

## 5. Bug classes this grammar produced (G)
| Bug | Cause | Fix | § |
|---|---|---|---|
| NS3[2]'s cut skipped on a quick third press | the clone's swing lag 6 put its hit at f18; NS3[3] starts at f14 and retasks the clones | spawned NS clones swing at once | §443 |
| The SA after NS3[3] whiffed | the X knocked down | a stagger; only a route's last segment knocks down | §443 |
| AS3 tapped → Kikon | the hit at 8 f, before the tap lifts | the confirm after the hitstop + the undo | §441 |
| The phone's Kikon worked in the check, failed in play | the check held the attack zone; any contact counted | the SP zone only; check both zones | §442 |
| Duplicate replays, the clone cap filled | the clone's strike hazards carry its data, so they counted as clones | `clone-p` checks the hook | §438 |
| A wave could never Kikon | `apply-hit` needed a melee hit | `hazard-sp-mv` + `:kikon-strike` | §437 |
| A shared strike classed AS in an NS | one tag a move | a copy per class | §437 |
| Copies' on-frames skipped | on-frames before `:enter` | on-frames ≥ `:enter` | §431 |

## 6. Wording that was misread or nearly so (G)
| The user wrote | Could read | Meant | Settled by |
|---|---|---|---|
| 「重現本體的行為（包含 J 與 SP）」 | every move incl. the next NS | only the J / AS after NS3 (「為什麼還有下一個 NS？」) | a correction mid-question |
| 「依據目前指針指向的 NS」 | the pointer before the AS | the pointer the AS writes | §435 |
| 「把毀魂技的按住判定時間拉長」 | a grace before / after the hit | a stricter confirm after it (「打中後要多按住幾幀」) | AskUserQuestion |
| 「點擊觸發」 | fire on press everywhere | asked the conflicts first; chose press-in-moves only (「1」) | three options |
| 「SP 打中後繼續按著」 on the phone | a hold kept from the tap | a re-press, judged at the hit (「打中前按下」) | AskUserQuestion |

## 7. Process (G)
- **A system replacement** (§410–§411):
  - Start from the user's note.
  - Hold a grilling session; record a scope table with verbatim answers, and a list "defaults I chose where the note is silent".
  - Build in this order: docs → pure rules with host tests → one character → the others → input / phone / HUD → CPU → gates.
  - Retire what doesn't fit (`*retired*`) and freeze side modes (ASSIST, the learner, ENDLESS, ROGUE); keep their code.
- **Stacked special cases are still the redesign signal.** About 20 rules in 2 days on the old Lille's traces led to a rebuild. Write
  an animation inventory and a proposal from the part that works (`git show e55304e:skills/duel-move-modules/reference.md` §3).
- **Feel numbers churn; intent holds.** Expose the numbers as knobs with docstrings (old → new, date, who decided):
  - the confirm 12 f,
  - the replay lags 4 / 8,
  - the replay scale 0.1,
  - the clash slow motion 0.2 × 0.7 s.
