#!/bin/sh
# lineup.sh — sourced with P set (`P=hi; . ./lineup.sh`) from the switch directory: the pairing P's sw.py options C (me, vs, the opponent seat = the other
# side's LIVE lookup table vs me, the arms file of P's current table), CUR (P's current live table) and
# FROZEN (the frozen style CPU used as a stand-in for a human, reported only). DUEL_AI_STRATEGY §8.19 round 5 (the user, 2026-11-09:
# 「每個對戰組合都重新擬合雙方的新表」: every fit and every swap test against the other side's live table). Override an entry with
# OPP_<P>=file / CUR_<P>=file / ARMS_<P>=file when a swap changes the lineup. The defaults are the lineup after round 5's step 6
# (HK :qhs-ken = corefit/hk-r1, HH :qhs4-mirror = corefit/hh-r1, KI :qks3-ichigo = joint/ki-t2, IK :q1-ichigo-ken, IH :qis-hisagi;
# step 6: KH :qks4-hisagi = khevent/kh-t2, the event layer on).
F=..
case ${P:-$1} in
  hi) ME=hisagi; VS=ichigo;   OPP=${OPP_hi:-ichigo/qis-hisagi.lisp};           ARMS=${ARMS_hi:-arms/hi-d.arms};    CUR=${CUR_hi:-hi/qhs3-ichigo.lisp};          FROZEN=$F/../counter/frozen/ki-ichigo.lisp ;;
  hk) ME=hisagi; VS=kenpachi; OPP=${OPP_hk:-khevent/kh-t2.lisp};               ARMS=${ARMS_hk:-arms/hk.arms};      CUR=${CUR_hk:-corefit/hk-r1.lisp};           FROZEN=$F/../counter/frozen/ki-ken.lisp ;;
  hh) ME=hisagi; VS=hisagi;   OPP=${OPP_hh:-corefit/hh-r1.lisp};               ARMS=${ARMS_hh:-arms/hh.arms};      CUR=${CUR_hh:-corefit/hh-r1.lisp};           FROZEN=none ;;
  ki) ME=kenpachi; VS=ichigo; OPP=${OPP_ki:-$F/../counter/frozen/q1-ichigo-ken.lisp}; ARMS=${ARMS_ki:-kenpachi/ki.arms}; CUR=${CUR_ki:-joint/ki-t2.lisp}; FROZEN=$F/../counter/frozen/ki-ichigo.lisp ;;
  kh) ME=kenpachi; VS=hisagi; OPP=${OPP_kh:-corefit/hk-r1.lisp};               ARMS=${ARMS_kh:-khevent/kh.arms};   CUR=${CUR_kh:-khevent/kh-t2.lisp};          FROZEN=none ;;
  kk) ME=kenpachi; VS=kenpachi; OPP=${OPP_kk:-kenpachi/qks-ken.lisp};          ARMS=${ARMS_kk:-kenpachi/kk.arms};  CUR=${CUR_kk:-kenpachi/qks-ken.lisp};       FROZEN=none ;;
  ik) ME=ichigo; VS=kenpachi; OPP=${OPP_ik:-joint/ki-t2.lisp};                ARMS=${ARMS_ik:-ichigo/ik.arms};    CUR=${CUR_ik:-$F/../counter/frozen/q1-ichigo-ken.lisp}; FROZEN=$F/../counter/frozen/ki-ken.lisp ;;
  ih) ME=ichigo; VS=hisagi;   OPP=${OPP_ih:-hi/qhs3-ichigo.lisp};              ARMS=${ARMS_ih:-ichigo/ih.arms};    CUR=${CUR_ih:-ichigo/qis-hisagi.lisp};     FROZEN=none ;;
  ii) ME=ichigo; VS=ichigo;   OPP=${OPP_ii:-$F/pairs/ii/ii-fit.lisp};          ARMS=${ARMS_ii:-ichigo/ii.arms};    CUR=${CUR_ii:-$F/pairs/ii/ii-fit.lisp};     FROZEN=none ;;
  *) echo "lineup.sh: no pairing ${P:-$1}" >&2; exit 2 ;;
esac
C="--me $ME --vs $VS --opp $OPP --arms $ARMS"
