#!/bin/sh
# add.sh — arms5's final T0 tables replace B4's entries of the same ids in duel/lisp/strategy.lisp's *STRAT-LIBRARY* (add.py replaces in
# place; *STRAT-LOOKUP*'s rows already point at the ids). Checkpoint 2b (the user, 2026-11-15, 「先保留 B4 舊表」): KI both, KK, II.
# Checkpoint 2c (the user, 2026-11-16, 「KH、IH 換新表，HH 保留舊表」): KH both, IH both; HH keeps B4's (arms4/t0final/add.sh).
# First Hisagi's own style unit (:st-hisagi-own = hisagi-own-style; no :ken-ranged: his h5 arms carry it as their own key, h5-tip does
# not), then the arms5 arm units *STRAT-UNITS* lacks (sp/final/units.py's lines) after the last unit block, then entry.py + add.py per
# table. Run from the repo root; idempotent (each step skipped when done; an entry replaced by itself); OUT a scratch directory.
set -e
D=docs/research/strategy-drsi/sp/arms5/t0
L=docs/research/strategy-drsi/fq/switch/library
OUT=${OUT:-/tmp}
python3 - <<'EOF'
p = 'duel/lisp/strategy.lisp'
s = open(p).read()
if ':id :st-hisagi-own ' not in s:
    at = "    (:id :st-hisagi-ihr1b2a0 :fn hisagi-ihr1b2a0-style :apply (:hisagi))       ; Hisagi's IH round-1 style (§11.14; the final tables, §11.16)\n"
    assert s.count(at) == 1
    s = s.replace(at, at + "    (:id :st-hisagi-own :fn hisagi-own-style :apply (:hisagi))               ; Hisagi's own style (arms5, sp/arms5/hisagi.md; the KH / IH tables, §11.29)\n")
    open(p, 'w').write(s)
EOF
python3 docs/research/strategy-drsi/sp/final/units.py $D/t0-ki-kenpachi.lisp $D/t0-ki-ichigo.lisp $D/t0-kk-kenpachi.lisp $D/t0-ii-ichigo.lisp \
  $D/t0-kh-kenpachi.lisp $D/t0-kh-hisagi.lisp $D/t0-ih-ichigo.lisp $D/t0-ih-hisagi.lisp > $OUT/arms5-units.txt
python3 - $OUT/arms5-units.txt <<'EOF'
import sys
p = 'duel/lisp/strategy.lisp'
s, new = open(p).read(), [l.strip() for l in open(sys.argv[1]) if l.strip()]
if new:
    end = s.index('\n  "The arm units: a style + data units')
    assert s[:end].endswith(')))'), s[end - 20:end]
    block = ('\n    ;; checkpoint 2c\'s arms5 one-job arms in the KH / IH T0 tables (DUEL_AI_STRATEGY §11.29; docs/research/strategy-drsi/sp/arms5/hisagi.md;'
             '\n    ;; sp/final/units.py writes them): Hisagi all cancel wake tip bind (KH Kenpachi\'s k5-all = :c-ki-k-r2-b1a2, k5-wake above)'
             + ''.join('\n    ' + l for l in new))
    s = s[:end - 1] + block + ')' + s[end:]
    open(p, 'w').write(s)
print(f'{len(new)} units added')
EOF
while read cp t me vs; do
  python3 $L/entry.py $D/t0-$t.lisp :t0-$t > $OUT/t0-$t.entry
  python3 $L/add.py $OUT/t0-$t.entry $me $vs "PLAN4's T0, arms5 (checkpoint $cp, DUEL_AI_STRATEGY §11.29; was B4's arms4/t0final/t0-$t.lisp): one-job arms admitted in band, switched by a designed :rb-sp2 job map (arm k +q in its job rules, -q / n in the rest of its groups), :keep-state, the pairing's :with exchange unit: $D/t0-$t.lisp"
done <<EOF
2b ki-ichigo ichigo kenpachi
2b ki-kenpachi kenpachi ichigo
2b kk-kenpachi kenpachi kenpachi
2b ii-ichigo ichigo ichigo
2c kh-kenpachi kenpachi hisagi
2c kh-hisagi hisagi kenpachi
2c ih-ichigo ichigo hisagi
2c ih-hisagi hisagi ichigo
EOF
