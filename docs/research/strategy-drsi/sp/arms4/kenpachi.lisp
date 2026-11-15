;; Kenpachi's arms (PLAN4 §3, batch B3; assembled first, `rush` / `guard` to be tuned by cells). One style function, ken-kh-standoff-style
;; (the bait arm excepted, below). The common base = the 2026-11-15 arm 0 of the KI and KH tables (x-ki-k-r1-b0a2 and x-kh-k-r1-b0a2 share
;; every key but the exchange keys) without its exchange keys: they come from the pairing's :with unit (x-units/). No arm names an exchange
;; key (KNOBS.md §6.5). The job keys are KNOBS.md §6.1 / §6.2's; each arm writes the base whole with its job's keys replaced or added.
;; One plist per arm, arm 0 first, then the general arms, then the targeted ones; proof.py reads them by :id.
(:id :a4-k-all :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3))
;; rush: close in (Hoho in from 6 m on one cell, Step in, walk in until a move reaches, the Hoho-safety and the back Step off)
(:id :a4-k-rush :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 0.5 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 1.0 :kk-hoho-in-p 1.0 :kk-hin-fs 100 :kk-hoho-in-max 6.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 0 :kk-step-max 4.5 :kk-step-p 0.0 :kk-bankai-p 0.0 :kk-reach-p 1.0 :kk-ns-safe-p 0.0 :other 10.0 :kikon 0.3))
;; guard: hold and answer (the brawl read from 4 m, the dodge, the back Step to 7 m, no lunge, no Step / Hoho in, the Hoho-safety always on,
;; the stand-off breaker late)
(:id :a4-k-guard :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 1.3 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-brawl-p 1.0 :kk-read-range 4.0 :kk-dodge-p 1.0 :kk-step-in-p 0.0 :kk-hoho-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 0.0 :kso-stale 600 :kk-step-max 7.0 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 1.0 :kk-ns-safe-p 1.0 :other 10.0 :kikon 0.3))
;; spend: cells into the Burst and the Kikon (the Kikon hold x3, never tapped by the red / pointer rules; :other 10 keeps the Burst and cancel
;; chances at their cap)
(:id :a4-k-spend :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 3.0 :kk-kikon-red-p 0.0 :kk-kikon-ptr-p 0.0))
;; climb: build L to 3, the Bankai, awaken (the climb, the Bankai on, its NS route at the HARD 0.25)
(:id :a4-k-climb :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-climb-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 1.0 :kk-bk-ns-p 0.25 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3))
;; targeted, vs Hisagi: the wake-up bait (ken-kh-style: hold at 2.3 m while he is down, no meaty J1). Another :fn: its style state (a KHS) and
;; the stand-off's (a KSO) each restart the other at a switch, :keep-state or not.
(:id :a4-k-bait :fn ken-kh-style :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.0 :kk-lunge-p 1.0 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3 :khf-bait-p 1.0 :khf-bait-d 2.3))
;; targeted, vs Ichigo: the wave answer (her pointer-2 Getsuga route answered at the HARD 0.9 by *kk-wave-mix*)
(:id :a4-k-wave :fn ken-kh-standoff-style :apply (:kenpachi) :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0 :p 1.0 :kk-step-in-p 0.0 :kk-awaken-p 1.0 :kk-reach-margin 0.35 :kk-wave-p 0.9 :kk-lunge-p 1.0 :kso-stale 60 :kk-step-max 4.5 :kk-step-p 1.0 :kk-bankai-p 0.0 :kk-reach-p 0.5 :kk-ns-safe-p 0.8 :other 10.0 :kikon 0.3))
