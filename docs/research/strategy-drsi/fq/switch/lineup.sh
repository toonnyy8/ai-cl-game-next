#!/bin/sh
# lineup.sh — sourced with P set (`P=hi; . ./lineup.sh`) from the switch directory: the pairing P's sw.py options C (me, vs, the opponent seat = the other
# side's LIVE lookup table vs me, the arms file of P's current table), CUR (P's current live table) and
# FROZEN (the frozen style CPU used as a stand-in for a human, reported only). DUEL_AI_STRATEGY §8.19 round 5 (the user, 2026-11-09:
# 「每個對戰組合都重新擬合雙方的新表」: every fit and every swap test against the other side's live table). Override an entry with
# OPP_<P>=file / CUR_<P>=file / ARMS_<P>=file when a swap changes the lineup. The defaults are the lineup after round 5's step 1
# (Ichigo vs Hisagi :qis-hisagi; Ichigo vs Kenpachi and the Ichigo mirror kept).
F=..
case ${P:-$1} in
  hi) ME=hisagi; VS=ichigo;   OPP=${OPP_hi:-ichigo/qis-hisagi.lisp};           ARMS=${ARMS_hi:-arms/hi-d.arms};    CUR=${CUR_hi:-hi/qhs3-ichigo.lisp};          FROZEN=$F/../counter/frozen/ki-ichigo.lisp ;;
  hk) ME=hisagi; VS=kenpachi; OPP=${OPP_hk:-kenpachi/qks-hisagi.lisp};         ARMS=${ARMS_hk:-arms/hk.arms};      CUR=${CUR_hk:-arms/ship-qh-ken.lisp};        FROZEN=$F/../counter/frozen/ki-ken.lisp ;;
  hh) ME=hisagi; VS=hisagi;   OPP=${OPP_hh:-hh/qhs2-mirror.lisp};              ARMS=${ARMS_hh:-arms/hh.arms};      CUR=${CUR_hh:-hh/qhs2-mirror.lisp};          FROZEN=none ;;
  ki) ME=kenpachi; VS=ichigo; OPP=${OPP_ki:-$F/../counter/frozen/q1-ichigo-ken.lisp}; ARMS=${ARMS_ki:-kenpachi/ki.arms}; CUR=${CUR_ki:-kenpachi/qks-ichigo.lisp}; FROZEN=$F/../counter/frozen/ki-ichigo.lisp ;;
  kh) ME=kenpachi; VS=hisagi; OPP=${OPP_kh:-arms/ship-qh-ken.lisp};            ARMS=${ARMS_kh:-kenpachi/kh.arms};  CUR=${CUR_kh:-kenpachi/qks-hisagi.lisp};    FROZEN=none ;;
  kk) ME=kenpachi; VS=kenpachi; OPP=${OPP_kk:-kenpachi/qks-ken.lisp};          ARMS=${ARMS_kk:-kenpachi/kk.arms};  CUR=${CUR_kk:-kenpachi/qks-ken.lisp};       FROZEN=none ;;
  ik) ME=ichigo; VS=kenpachi; OPP=${OPP_ik:-kenpachi/qks-ichigo.lisp};         ARMS=${ARMS_ik:-ichigo/ik.arms};    CUR=${CUR_ik:-$F/../counter/frozen/q1-ichigo-ken.lisp}; FROZEN=$F/../counter/frozen/ki-ken.lisp ;;
  ih) ME=ichigo; VS=hisagi;   OPP=${OPP_ih:-hi/qhs3-ichigo.lisp};              ARMS=${ARMS_ih:-ichigo/ih.arms};    CUR=${CUR_ih:-ichigo/qis-hisagi.lisp};     FROZEN=none ;;
  ii) ME=ichigo; VS=ichigo;   OPP=${OPP_ii:-$F/pairs/ii/ii-fit.lisp};          ARMS=${ARMS_ii:-ichigo/ii.arms};    CUR=${CUR_ii:-$F/pairs/ii/ii-fit.lisp};     FROZEN=none ;;
  *) echo "lineup.sh: no pairing ${P:-$1}" >&2; exit 2 ;;
esac
C="--me $ME --vs $VS --opp $OPP --arms $ARMS"
