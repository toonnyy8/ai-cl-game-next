# Mechanic precedents for Yamamoto on the core system (research, 2026-11-19)

Scope: game-design precedents for the two mechanics of `docs/duel/DUEL_YAMA_CORE.md` (§3 heat → 爆炎, §4 three marks → 北).

Evidence grades: **B** official text / patch notes; **C** secondary (wikis, guides, reviews, forums); **D** my inference, or recall
from memory that this session's fetches did NOT confirm. Honest limit: web access here was poor (several wikis answered with a bot wall,
no patch-note page was read in full), so almost nothing below is grade B. Treat every number as "verify before quoting"; the design
patterns are the useful part. Rows marked D-recall are from memory and must be re-checked.

## Part 1. Heat → overheat (gauge by landing attacks; spend for boost; a timed powered state that drains health)

### 1.1 Bleach: Rebirth of Souls, Yamamoto (the direct ancestor)

- Rule (C): an Inferno Gauge fills from certain attacks, including his Signature Move; full gauge puts him in Hellfire State, attacks
  stronger; the Spiritual Pressure moves change (without it the follow-up is Taimatsu, in it Nadegiri). Source: Siliconera
  https://www.siliconera.com/shigekuni-genryusai-yamamoto-strikes-in-bleach-rebirth-of-souls-trailer/
- Numbers: none found (duration, drain, cost unknown). Opponent counter: none documented. Patch history: Bandai Namco's v1.40 notes
  (B, https://www.bandainamcoent.com/news/bleach-rebirth-of-souls-version-1-40-updates) as returned by search mention only Breaker hitbox
  and Reverse Gauge changes, nothing Yamamoto-specific (not read in full).
- Relevance: our design is a deliberate variation (spend-for-boost, health drain, early exit). The move-set swap (Taimatsu →
  Nadegiri) is exactly the "variant per move" idea of 爆炎.

### 1.2 Tekken 8, Heat

- Rule (C): a Heat gauge under the health bar; Heat Burst or a character Heat Engager (usable only on hit) starts Heat State: 10 s
  (Burst) or 15 s (Engager); certain moves are stronger; all attacks chip a blocker (white, recoverable health; ~30 % of damage rounded up,
  cannot KO); Heat Dash spends the rest of the gauge; Heat Smash (repeat the Burst input) is a super that ends Heat. Sources: ESTNN
  https://estnn.com/tekken-8-heat-system-explained ; esports.gg
  https://esports.gg/news/tekken-8/tekken-8-heat-system-how-it-works-and-how-to-activate-heat . Guides disagree on whether Dash spends one
  cell or all; the 10 s / 15 s figures are consistent (C).
- Counter: block and wait (Heat is timed; chip is recoverable), punish the engager's startup; the state does not cost the user health (C).
- Designer / player comment: not retrieved. (D: the community complaint I recall, that Heat plus a free engager made some characters
  oppressive, and that patches trimmed engagers and chip, is unverified; check the patch notes before citing.)
- Relevance: a fixed-length powered state whose exit is a spend-all super (Heat Smash) is the closest structure to our "NS spends
  heat to leave 爆炎". Chip that cannot kill is the same idea as our "Reishi drain never below 1".

### 1.3 Street Fighter 6, Burnout (the inverse: overspending is the penalty)

- Rule (C): Drive gauge to zero puts the player in Burnout: no Drive moves, chip damage on guard goes to health (and can kill in the
  beta writeups), longer blockstun, the gauge refills slowly; ordinary gauge building shortens it; a wall-splat Drive Impact stuns
  (stun gauge removed). Duration quoted variously ("about 20 s" beta; a 28 s figure unconfirmed). Sources: Red Bull
  https://www.redbull.com/ca-en/drive-system-street-fighter-6 (page body not read), exputer
  https://exputer.com/guides/sf6-burnout/ , gameranx
  https://gameranx.com/features/id/469390/article/street-fighter-6-how-to-deal-with-burnout-tips-tricks .
- Counter: pressure the burned-out player (the whole game plan of the opponent), corner them (C).
- Lesson (D): Burnout is readable because it is shown on the gauge and on the character (flashing, a visible meter); and the penalty
  is the state itself, not a hidden number.

### 1.4 Melty Blood (Type Lumina / classic): HEAT and Moon Drive

- Rule (C): in HEAT, red life slowly regenerates and the timer stops (Mizuumi wiki, via search summary); Moon Drive: 5B+C at 50 %+ Moon
  gauge turns the gauge into a draining timer that cannot be refilled until it ends (MBTL resources,
  https://wiki.gbl.gg/w/Melty_Blood/MBTL/Resources ). Whether Moon Drive costs life: not confirmed (the fetch of the rules page was
  blocked).
- Relevance: a powered mode where the gauge itself is the timer (our 爆炎 decays heat 10 / s, same shape). Counter: out-wait it.

### 1.5 BlazBlue, Susano'o (heat gauge + stage seals)

- Rule (C): his own Heat gauge pays for specials (50 % for Liberating Dagger, Strike of the Possessed God, Collapsing Resentment; 100 %
  for Roar of the Mad King); moves are gated by numbered stages 2-8 that he unlocks over the match, with stage 1 open at the start;
  Overdrive (A+B+C+D) allows all specials briefly. Sources: https://blazblue.wiki/wiki/Gameplay:Susano%27o_BBCF ; seal count and a
  conditional unlock (a Fatal Counter, 75 % heat, Overdrive and seals 4 and 8 unlock seal 5) from
  https://blazblue.fandom.com/wiki/Susanoo/Combo_List and the BBCF file page (C). Stage-unlock conditions beyond that: not read.
- Relevance: both mechanics in one character (gauge-spend specials + seal unlocks), but the stage system is a long-match progression
  rather than a three-mark one-shot; a warning that the rules need a page of explanation (D).

### 1.6 BlazBlue, Hakumen (time-filled stock, spent on specials)

- Rule (C): the Magatama gauge fills over time (faster on the ground), each fill is one Magatama up to 8, a match starts with 1; specials
  cost 1 / 2 / 3 / 4 / 8; the 8-cost Astral Heat is the strongest. Source: https://blazblue.wiki/wiki/Hakumen/Gameplay/BBCF .
- Counter (C, same page): deny the stock by early pressure ("Hakumen needs to restrain the opponent until his gauge fills"); punish
  his slow specials.
- Relevance: one charge unit, several priced options, and the strongest option costs the whole bar. Note that it fills with time, not
  hits, so it rewards the defender; ours rewards the attacker, which is the "winner gets stronger" risk (see lessons).

### 1.7 Guilty Gear Strive, Asuka R# (a resource whose exhaustion is a penalty state)

- Rule (C): 4 spell slots, each spell costs Mana, using one discards it and he must restock; if hit and Mana hits zero he is put in a
  special state until Mana refills. Source: https://dustloop.com/w/GGST/Asuka_R/Strategy .
- Relevance: spending a gauge below a threshold is dangerous, which is how our "spend heat to leave early" must feel (D).

### 1.8 Not verified (recall only, grade D-recall; do not quote)

- KOF MAX Mode / Hyper Drive, Granblue Rising, Under Night In-Birth (Hyde), Dragon Ball FighterZ, Persona 4 Arena: searches this
  session returned nothing usable. A "powered timed state that costs life" I remember is Guilty Gear's Testament-style or Jin-style
  risk modes, and in Strive Zato / Happy Chaos use a cost-per-use resource; none of these were checked.

## Part 2. Collect three marks → a brief strongest state

### 2.1 BlazBlue Susano'o seals (closest)

- Rule (C, as 1.5): numbered seals unlock the move list stage by stage; one seal's condition is a conjunction of events (Fatal Counter
  plus heat plus Overdrive plus two other seals). Sources as 1.5.
- Counter / patch notes: not retrieved.

### 2.2 Hakumen's Magatama (stock-to-ultimate)

- As 1.6: eight units, the 8-cost Astral Heat as the finisher; the strongest option costs the full bar. Source:
  https://blazblue.wiki/wiki/Hakumen/Gameplay/BBCF (C).

### 2.3 Others (grade D-recall, not verified here)

- Street Fighter install supers (V-Trigger / Critical Art style: a bar fills, the player chooses when), Guilty Gear Zato and Happy
  Chaos, MOBA stack-to-ultimate (e.g. a champion who needs N stacks), Sekiro / Nioh (a gauge from varied attacks). No source was
  fetched; the general pattern (a counter that fills by doing specified things, then a one-use payoff) is common, and the
  "different enders, one per type" requirement is closest to Susano'o's conditional unlocks (D).

## Lessons for SOUL DUEL

1. **A state the winner gets for free snowballs (D, from 1.2 / 1.6).** Heat fills only on landing hits (Y1), so the attacker gains it.
   Keep three brakes: the gauge starts at 0 each match and each Shikai entry, the drain keeps the user's health falling (never lethal,
   Y4), and the state has a hard end (10 s decay). If the 爆炎 set is clearly stronger than the Shikai, add a defender-side gain
   (e.g. blocking a Heat move, or a small gain on being hit) rather than only nerfing numbers.
2. **A powered state needs counterplay that is not "wait for it to end" only (C, 1.2).** Tekken's Heat is answered by blocking and
   punishing engagers; SF6's Burnout by pressure. For 爆炎, the opponent's reads should include: the early-exit NS spend (a visible
   tell), the Reishi drain meter, and keeping 爆炎 NS / AS cancel-able or punishable so free specials are not safe.
3. **Make the powered state readable at a glance (C, 1.3, 1.1).** SF6's Burnout and Hellfire are both a different look and a changed
   move set; 爆炎 should have a distinct body glow and a Reishi bar dropping with a number, and the gauge's remaining decay shown
   as a bar, not a hidden timer.
4. **Chip / drain that cannot kill is accepted (C, 1.2 chip; our Y4).** Put the floor in the UI (the bar stops at 1) so players
   trust the drain.
5. **Spend-for-boost works when the boost is proportional and the cost is visible (C, 1.5 Susano'o specials at 50 / 100 %, 1.6
   Hakumen 1-8).** Y2 / Y3's fixed 25 per segment with a proportional boost matches that; avoid hidden thresholds.
6. **For the marks: show the set, keep the condition simple, keep the payoff one use.** Susano'o's seal conditions are a long
   conjunction and read as homework (C, 1.5; D inference); ours is "three different AS", which is far simpler and should show as
   three icons beside the pointer (§4 HUD).
7. **The strongest option should cost the whole resource (C, 1.6 Astral Heat = 8 Magatama; 1.2 Heat Smash ends Heat).** 北 clearing
   all marks and ending after one move (Y7) has the same shape; keep it one move, with a loud tell, so it reads before it hits.
8. **Beware the losing side getting too strong (D).** Marks and heat both reward landing hits; if the match comes down to who gets
   North first, add a small way back (a mark lost on being hit by a Kikon, or a cancel clearing a mark) or check that cancels and
   clashes do not let the loser fill the gauge faster than the winner.

## Open verification (do before quoting any number in the design doc)

Tekken 8 patch notes (Heat / chip), SF6 patch notes (Burnout duration), Bleach RoS Yamamoto's Hellfire numbers, Susano'o stage unlock
rules, and every "D-recall" item above.
