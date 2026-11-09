;;; ---------------------------------------------------------------- the library's units (DUEL_AI_STRATEGY §10; the user, 2026-11-09:
;;; 「不設上限，但將相似的策略合併，或將策略解耦成更小的單位，確保策略庫的『高內聚、低耦合』」)
;;; A strategy is composed from units defined once, and *STRAT-LIBRARY* is expanded from them at load (STRAT-EXPAND): the runtime sees the
;;; same plists as before (an arm or a strategy: :FN, its keys, :BASE, :RULES ...; a Q table: :ARMS of such plists, :RULES of (ANTE Q ...)).
;;;   style  *STRAT-STYLES*     a style function and its own keys: what plays (:FN, :KEN-RANGED ...); :APPLY, whose style it is
;;;   data   *STRAT-DATA*       a data unit: :BASE outputs, :RULES, other keys (:DSWITCH-MAP); what it tunes, no code
;;;   arm    *STRAT-UNITS*      a named arm = a style + data units in order (+ its own keys): what a Q table chooses among
;;;   rules  *STRAT-RULE-BASES* a Q table's antecedents in order (+ :GROUPS): a table carries only its q per rule and arm (:Q)
;;; A library entry or an arm may name :STYLE S and :DATA (D ...): its plist is the style's keys, then its own keys, then the data's keys,
;;; :BASE the data's :BASE lists then its own appended, :RULES likewise (the order is a strategy's meaning: STRAT-VALUE averages rules in
;;; order, GETF takes a :BASE key's first occurrence). A Q table's :ARMS may name arm ids (NIL stays NIL: no strategy, the shipped CPU with
;;; its matchup style CPU) and its :RULE-BASE + :Q build :RULES; a composite's :SWITCH subs and :ELSE may name arm ids. An inline plist is
;;; kept as it is everywhere (the research files that strat-run.lisp plays raw are written inline).
(defparameter *strat-styles*
  '((:id :st-ken-ki :fn ken-ki-style :apply (:kenpachi))                       ; Kenpachi's KI style CPU (DUEL_MATCHUP_AI; against Ichigo)
    (:id :st-ichigo-ki :fn ichigo-ki-style :apply (:ichigo))                   ; Ichigo's KI style CPU (against Kenpachi)
    (:id :st-hisagi-merged :fn hisagi-merged-style :ken-ranged t :apply (:hisagi))   ; Hisagi's merged style (§8.17)
    (:id :st-hisagi-range :fn hisagi-range-style :apply (:hisagi))             ; Hisagi's ranged-mode distance control (§8.16)
    (:id :st-generic))                                                          ; no style function: the generic CPU + the MCTS
  "The style units: a style function and its own keys (DUEL_AI_STRATEGY §10).")

(defparameter *strat-data*
  '((:id :d-brawler                                    ; close pressure (s1-brawler's outputs without its priors)
     :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0
            :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05)
     :rules ((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12))
             (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1))
             (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08))
             (((:ost :active) (:dj :in)) (:b-hoho -0.05))))
    (:id :d-brawler-prior                              ; s1-brawler's strategy-layer priors
     :rules ((((:lead :behind)) (:p 1.5)) (((:lead :ahead)) (:p 0.7)) (((:or :low)) (:p 1.4))))
    (:id :d-zoner                                      ; zoning (s3-zoner's outputs without its red Kikon and priors)
     :base (:range 1.5 :ns 0.9 :hoho 1.1 :kikon 0.4 :cont 0.8 :p 1.0
            :b-walk-out 0.02 :b-wait 0.02 :b-j1 -0.08 :b-walk-in -0.04)
     :rules ((((:dn :reach)) (:b-sp 0.15 :b-walk-in -0.05))
             (((:dn :out)) (:b-sp 0.1 :b-walk-in 0.04))
             (((:dn :afar) (:wave :yes)) (:b-sp 0.18 :b-walk-in -0.04))
             (((:do :in)) (:b-walk-out 0.12 :b-step-out 0.1 :b-j1 -0.05))
             (((:dj :in)) (:b-step-out 0.08 :b-j1 0.05))))
    (:id :d-zoner-extra                                ; s3-zoner's red Kikon and priors
     :rules ((((:ored :yes)) (:kikon 1.6))
             (((:lead :ahead)) (:p 1.4)) (((:lead :behind)) (:p 0.6)) (((:mr :low)) (:p 1.3))))
    (:id :d-kite                                       ; the kite (s7-kite's outputs without its red Kikon)
     :base (:range 3.2 :ns 1.0 :hoho 1.0 :kikon 0.4 :cont 1.3 :awaken 4.0 :p 1.0
            :b-walk-out 0.05 :b-wait 0.04 :b-j1 -0.3 :b-walk-in -0.08 :b-step-in -0.05)
     :rules ((((:dn :reach)) (:b-sp 0.2 :b-walk-in -0.05))
             (((:dn :out)) (:b-sp 0.15))
             (((:dn :afar) (:wave :yes)) (:b-sp 0.22 :b-walk-in -0.06))
             (((:do :in)) (:b-walk-out 0.2 :b-step-out 0.18 :b-j1 -0.1))
             (((:do :reach)) (:b-walk-out 0.1 :b-step-out 0.08))))
    (:id :d-red-kikon                                  ; a red opponent: hold the Kikon more
     :rules ((((:ored :yes)) (:kikon 1.6))))
    (:id :d-dswitch                                    ; the DRIVE switch (§8.16): its chance and the Shikai's NS1 > NS3a map
     :base (:dswitch 1.0) :dswitch-map ((:base 1 3)))
    (:id :d-no-far-ns                                  ; no NS out of its reach (§8.16's ranged WA 0-3 m)
     :rules ((((:dn :out)) (:b-sp -0.3 :ns 0.0)) (((:dn :afar)) (:b-sp -0.3 :ns 0.0)))))
  "The data units: outputs, rules and keys without code (DUEL_AI_STRATEGY §10).")

(defparameter *strat-units*
  '((:id :a-ken-ki :style :st-ken-ki)                                         ; Kenpachi's KI style code
    (:id :a-ichigo-ki :style :st-ichigo-ki)                                   ; Ichigo's KI style code
    (:id :a-generic :style :st-generic)                                       ; the generic CPU (a strategy with nothing: no style CPU)
    (:id :a-zoner :style :st-generic :data (:d-zoner :d-zoner-extra))        ; s3-zoner (the generic CPU zoning)
    (:id :a-hisagi-merged :style :st-hisagi-merged)                           ; Hisagi's merged style
    (:id :a-hisagi-dswitch :style :st-hisagi-merged :data (:d-dswitch))       ; + the DRIVE switch
    (:id :a-hisagi-press :style :st-hisagi-merged :data (:d-brawler))         ; + close pressure
    (:id :a-hisagi-pressd :style :st-hisagi-merged :data (:d-dswitch :d-brawler))   ; + both
    (:id :a-hisagi-kite :style :st-hisagi-merged :data (:d-kite))             ; + the kite
    (:id :a-ken-press :style :st-ken-ki :data (:d-brawler))
    (:id :a-ken-kite :style :st-ken-ki :data (:d-kite))
    (:id :a-ken-zoner :style :st-ken-ki :data (:d-zoner))
    (:id :a-ichigo-press :style :st-ichigo-ki :data (:d-brawler))
    (:id :a-ichigo-kite :style :st-ichigo-ki :data (:d-kite))
    (:id :a-ichigo-zoner :style :st-ichigo-ki :data (:d-zoner)))
  "The arm units: a style + data units, each defined once; the Q tables name them (DUEL_AI_STRATEGY §10). General for their style's owner
(:APPLY from the style), and a table's comment says when it plays one against a single opponent (targeted).")
