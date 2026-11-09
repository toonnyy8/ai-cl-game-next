#!/bin/sh
# round.sh R — the co-refit's round R for all nine pairings (DUEL_AI_STRATEGY §8.19 round 5, step 2; the user, 2026-11-09:
# 「每個對戰組合都重新擬合雙方的新表」), from the switch directory. Every fit sees the lineup as the round started (lineup.sh): each pairing's
# behaviour is its current table (a grouped start embedding it where the current one is a 48-rule table) + runs, against the other side's
# live table, 2 salts x seeds 1-599 x both seats; then one fit (gamma 0.98) and the current table's learnable prior put back (HI: press +0.08
# in the Shikai; IH: Kenpachi's code +0.05 in her base form) -> corefit/<p>-r<R>.lisp.
set -e
R=$1
for p in hi:hi/qhs3-ichigo.lisp hk:hk/hk2-s0-p30.lisp hh:hh/qhs2-mirror.lisp ki:kenpachi/qks-ichigo.lisp kh:kenpachi/qks-hisagi.lisp \
         kk:kenpachi/qks-ken.lisp ik:ichigo/ik-s0-p30.lisp ih:ichigo/qis-hisagi.lisp ii:ichigo/ii-s0-p30.lisp; do
  k=${p%%:*}; t=${p#*:}
  [ -f corefit/$k-r$R.lisp ] && continue
  sh run.sh $k log c$k-r$R $t "1 2"
  sh run.sh $k fit c$k-r$R corefit/$k-r$R-fit.lisp 0.98
  case $k in
    hi) sh run.sh $k pin corefit/$k-r$R-fit.lisp corefit/$k-r$R.lisp 0 0 0.08 ;;
    ih) sh run.sh $k pin corefit/$k-r$R-fit.lisp corefit/$k-r$R.lisp 0 1 0.05 ;;
    *) cp corefit/$k-r$R-fit.lisp corefit/$k-r$R.lisp ;;
  esac
done
