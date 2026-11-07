;;;; sim-state.lisp — what of SOUL DUEL a snapshot saves, and a rollout (docs/duel/DUEL_AI_TEACHER.md §5; the engine's part:
;;;; engine/lisp/snapshot.lisp). Nothing in play calls these: the offline teacher and its tests do.
;;;; The roots start with what the step obviously touches; the pollution test (tools/simgate/snaptest.lisp) adds what it finds.
(in-package :duel)

;;; Shared definitions: made at load time, never written while a match runs, so a snapshot keeps them by reference.
(snapshot-shared 'clip 'move 'hitwin 'kit 'body 'weapon 'mesh 'glyph 'app 'camera 'environment 'gesture-config 'mesh-builder
                 'stream-buffer)

;;; The game's sim globals (the ECS stores and the sim RNG are the engine's).
(snapshot-roots '*match-tick* '*flow* '*timer* '*winner* '*paused*                ; flow.lisp, components.lisp
                '*pending* '*kikons* '*blow-aways*                                 ; combat.lisp
                '*slow-acc*                                                        ; main.lisp
                ;; cinema.lisp: what a cinematic's start sets in the very step that starts it (a rollout stops after that step;
                ;; *CINE-PLACED* is where CINE-END gives the actors back: the first state the pollution test found missing)
                '*cine-placed* '*cine-placed-e* '*cine-close* '*cine-time-scale* '*cine-subject* '*draw-scale-e* '*aura-off*
                '*caption* '*caption-out* '*ui-flash* '*screen-fx* '*cine-grade* '*card* '*splash-args* '*silhouette* '*impact-next*)
;;; (the engine registers its own: the ECS, hitstop, slow motion, the cinematic; snapshot.lisp)

(defun sim-snapshot-ok-p ()
  "Can the sim be snapshotted now? Only in battle and outside a cinematic (DUEL_AI_TEACHER §5)."
  (and (eq *flow* :battle) (not *cine*) (not *paused*)))

(defun sim-rollout (steps)
  "Run up to STEPS sim steps as a search's rollout: every log off, cinematics skipped (*SKIP-CINES*: one ends at once with its AFTER,
so a Kikon's Konpaku is settled and the rollout goes on), stopping when the flow leaves the battle. Returns the steps run. The caller
restores the snapshot it took before."
  (let ((*log-mute* t) (*pacing-log* nil) (*combat-log* nil) (*gate-log* nil) (*step-hook* nil) (*skip-cines* t))
    (loop for i below steps
          while (and (eq *flow* :battle) (not *cine*))
          do (sim-step)
          finally (return i))))
