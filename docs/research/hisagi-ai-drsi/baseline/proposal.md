# The shipped CPU (the baseline at the freeze; DUEL_HISAGI §20, §22.2, §22.6, §22.8, §23.1, §23.5, §24.4-§24.5, §25.3, §25.5-§25.11)

Measured at 40 seeds with the frozen evaluator (`score.json`, re-frozen 2026-10-19 on §25.5-§25.11's rules: K 2-5 m, SAHARAI
S 18 cancelled by J / K only on a hit, KOJO's yank a hit, the Shikai's J 1.7 m, the bind's Step J SENGEN, the spread
route's Reiatsu x1.3 and the gathered route's guard damage x1.3): **score 0.0** (raw 0.3848; NORMAL share 0.042, factor 0):
strength 0.000 (0 of 480 HARD matches), masher 0.107, signature 0.727 (chain 0.436, ranged 0.178, bind 0.112, plain J
0.128), pacing ok (NORMAL medians 117-173 s). (§25.6's: raw 0.3842, NORMAL 0.033; §25.4's: raw 0.3803, NORMAL 0.115.)

- **Shikai** (`:base` `:ai`): intents approach 2 / pressure 2 / zone 3 / defend 1; bands 0-2 m J (+ Breaker, SP2), 2-3 m
  little, 3-3.5 m K1, 3.5-6.2 m K1 (+ SP1), 6.2-9 m SP1 / Kikon / the windmill (charged K1 at range), 9 m+ Kikon. HS-AI-REFLEX:
  the windmill against an incoming ranged threat (RANGED-THREAT-IN), one roll a threat. HS-AI-SIG-HOLD / HS-AI-KAZA-K: K out of
  a held windmill once in the charged K1's reach. HS-AI-MOVE: the leap (J after K1 / K2) when closing (one roll, once a
  combo). HS-AI-ENDER: SP2 after RIN, SP1 after a K ender. `:l-after-j` 0.3 (the bridge).
- **Bankai ranged** (`:bankai`): bands 0-2 m L, 2-3 m K1, 3-5 m K1 / J1, 5-6 m J1, 6-8 m SP1 (§25.5); HS-R-AI-REFLEX: L
  SAHARAI once per entry inside 2.0 m; HS-R-AI-MOVE: KUBIKAKE on a confirmed J / K hit with 200 Reiatsu (HS-R-AI-THROW-P), else the damage
  pick (`*hs-ai-route-dmg-p*`); HS-R-AI-ENDER: KUBIKAKE or SP1.
- **Bind** (`:bankai-bind`): approach / pressure; HS-B-AI-REFLEX: KAIBAKU-GEKI when behind on grey within its reach (no
  plain release since §24.5), KOJO's pull; HS-B-AI-ENDER: SP only while ahead on grey.
- Every chance an (:easy :normal :hard) plist read by HS-P, rolled once per event.
