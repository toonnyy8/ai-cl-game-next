# b2_a0 (round 2): punish the whiff after his own dodge (Hoho / Step), not only after a knockdown

Started from round 1's b2_a0 (wake-up whiff punish, live-KH 0.19 on dev).

Job (one line): on Hisagi's first free frame after a knockdown, his own Hoho or his own Step, if Kenpachi is perceived recovering from a move
that outlasts J1's (else the pointer's NS's) startup and is in reach, hit him with that move.

Mechanism: one-line change to hkw-step: the `was` set {:air :down :wakeup} becomes {:air :down :wakeup :hoho :step}. Same roll (HARD 1.0), same
fit test, state in HKS. Rationale: the KI code's hoho-end J1, meaty J1 and Step-in J1 are dodged by Hoho / Step; the whiffed J1 then recovers
in front of him.

Measurement (dev 300): scale 0.5: start 0.271 (live 0.245) -> 0.281 (live 0.284). Scale 1: 0.2419 (live 0.193, past 0.139, arms 0.429,
standin 0.206) vs round 1's 0.2357 (live 0.188). Inside the +-0.02 noise: no measurable gain. Host tests ALL PASS.

Not a KI-code duplicate (reacts only to a seen recovery). Risks: live 0.19 << 0.2985 and total << 0.3153, so it will not pass the keep rule;
the shared CPU, not this style, chooses when Hoho / Step happen, so few new trigger frames. Untried: forcing the dodge on Kenpachi's move starts
(b2_a2 round 1: dodge timing no better than the race).
