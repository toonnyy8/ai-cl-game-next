# The baseline: Lille II's shipped CPU at the freeze (DUEL_LILLE_V3 §22)

The CPU as it stood after decisions R3–R17 (DUEL_LILLE_V3 §9–§21). Its tables were written for version 3's first rules
(R2–R3: the base stance's 4 m shots, the awakened stance EN as a free-moving form) and were only patched since:

- **Base form** (`:base` :ai): AI-DECIDE's bands; the `:zone` reflex (BR-AI-REFLEX) enters the stance (`:br-kamae`)
  inside 4 m (`:zone :in 4.0`, one roll every *BR-AI-EVERY* 30 f). In the stance BR-AI-KAMAE rolls one plan
  (BR-AI-STANCE-PLAN: `:gather` L when the pips are short, `:recover-fs` / `:recover-bars` J when flash step / Reiatsu are
  low, else K; `:step` the HIRENKYAKU when threatened). R15's patch: a J / K plan out of the opener's reach turns into L.
  It never holds L (the snipe always fires at level 1, S 16, 4 m), so from 4 m its J / K whiff or turn into level-1 shots.
- **Stance strings** (BR-S-CPU-CALL): at a string's link point one call: the L L follow-up (`:follow` chance, the
  specials permitting) or, on a hit, the charge-less SP2 (`:sp2-at` specials, `:sp2` chance).
- **JILLIEL KIN / the owl KIN**: AI-DECIDE's bands (J / K strings, `:sig` = the turn into EN, the Breaker, SP1); the burst
  into the owl (BR-AI-BURST-P: `:burst :p :wings :in`).
- **JILLIEL EN / the owl EN** (the stance FORM): AI-DECIDE's bands with :q / :f = the stance J / K strings, :sig = the dash
  (never charged: level 1), :step the fast Step. Since R12 EN is rooted and ends after 30 f standing: the bands' approach /
  walk do nothing there and the CPU often waits the stance out.
- **Learning** (BR-LEARN-*): the learner's `:shot` situation (the human's answer to the base stance's K K) changes the
  stance plan; **ASSIST** (BR-ASSIST-COMBO): AUTO COMBO's routes for a human.

Measured at the freeze (tools/aieval.py --char 6, 40 seeds): see score.json (80 seeds: score80.json). At 10 seeds before
the freeze: HARD strength 0.000 (0 / 100), masher 0.25, signature 0.274, NORMAL share 0.07 (factor 0): broken.
