;;;; debug.lisp — developer tools (design-v1 §15). Module._debug_cmd(N) from the page / test scripts
;;;; (arguments are encoded in the integer); the first call turns the combat log and stats lines on.
;;;; The full command table (every range, with its arguments and the probe lines it prints) is in
;;;; docs/duel/DUEL_GAMEPLAY.md "Debug commands"; claim a new range THERE before using it. In brief:
;;;;   2000-5000+s   seeded CPU vs CPU now (2000+s random pairing, 3000+ II, 4000+ IK, 5000+ KK (YY / YK until the core system, 2026-10-27))
;;;;   2100-2109     toggles: skip cinematics, turbo, hitbox / intent overlays, CPUs off, perf log, dump, (2108 a no-op), camera
;;;;   2110-2119, 2125+k, 2136+i, 30000+k   the seed gates (all pairings / one pairing / one character's), their seed offset
;;;;   2200+k, 10000+1000k+f   force cinematic k now and hold it / stills of it at frame f
;;;;   2300-2399, 2401+k, 2610+k   scenarios and probes (2300+k specials, 2320 the mash probe, 2386+k Bankai tests, 2401+k the Lisp
;;;;               menus' RESULTS); 2400 god; 2500+k human P1 vs an idle CPU (2504: vs a learning HARD Ichigo). (The retired kits'
;;;;               scenes, the frame / stance / module probes and the HUD review left with their code, 2026-11-12.)
;;;;   22000-27999, 30000-31199   knobs without a rebuild (value = k, k / 10 or k / 100 per range: see the doc), the gates' seeds
;;;;   74000-75599 Ichigo, 83000-83999 Hisagi, 84000-84099 Kenpachi, 81020+i the gates' CPU difficulty, 200000+ the pairing gate
;;;; Log lines: "duel -> STATE" (flow.lisp), "duel hash t=N ..." every 600 battle ticks (s = SP paid),
;;;; "duel -> RESULTS winner ..." (flow.lisp), CLOG combat lines "[tick] ...".
;;;; The gates' machinery (the hash line, CPU vs CPU, the seed / learning gates) is gate.lisp, their scripted players scripted.lisp.
(in-package :duel)

(defvar *hitboxes* nil)
(defvar *intents* nil)
(defvar *god* nil)
(defvar *no-draw* (make-array 4 :initial-element nil) "Debug 2120+k: skip drawing part k (perf bisection).")

(defmacro cons-per (name form &optional (n 10))
  "The consing probes' unit: run FORM N times and give \"NAME bytes\" (the string the *-cons-check lines list).
FORM sees the iteration index as I."
  `(let ((c0 (cons-bytes))) (dotimes (i ,n) ,form) (format nil "~a ~d" ,name (- (cons-bytes) c0))))

(defvar *probe* nil "A running frame probe: (kind name t0 attacker-free defender-free blocked).")

(defun webhud-consing ()
  "Debug 2515: the battle screens' model (webhud.lisp) in the running battle, 100 calls each once the values are written (so
nothing changes: the steady state of a frame): a `webhud consing` line, B (DUEL_WEBUI §7; 0 B wanted)."
  (when (and *p1* *p2* (entity-alive-p *p1*) (entity-alive-p *p2*))
    (webhud-sync)
    (log-msg "webhud consing (100 calls, B): ~a, ~a, ~a, ~a, ~a, ~a, ~a"
             (cons-per "sync" (webhud-sync) 100) (cons-per "side" (webhud-side *p1* 50) 100)
             (cons-per "prompt" (webhud-prompt *p1*) 100) (cons-per "deck" (webhud-deck) 100)
             (cons-per "tag" (webhud-tag *p1* (fighter-kit (fighter *p1*))) 100)
             (cons-per "stake" (at-stake *p1*) 100)
             (cons-per "touch" (progn (touch-button :mod) (touch-button :awaken) (touch-button :quick) (touch-button :step)) 100))))

(defun-fast lhud-flames-ab (glyph)
  "2519's flame A/B (DUEL_LISP_HUD §14): 18 soul flames at a phone plate's size, as phase 2 drew them (GLYPH nil: the polygon fill
and its round-capped stroke) or as the baked SDF glyph (two quads), in the same frame and transform."
  (let* ((u (lay-u 1f0)) (sw (* 1.05f0 u)) (s (/ sw 10f0)) (gz (* 14f0 s)) (np (floor (length *sh-flame*) 2)) (no (floor (length *sh-flame-o*) 2))
         (du (/ (aref *glyph-dscale* 0) 14f0)))
    (declare (single-float u sw s gz du) (fixnum np no))
    (paint-reset)
    (dotimes (i 18)
      (let ((bx (* (i->f i) 1.5f0 u)) (y0 (* 10f0 u)))
        (declare (single-float bx y0))
        (paint-push)
        (if glyph
            (progn (paint-pen! bx (+ y0 gz) gz) (paint-text +soul-glyph+ +f-sans+ +c-paper+)
                   (paint-pen! bx (+ y0 gz) gz :edge (- 0.5f0 (* du 0.6f0)) :outline (* du 1.2f0)) (paint-text +soul-glyph+ +f-sans+ +c-ink+))
            (progn (paint-transform! 0f0 0f0 :sx s :sy s :dx bx :dy y0)
                   (paint-clip! -1f5 -1f5 1f5 1f5) (paint-centre! 6f0 12.6f0) (paint-poly *sh-flame* np +c-paper+ +c-paper+)
                   (paint-stroke! *sh-flame-o* no 1.2f0 +c-ink+ :round t)))
        (paint-pop)))
    nil))

(defun lhud-consing ()
  "Debug 2519: the Lisp HUD's per-frame path in the running battle, 100 calls each once the state settled, with the busiest frame
forced (P1's combo mid-stamp, P1's move name and the Kikon prompt with its ring shown, a ripple, a trail and two words in the touch
ink; put back after): `lhud consing (100 calls, B): …` (plate, combo, the whole draw, 2509's shapes card) with their ms a call and
vertices; `lhud consing 1c …` (the frame's layout, 2518's rows); `lhud consing p2 …` (phase 2's elements: the systems, your plate on
the line, the deck, 爆, the stance ring, the clock tab, the touch ink, the move name, the prompt) (0 B wanted; DUEL_LISP_HUD §4.7, §13)."
  (when (and *p1* *p2* (entity-alive-p *p1*) (entity-alive-p *p2*))
    (let* ((f0 (stream-buffer-fill *hud-batch*)) (b0 (stream-buffer-fill *hud-back*)) (now (aref *ui-clock* 0))
           (kan (lhud-move-kanji "GETSUGA TENSHO"))
           (saved (mapcar #'copy-seq (list *lhud-cb-i* *lhud-cb-f* *lhud-cl-i* *lhud-cl-f* *lhud-pr-i* *lhud-pr-f* *lhud-pr-t*
                                           *lhud-fx-i* *lhud-fx-f*))))
      (lhud-frame) (lhud-systems nil)
      (setf (aref *lhud-cb-i* 4) 1 (aref *lhud-cb-i* 5) 1 (aref *lhud-cb-i* 1) 12 (aref *lhud-cb-i* 2) 345 (aref *lhud-cb-i* 3) 85
            (aref *lhud-cb-f* 0) 1.0 (aref *lhud-cb-f* 1) 1.0 (aref *lhud-cb-f* 3) 0.0 (aref *lhud-cb-f* 4) 0.0
            (aref *lhud-cb-f* 6) (- now 0.1) (aref *lhud-cb-f* 7) now
            (aref *lhud-cl-i* 1) 1 (aref *lhud-cl-f* 0) 1.0 (aref *lhud-cl-f* 1) 1.0 (aref *lhud-cl-f* 3) (- now 0.1)
            (aref *lhud-pr-i* 0) 1 (aref *lhud-pr-i* 1) 30 (aref *lhud-pr-i* 2) 1 (aref *lhud-pr-f* 0) 1.0 (aref *lhud-pr-f* 1) 1.0
            (aref *lhud-pr-t* 0) (- now 0.2) (aref *lhud-pr-t* 1) 0.5)
      (let ((x (* 0.5 (window-width))) (y (* 0.8 (window-height))))
        (lane! (f32 x) (f32 y) 0f0 0f0) (lhud-fx-add 1 0) (lhud-fx-add 4 0)
        (lane! (f32 x) (f32 (* 0.7 (window-height))) (f32 (* 0.2 (window-width))) 0.3f0) (lhud-fx-add 3 0) (lhud-fx-add 4 4))
      (labels ((one (k) (setf (stream-buffer-fill *hud-batch*) f0 (stream-buffer-fill *hud-back*) b0)
                 (case k (0 (lhud-plate 1)) (1 (lhud-combo 0)) (2 (lhud-draw)) (3 (lhud-shapes-card)) (4 (lhud-card-demo))
                   (5 (lhud-systems nil)) (6 (lhud-plate-line)) (7 (lhud-deck)) (8 (lhud-dial)) (9 (lhud-ring)) (10 (lhud-clock))
                   (11 (lhud-fx))
                   (12 (setf (svref (svref *lhud-side* 0) 6) "GETSUGA TENSHO" (svref (svref *lhud-side* 0) 7) kan)   ; (the draw's model
                       (lhud-callout 0))                                                                            ;  update resets them)
                   (13 (lhud-prompt)) (14 (lhud-intro)) (15 (lhud-ready)) (16 (lhud-finish)) (17 (lhud-pause)) (18 (lhud-dim))
                   (19 (lhud-pause-pointer)) (20 (lhud-flames-ab nil)) (t (lhud-flames-ab t))))
               (ms (k) (let ((t0 (now-ms))) (dotimes (i 100) (one k)) (/ (- (now-ms) t0) 100)))
               (vs (k) (one k) (floor (- (stream-buffer-fill *hud-batch*) f0) 16)))
        (dotimes (k 14) (one k))
        (log-msg "lhud consing (100 calls, B): ~a, ~a, ~a, ~a; ms a call: plate ~,4f, combo ~,4f, draw ~,4f, shapes ~,4f; verts: plate ~d, combo ~d, frame ~d, shapes ~d"
                 (cons-per "plate" (one 0) 100) (cons-per "combo" (one 1) 100) (cons-per "draw" (one 2) 100)
                 (cons-per "shapes" (one 3) 100) (ms 0) (ms 1) (ms 2) (ms 3) (vs 0) (vs 1) (vs 2) (vs 3))
        (log-msg "lhud consing 1c (100 calls, B): ~a, ~a; ms a call: demo ~,4f; verts: demo ~d"
                 (cons-per "frame" (lhud-frame) 100) (cons-per "demo" (one 4) 100) (ms 4) (vs 4))
        (log-msg "lhud consing p2 (100 calls, B): ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a; ms a call: systems ~,4f, line ~,4f, deck ~,4f, dial ~,4f, ring ~,4f, clock ~,4f, ink ~,4f, name ~,4f, prompt ~,4f; verts: line ~d, deck ~d, dial ~d, ring ~d, clock ~d, ink ~d, name ~d, prompt ~d"
                 (cons-per "systems" (one 5) 100) (cons-per "line" (one 6) 100) (cons-per "deck" (one 7) 100)
                 (cons-per "dial" (one 8) 100) (cons-per "ring" (one 9) 100) (cons-per "clock" (one 10) 100)
                 (cons-per "ink" (one 11) 100) (cons-per "name" (one 12) 100) (cons-per "prompt" (one 13) 100)
                 (ms 5) (ms 6) (ms 7) (ms 8) (ms 9) (ms 10) (ms 11) (ms 12) (ms 13)
                 (vs 6) (vs 7) (vs 8) (vs 9) (vs 10) (vs 11) (vs 12) (vs 13))
        ;; phases 3-4 (DUEL_LISP_HUD §14): the overlays forced on mid-animation (the card, READY, the finish, the pause with its rows,
        ;; the dimmed scene), the model and the overlays' state put back after
        (let* ((hs0 (copy-seq *hud-sent*)) (ss0 (copy-seq *hud-strs*))
               (ov (mapcar #'copy-seq (list *lhud-ov-t* *lhud-ov-i* *lhud-pz-tr* *lhud-lay-tr*))) (items (pause-items)))
          (setf (aref *hud-sent* 0) (logior (aref *hud-sent* 0) 4 32) (aref *hud-sent* 14) 1 (aref *hud-sent* 15) 1
                (aref *hud-sent* 16) 0 (aref *hud-sent* 17) 1 (aref *hud-sent* 18) (min 20 (length items))
                (aref *hud-sent* 19) (logand 1023 (1+ (aref *hud-sent* 19))))
          (loop for it in items for i from 10 below 30 do (setf (svref *hud-strs* i) it))
          (lhud-systems nil)
          (dotimes (i 7) (setf (aref *lhud-ov-t* i) (f32 (- now 0.6))))
          (setf (aref *lhud-ov-t* 2) (f32 (- now 0.1)) (aref *lhud-ov-t* 4) (f32 (- now 0.2)))
          (dotimes (k 6) (one (+ 14 k)))
          (log-msg "lhud consing p34 (100 calls, B): ~a, ~a, ~a, ~a, ~a, ~a, ~a; ms a call: clock ~,4f, intro ~,4f, ready ~,4f, finish ~,4f, pause ~,4f, dim ~,4f, pointer ~,4f; verts: clock ~d, intro ~d, ready ~d, finish ~d, pause ~d, dim ~d"
                   (cons-per "clock" (one 10) 100) (cons-per "intro" (one 14) 100) (cons-per "ready" (one 15) 100)
                   (cons-per "finish" (one 16) 100) (cons-per "pause" (one 17) 100) (cons-per "dim" (one 18) 100)
                   (cons-per "pointer" (one 19) 100)
                   (ms 10) (ms 14) (ms 15) (ms 16) (ms 17) (ms 18) (ms 19) (vs 10) (vs 14) (vs 15) (vs 16) (vs 17) (vs 18))
          (log-msg "lhud flames (18, 100 calls): polygon + stroke ~,4f ms ~d verts, glyph ~,4f ms ~d verts; consing ~a"
                   (ms 20) (vs 20) (ms 21) (vs 21) (cons-per "glyph" (one 21) 100))
          (replace *hud-sent* hs0) (replace *hud-strs* ss0)
          (loop for v in (list *lhud-ov-t* *lhud-ov-i* *lhud-pz-tr* *lhud-lay-tr*) for o in ov do (replace v o))))
      (setf (stream-buffer-fill *hud-back*) b0 (stream-buffer-fill *hud-batch*) f0)
      (loop for v in (list *lhud-cb-i* *lhud-cb-f* *lhud-cl-i* *lhud-cl-f* *lhud-pr-i* *lhud-pr-f* *lhud-pr-t* *lhud-fx-i* *lhud-fx-f*)
            for o in saved do (replace v o)))))

(defun lm-consing ()
  "Debug 2519's menus line (DUEL_LISP_HUD §15): 100 calls each of the Lisp menus' systems, every screen's view (whatever the model
holds now), SELECT's back layer, the rails, the wash, the cut half-way and the pointer, each warmed first (the screens share the layout lanes and the line-break cache, so the first call after another
screen re-lays its paragraphs out): `lmenu consing (100 calls,
B): …; ms a call: …; verts: …` (0 B wanted)."
  (let ((f0 (stream-buffer-fill *hud-batch*)) (b0 (stream-buffer-fill *hud-back*)) (cut (aref *lm-t* 0)) (tr *render-transparent*))
    (lhud-frame)
    (setf (aref *lm-t* 0) (- (aref *ui-clock* 0) 0.15))
    (labels ((one (k) (setf (stream-buffer-fill *hud-batch*) f0 (stream-buffer-fill *hud-back*) b0)
               (case k (0 (lm-systems (uv 0))) (1 (lm-title)) (2 (lm-mode)) (3 (lm-settings)) (4 (lm-controls)) (5 (lm-select))
                 (6 (lm-select-back)) (7 (lm-results)) (8 (lm-rails (max 1 (uv 0)))) (9 (lm-wash)) (10 (lm-cut)) (t (lm-pointer))))
             (ms (k) (let ((t0 (now-ms))) (dotimes (i 100) (one k)) (/ (- (now-ms) t0) 100)))
             (vs (k) (one k) (floor (- (if (= k 6) (stream-buffer-fill *hud-back*) (stream-buffer-fill *hud-batch*)) (if (= k 6) b0 f0)) 16))
             (cp (nm k) (one k) (cons-per nm (one k) 100)))   ; (each view warmed first: the screens share the layout lanes and the line-break cache)
      (dotimes (k 12) (one k))
      (log-msg "lmenu consing (100 calls, B): ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a, ~a; ms a call: systems ~,4f, title ~,4f, mode ~,4f, settings ~,4f, controls ~,4f, select ~,4f, back ~,4f, results ~,4f, rails ~,4f, wash ~,4f, cut ~,4f; verts: title ~d, mode ~d, settings ~d, controls ~d, select ~d, back ~d, results ~d, rails ~d, wash ~d, cut ~d"
               (cp "systems" 0) (cp "title" 1) (cp "mode" 2) (cp "settings" 3)
               (cp "controls" 4) (cp "select" 5) (cp "back" 6) (cp "results" 7)
               (cp "rails" 8) (cp "wash" 9) (cp "cut" 10) (cp "pointer" 11)
               (ms 0) (ms 1) (ms 2) (ms 3) (ms 4) (ms 5) (ms 6) (ms 7) (ms 8) (ms 9) (ms 10)
               (vs 1) (vs 2) (vs 3) (vs 4) (vs 5) (vs 6) (vs 7) (vs 8) (vs 9) (vs 10)))
    (setf (stream-buffer-fill *hud-batch*) f0 (stream-buffer-fill *hud-back*) b0 (aref *lm-t* 0) cut *render-transparent* tr)))

(defun lm-results-scene (w)
  "2401+k: a K.O. now into RESULTS for the Lisp menus' review (DUEL_LISP_HUD §15): human Ichigo (P1) vs Kenpachi (P2), VS CPU, some
numbers on the results (P1: Konpaku 6, best combo 12, 2 Kikons, 3 perfect Hohos; P2: 4, 7, 1, 0), then k: 0 P1 wins, 1 P2 wins, 2 a
draw; the K.O. cinematic plays (skip it with a key) and RESULTS follows. k 3: SELECT with P1 Hisagi and P2 Ichigo (VS CPU), each
card focused without cycling the picks."
  (when (= w 3) (setf *picks* (list :hisagi :ichigo) *mode* :vs-cpu) (go-select) (return-from lm-results-scene))
  (setf *cine-hold* nil)
  (ensure-battle :ichigo :kenpachi)
  (place *p1* *p2* 3.0)
  (loop for e in (list *p1* *p2*) for (kon best kik per) in '((6 12 2 3) (4 7 1 0))
        do (let ((g (gauges e))) (setf (gauges-konpaku g) kon (gauges-best-combo g) best (gauges-kikons g) kik (gauges-perfects g) per)))
  (match-over (case w (0 *p1*) (1 *p2*) (t nil))))

(defun set-probe (kind name &optional a b c)
  "Start a frame probe now: *PROBE* = (KIND NAME this tick A B C)."
  (setf *probe* (list kind name *match-tick* a b c)))

(defun full-gauges! (e &optional meter)
  "A scenario's preamble for fighter E: cooldowns cleared, flash-step / guard gauge full, not guardless,
Reishi at its cap; with METER also the kit meter set to it and its idle timer cleared."
  (let ((g (gauges e)))
    (fill (fighter-cd (fighter e)) 0)
    (setf (gauges-fs g) *fs-max* (gauges-gg g) *gg-max* (gauges-guardless g) nil
          (gauges-reishi g) (gauges-reishi-max g))
    (when meter (setf (gauges-meter g) meter (gauges-meter-idle g) 0))))


(defun probe-mash ()
  "Burst test (2320): human P1 Ichigo at 2 m from Kenpachi, whose (switched off) CPU mashes Quick (PROBE-UPDATE). (P1 was
Yamamoto until his code left main, 2026-11-12.)"
  (ensure-battle :ichigo :kenpachi)
  (place *p1* *p2* 2.0)
  (set-probe :mash :quick))

(defun force-burst ()
  "P1 Ichigo (Yamamoto until 2026-11-12), 2 hits into Kenpachi's string, bursts out now."
  (ensure-battle :ichigo :kenpachi)
  (place *p1* *p2* 2.0)
  (start-move *p2* (kit-move (kit-of *p2*) :ke-j2))
  (setf (fighter-sf (fighter *p2*)) 9)
  (set-reaction *p1* :flinch 18 (aref (pos-of *p2*) 0) (aref (pos-of *p2*) 2) 0.0)
  (setf (fighter-combo-hits (fighter *p1*)) 2)
  (burst! *p1* :blue))

(defun burst-burn-test (k)
  "2610+k: the burst's burning budget (docs/duel/DUEL_DESIGN.md \"BLUE burns one cell\"): human P1 3.5 m from an idle Kenpachi bursts at once,
k 0 BLUE with the flash-step full (300), 1 BLUE from 230, 2 WHITE from 300 (drains to 0). The `BURST` / `BURST END` log lines carry the gauge. (P1 was Yamamoto until his code left main, 2026-11-12: any kit has the gauge.)"
  (ensure-battle :ichigo :kenpachi)
  (place *p1* *p2* 3.5)
  (setf (gauges-fs (gauges *p1*)) (if (= k 1) 230f0 *fs-max*) (gauges-burst (gauges *p1*)) nil)
  (burst! *p1* (if (= k 2) :white :blue)))

(defun lhud-scene (practice &key intro (picks '(:ichigo :kenpachi)))
  "2505 / 2506: the handheld battle screen's scene (DUEL_LISP_HUD §13): human Ichigo (P1) vs Kenpachi with his CPU off, one-handed
where it is in effect (run with --mobile), cinematics skipped; VS CPU (the clock) or PRACTICE (the ∞ tab). 2495 / 2496 (§14): INTRO
plays the intro (the card, READY / 斬); PICKS other fighters."
  (setf *picks* picks *mode* (if practice :practice :vs-cpu) *match-seed* 1 *probe* nil
        *one-hand* (one-hand-effective-p))
  (let ((*skip-cines* (not intro))) (start-match))
  (setf (brain-off (brain *p2*)) t)
  (when (brain *p1*) (setf (brain-off (brain *p1*)) t)))

(defun practice-cancel-scene (c)
  "PRACTICE's GUARD ALL with a :core dummy (DUEL_CORE §9): 2800 + 3a + b (a / b 0-2: Kenpachi, Ichigo, Hisagi) a PRACTICE with human P1 a
against dummy b set to GUARD ALL, cinematics skipped; 2809 both 2.2 m apart, idle (a fresh scene in the same match); 2810+k
(k 0-3) the DUMMY option STAND / GUARD ALL / GUARD AFTER HIT / CPU now; 2814 both 6 m apart, idle; 2815 COUNTER J1 / OFF toggled. Every one
but 2814 / 2815 ends 2.2 m apart, idle."
  (cond ((<= c 2808)
         (let ((cs '(:kenpachi :ichigo :hisagi)))
           (setf *picks* (list (nth (floor (- c 2800) 3) cs) (nth (mod (- c 2800) 3) cs)) *mode* :practice *match-seed* 1 *probe* nil
                 *dummy* :guard-all))
         (let ((*skip-cines* t)) (start-match))
         (when (brain *p1*) (setf (brain-off (brain *p1*)) t)))
        ((<= 2810 c 2813) (setf *dummy* (car (nth (- c 2810) *dummies*))))
        ((= c 2815) (setf *dummy-counter* (not *dummy-counter*))))
  (practice-dummy!)
  (unless (= c 2815) (place *p1* *p2* (if (= c 2814) 6.0 2.2)))
  (log-msg "duel practice scene ~a vs ~a DUMMY ~a COUNTER ~a" (fighter-character (fighter *p1*)) (fighter-character (fighter *p2*))
           (cdr (assoc *dummy* *dummies*)) (if *dummy-counter* "J1" "OFF")))

(defun lhud-p2-form ()
  "2508: P2 (Kenpachi in 2505 / 2506) to his next form: sealed -> the Shikai with KAIHO L2 -> the Bankai KYORAN -> ZANKAI -> sealed
(DUEL_LISP_HUD §13: the top plate's form seals 旋 墜 / 狂 / 壞, the form tag, the KAIHO strip)."
  (let* ((forms '(:base :nozarashi :bankai :bankai-2)) (f (fighter-form (fighter *p2*)))
         (next (or (second (member f forms)) :base)))
    (force-form *p2* next)
    (when (eq next :nozarashi) (setf (gauges-meter (gauges *p2*)) 2f0 (gauges-meter-idle (gauges *p2*)) 0))))

(defun lhud-review (k)
  "2440+k: the handheld screen's states for the Lisp HUD's review stills (DUEL_LISP_HUD §13), on the running battle (2505 / 2506):
both fighters 2.2 m apart (a J reaches), idle, full gauges, Konpaku 9 with 2 at stake (the user's screenshot), then by K: 0 that; 1 / 2 both SP
pointers 2 / 3; 3 Reishi 15 % (red) and P1's Konpaku 6; 4 the flash step empty (the Burst spent); 5 the flash step at half (a Hoho,
no Burst); 6 the awakening ready; 7 P1 awakened in KESSA with SPIRIT DRIVE 60; 8 SUBLIMATION 60 over a full awakening; 9 the clock
at 9 s (VS CPU)."
  (setf *probe* nil)
  (place *p1* *p2* 2.2)
  (do-sides (e)
    (let ((g (gauges e)) (f (fighter e)))
      (full-gauges! e)
      (setf (fighter-ptr f) (case k (1 2) (2 3) (t 1)) (gauges-awaken g) 0f0 (gauges-sub g) 0f0 (gauges-awakened g) nil
            (gauges-drive g) 0f0)
      (case k
        (3 (setf (gauges-reishi g) (round (* 0.15 (gauges-reishi-max g)))))
        (4 (setf (gauges-fs g) 0f0))
        (5 (setf (gauges-fs g) (* 0.5 *fs-max*)))
        ((6 8) (setf (gauges-awaken g) *awaken-max*) (when (= k 8) (setf (gauges-sub g) 60f0))))))
  (case k
    (3 (setf (gauges-konpaku (gauges *p1*)) 6))
    (7 (force-form *p1* :kessa)
       (setf (gauges-awakened (gauges *p1*)) t (gauges-drive (gauges *p1*)) 60f0))
    (9 (setf *timer* (* 9 60)))))

(defun probe-update ()
  "Per step: the mash test's presses (2320: J down every other step; the switched-off brain still writes its held button).
(The block / trade / wall / ward / ranged / parry / drink / cut / Rukia / pressure / guard-after probes left with the retired
kits' scenes, 2026-11-12, REFACTOR_2026-11 R3.)"
  (when *probe*
    (destructuring-bind (kind name t0 &rest more) *probe*
      (declare (ignore name more))
      (let ((dt (- *match-tick* t0)))
        (case kind
          (:mash (let ((b (brain *p2*)))
                   (setf (brain-press b) :quick (brain-press-mod b) nil (brain-press-left b) (if (evenp dt) 1 0))
                   (when (> dt 60) (setf (brain-press-left b) 0 *probe* nil)))))))))

(defun brush-cons-check ()
  "2329: bytes consed by 100 draws of each brush caption layout (drawn past their stamp: the steady state), of the
screen punctuation with an impact splash and of a brush Latin line (callouts, big words)."
  (let* ((w (window-width)) (h (window-height))
         (cine (make-bcap "天地灰尽" :kanji2 "残火の太刀" :mark "北" :reading "TENCHI KAIJIN" :sub "KITA" :hanko t))
         (card (make-bcap "卍解" :reading "BANKAI" :ink t))
         (call (make-bcap "火火十万億死大葬陣" :mark "南" :reading "MINAMI" :layout :callout :side 1 :secs 100.0))
         (res (make-bcap "勝" :layout :results)))
    (dolist (c (list cine card call res)) (setf (aref (bcap-f c) 0) (f32 (- (fx-clock) 1.0))))
    (dotimes (i 2) (dolist (c (list cine card call res)) (draw-bcap c w h)))   ; the splash arguments boxed once
    (impact-splash 0.0 0.0 0.0 60)
    (log-msg "brush consing (100 draws, B): ~{~a~^, ~}"
             (list (cons-per "cine" (draw-bcap cine w h) 100) (cons-per "card" (draw-bcap card w h) 100) (cons-per "callout" (draw-bcap call w h) 100)
                   (cons-per "results" (draw-bcap res w h) 100) (cons-per "splash" (draw-screen-fx w h) 100)
                   (progn (set-line 300 300 40 '(1 1 1 1)) (setf (aref *bl* 7) (line-width "GUARD BREAK"))
                          (cons-per "line" (brush-line "GUARD BREAK") 100))
                   (cons-per "roll" (%roll-up (camera-up *camera*) *cam-eye* *cam-at* 8f0) 100)))
    (v3-set! (camera-up *camera*) 0f0 1f0 0f0)
    (setf (aref *screen-fx* 7) 0f0)))

(defun hud-cons-check ()
  "2328: bytes consed by 10 draws of each Bankai stance look (0 B each; the crossfade only while it runs). (The canvas battle HUD's
gauge bars it measured left with that HUD, 2026-11-11, DUEL_LISP_HUD §16; HUD-TEXT's line with the frozen modes' screens,
2026-11-13, REFACTOR_2026-11 R4.)"
  ;; the Bankai stances' per-frame looks (10 draws each; particles emitted too): West's flame garb, the bound ash,
  ;; the heat sheet, KYOKKO's ray, South's crack, the aura crossfade (DRAW-AURA); and the Phase-3 :heat aura for
  ;; comparison
  (log-msg "vfx consing (10 draws, B): ~{~a~^, ~}"
           (list (cons-per "garb" (vfx-aura 0f0 0f0 0f0 1.8f0 :garb 1f0 0.016f0))
                 (cons-per "bound" (vfx-aura 0f0 0f0 0f0 1.8f0 :bound 1f0 0.016f0))
                 (cons-per "nomihose" (vfx-aura 0f0 0f0 0f0 2f0 :nomihose 1f0 0.016f0))
                 (cons-per "oni" (vfx-aura 0f0 0f0 0f0 2f0 :oni 1f0 0.016f0))                 ; Kenpachi's Bankai pillar
                 (cons-per "oni smoulder" (vfx-aura 0f0 0f0 0f0 2f0 :oni 1f0 0.016f0 :k 0.15f0))
                 (cons-per "rift" (vfx-rift 1f0 0f0 4.4f0 0f0 nil))
                 (cons-per "ya hem pose" (%ya-hem-pose (model-joints (model *p1*)) *ya-hem* 0 1))   ; Yamamoto's looks
                 (cons-per "ya hem step" (%ya-hem-step *ya-hem* 0 0.016f0))                         ; (DUEL_YAMA_TYBW §3.1)
                 (cons-per "heat(old)" (vfx-aura 0f0 0f0 0f0 1.8f0 :heat 1f0 0.016f0))
                 (cons-per "kyoku" (vfx-line-cut 0f0 0f0 0f0 -9f0 0.2f0 0.67f0 :kyoku :dt 0.016f0))
                 (cons-per "kyokko" (vfx-line-cut 0f0 0f0 0f0 -4.6f0 0.1f0 0.23f0 :kyokko :dt 0.016f0))
                 (cons-per "south" (vfx-line-cut 0f0 0f0 0f0 -1.2f0 0.1f0 0.93f0 :south :dt 0.016f0))
                 (cons-per "enjo(old)" (vfx-line-cut 0f0 0f0 0f0 -9f0 0.2f0 0.67f0 :enjo :dt 0.016f0))
                 (let ((f (fighter *p1*)))
                   (format nil "~a, ~a" (cons-per "aura crossfading" (draw-aura f (if (evenp i) :garb :heat) 0f0 0f0 0f0 1.8f0 1f0 0.016f0 1.0))
                           (progn (setf (aref *aura-t* (fighter-side f)) (f32 (- (fx-clock) 5.0)))   ; settled
                                  (cons-per "aura settled" (draw-aura f :heat 0f0 0f0 0f0 1.8f0 1f0 0.016f0 1.0))))))))

(defun god-update ()
  (when *god*
    (dolist (e (list *p1* *p2*))
      (when (entity-alive-p e) (setf (gauges-reishi (gauges e)) (max (gauges-reishi (gauges e)) 400))))))

;;; ---------------------------------------------------------------- scenario helpers
(defun ensure-battle (c1 c2 &key cpu)
  "A battle with P1 = C1, P2 = C2 (CPUs when CPU), cinematics skipped into the fight."
  (unless (and (eq *flow* :battle) (eq (fighter-character (fighter *p1*)) c1) (eq (fighter-character (fighter *p2*)) c2))
    (setf *picks* (list c1 c2) *mode* (if cpu :cpu-cpu :vs-cpu))
    (let ((*skip-cines* t)) (start-match))
    (setf (brain-off (brain *p2*)) (not cpu))
    (when (brain *p1*) (setf (brain-off (brain *p1*)) (not cpu)))))

(defun place (a b dist)
  "A and B DIST metres apart on the x axis around the centre, facing, idle; no hazards, no particles."
  (clear-hazards) (fx-clear) (time-reset) (setf *punch-t* 0.0)
  (dolist (e (list a b)) (setf (model-flash (model e)) 0f0 (model-super (model e)) 0f0))
  (v3-set! (pos-of a) (f32 (* -0.5 dist)) 0f0 0f0) (v3-set! (pos-of b) (f32 (* 0.5 dist)) 0f0 0f0)
  (face-each-other a b)
  (dolist (e (list a b)) (to-idle e 0) (setf (fighter-lock (fighter e)) 0)))

(defun force-cmd (e cmd)
  "Start kit command CMD on E now, whatever the gauges say."
  (let ((f (fighter e))) (to-idle e 0) (try-command e f cmd (getf '(:sp1 :flash :sp2 :sig :sig :sig :breaker :breaker) cmd))))

(defun string-test (k)
  "2394+k: human P1 in form K (Ichigo's Shikai, KESSA, Kenpachi base, his Shikai) 2.2 m from an idle Kenpachi. (0 / 1 were
Yamamoto's Shikai and Bankai East until his code left main, 2026-11-12.)"
  (destructuring-bind (c form) (nth k '((:ichigo :base) (:ichigo :kessa) (:kenpachi :base) (:kenpachi :nozarashi)))
    (ensure-battle c :kenpachi)
    (unless (eq (fighter-form (fighter *p1*)) form) (force-form *p1* form))
    (place *p1* *p2* 2.2)))

(defun scale-k-links (pct)
  "Debug 26000+k: every K link entered mid-wind-up (a :flash move with :enter: K2, K3 and their copies) of every kit
deals PCT % of its written damage (the seed gate's first lever, DUEL_STRINGS §6, without a rebuild)."
  (maphash (lambda (c forms)
             (declare (ignore c))
             (loop for (nil . kit) in forms
                   do (maphash (lambda (n m)
                                 (declare (ignore n))
                                 (when (and (eq (mv-kind m) :flash) (plusp (mv-enter m)))
                                   (loop for w across (mv-hits m) do (setf (hw-dmg w) (round (* (mv-dmg m) pct) 100)))))
                               (kit-moves kit))))
           *kits*))

(defun force-form (e form)
  (set-form e form)
  (when (kit-awakening (kit-of e)) (setf (gauges-awakened (gauges e)) t)))

(defun force-cine (k)
  "Debug 2200+K: cinematic K of *CINE-NAMES* now, held (Kenpachi's, the generic ones; Ichigo the partner, Yamamoto until his
code left main, 2026-11-12, with his and Rukia's cinematics 0 2 3 11-15)."
  (setf *cine-hold* nil)
  (case k
    (1 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 5.0) (force-form *p1* :nozarashi)
       (start-cine 'ken-nozarashi-cine *p1* *p2*))
    (6 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 3.0) (start-cine 'soul-break-cine *p1* *p2*))
    (7 (start-match))
    (8 (ensure-battle :ichigo :kenpachi) (place *p1* *p2* 3.0) (start-cine 'ko-cine *p1* *p2*))
    (9 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 5.0) (force-form *p1* :bankai)
     (start-cine 'ken-bankai-cine *p1* *p2*)))
  (setf *cine-hold* t)
  (when *cine* (setf (cine-hold *cine*) (cine-hold-frame (cine-name *cine*)))))

(defparameter *cine-names* '(nil ken-nozarashi-cine nil nil nil
                               nil soul-break-cine intro-cine ko-cine ken-bankai-cine)
  "FORCE-CINE's numbering (the NILs: Yamamoto's 0 2 3, Kenpachi's old Kikon cinematics 4 5 10 (removed 2026-11-05, DUEL_KEN_V3
§43) and the retired kits' 11-19 (left 2026-11-12); the numbers kept).")

(defun cine-at (k f)
  "Debug 10000 + 1000 K + F (stills): cinematic K held at frame F (MAIN.LISP CINE-HELD-P freezes the effects there);
when K already runs, it continues to F."
  (unless (and *cine* (eq (cine-name *cine*) (nth k *cine-names*)))
    (abort-cine)                                         ; another one held: its looks (card, grade) end first
    (force-cine k))
  (when *cine* (setf *cine-hold* t (cine-hold *cine*) f)))

(defun force-special (k)
  "Debug 2300+K: a scenario now (Kenpachi's commands and looks, 11 the awakening gauges full, 14 P2 at 200 Reishi). Yamamoto's
scenes (0-4 12 62-64 66) left with his code, 2026-11-12; Ichigo takes his place as the partner since (7 his Hoho)."
  (setf *cine-hold* nil)
  (case k
    (5 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 7.0) (force-form *p1* :nozarashi) (force-cmd *p1* :sp1))
    (6 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 3.5)
       (setf (fighter-state (fighter *p2*)) :guard (fighter-guard-t (fighter *p2*)) 30)
       (setf (brain-press (brain *p2*)) :guard (brain-press-left (brain *p2*)) 120)   ; off: held
       (force-cmd *p1* :breaker))
    (7 (ensure-battle :ichigo :kenpachi) (place *p1* *p2* 2.4) (force-cmd *p2* :f)   ; a Hoho out of Kenpachi's K
       (let ((f (fighter *p1*))) (setf (fighter-sf (fighter *p2*)) 9) (start-hoho *p1* f)))
    (8 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 4.0) (force-cmd *p1* :sig))
    (9 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 5.0) (force-cmd *p1* :sp1))
    (10 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 5.0) (force-cmd *p1* :sp2))
    (11 (dolist (e (list *p1* *p2*)) (setf (gauges-awaken (gauges e)) *awaken-max*)))
    (13 (ensure-battle :kenpachi :ichigo) (force-form *p1* :nozarashi))
    (14 (setf (gauges-reishi (gauges *p2*)) 200))
    (65 (ensure-battle :kenpachi :ichigo) (place *p1* *p2* 4.0) (force-form *p1* :nozarashi)   ; (cup 3's pillar until 2026-11-03)
        (emit :rung *p1* t))))

(defun vfx6-cons-check ()
  "2391: bytes consed by 10 draws of each Phase 6 per-frame look (docs/style/STYLE_STORM_DESIGN.md §14 Phase 6): the marks and
chips (both pools full), a pillar beside the lens, the fire wave passing it, the skull, the rain, both face accents, the
left-hand grip (its step and the IK), and a caption slicing out."
  (let* ((e *p1*) (m (model e)) (cap (make-bcap "卍解" :kanji2 "残火の太刀" :reading "BANKAI" :layout :cine))
         (eye (camera-eye *camera*)) (px (f32 (+ (aref eye 0) 0.8))) (wx (f32 (+ (aref eye 0) 1.0))) (ez (aref eye 2)))
    (dotimes (i 20) (stage-mark (if (evenp i) :scorch :crack) (- (* 0.5 i) 5.0) 2.0 1.0))
    (stage-debris 0.0 0.0 24)
    (bcap-exit cap) (setf (aref (bcap-f cap) 7) (- (fx-clock) 0.1))
    (face-accent m :shout)                                  ; (a face change stamps the time once: not per frame)
    (log-msg "vfx6 consing (10 draws, B): ~{~a~^, ~}"
             (list (cons-per "marks" (st-draw-marks))
                   (cons-per "chips" (st-chips 0.016f0))
                   (cons-per "skull" (vfx-skull 0f0 3f0 0f0 0.98f0))
                   (cons-per "rain" (vfx-rain 0f0 0f0 0.5f0 0.9f0))
                   (cons-per "shout" (vfx-face-accent (model-joints m) 1 100))
                   (cons-per "hurt" (vfx-face-accent (model-joints m) 2 100))
                   (cons-per "face-accent" (face-accent m :shout))
                   (cons-per "grip" (grip-step m t 0.016f0))
                   (cons-per "caption-exit" (draw-bcap cap 1280 720))))
    (stage-clear-marks) (setf (aref (model-looks m) 0) 0f0)))

(defun vfx5-cons-check ()
  "2390: bytes consed by 10 draws of each Phase 5 per-frame look (docs/style/STYLE_STORM_DESIGN.md §14 Phase 5): the fire looks,
the auras redrawn in toon, the rift, a spent wave's erosion, the new stamps (all live at once), and the face / beat /
move-beat choices of DRAW-FIGHTER."
  (let* ((e *p1*) (f (fighter e)) (m (model e)) (mv (fighter-move f)))
    (dolist (k '(:ring :gash)) (stamp k 1.0 1.0 0.0 :dx 1.0 :dz 0.0 :scale 2.0 :n 0.7))
    (setf (model-beat m) 0.5)
    (log-msg "vfx5 consing (10 draws, B): ~{~a~^, ~}"
             (list (cons-per "charge" (vfx-charge 0f0 1.2f0 0f0 0.6f0 0.016f0))
                   (cons-per "hellfire" (vfx-aura 0f0 0f0 0f0 1.8f0 :hellfire 1f0 0.016f0))
                   (cons-per "evolution" (vfx-aura 0f0 0f0 0f0 1.8f0 :evolution 1f0 0.016f0 :k 0.5f0))
                   (cons-per "breaker" (vfx-aura 0f0 0f0 0f0 1.8f0 :breaker-fire 1f0 0.016f0 :k 1.5f0))
                   (cons-per "breaker-ring" (vfx-breaker-ring 0f0 0f0 0.3f0))
                   (cons-per "garb-flare" (vfx-aura 0f0 0f0 0f0 1.8f0 :garb 1f0 0.016f0 :k 1.9f0))
                   (cons-per "rift" (vfx-rift 1f0 0f0 4.4f0 0f0 nil))
                   (cons-per "stamps" (stamps-draw 0f0))
                   (cons-per "face" (face-of e f m mv))
                   (cons-per "beat-pose" (beat-pose! (anim-pose (model-anim m)) 0.5f0))
                   (cons-per "move-beats" (move-beats e f m mv 0f0 0f0 0f0 0f0))))
    (setf (model-beat m) 0f0)))


(defun cine-still-command-p (c)
  "The cinematic-still commands (FORCE-CINE / CINE-AT): a held cinematic stays held for them (tests/debug-ranges-check.py
checks every such clause of DEBUG-COMMAND is listed here)."
  (or (<= 2200 c 2299) (<= 10000 c 19999) (<= 35000 c 35999)))

(defun debug-command (c)
  "Module._debug_cmd(C): see the file header."
  (setf *combat-log* t *stats-log* t *learn-debug-off* t)   ; (no CPU learns in a debug run: fq-online.lisp FQ-ATTACH!)
  (log-msg "debug cmd ~d" c)
  (unless (cine-still-command-p c)
    (setf *cine-hold* nil))
  (cond ((<= 2000 c 2099) (start-cvc (- c 2000) nil))
        ((<= 200000 c 209999) (start-pair-gate (mod (floor c 100) 10) (mod (floor c 10) 10)))   ; (roster c1 / c2 0-9; h, m: no more read)
        ((<= 3000 c 3999) (start-cvc (- c 3000) '(:ichigo :ichigo)))
        ((<= 4000 c 4999) (start-cvc (- c 4000) '(:ichigo :kenpachi)))
        ((<= 5000 c 5999) (start-cvc (- c 5000) '(:kenpachi :kenpachi)))
        ((<= 2125 c 2139) (start-gate (+ 10 (- c 2125))))   ; one pairing alone: 0 YY 1 YK 2 KK 3 RY 4 RK 5 RR 6 IY 7 IK 8 IR
                                                            ; 9 II 10 SY 11 SK 12 SR 13 SS 14 SI
        ((<= 2140 c 2149) (start-gate (+ 100 (- c 2136))))  ; 2136+i: roster character i's pairings (i 4-13; 2140 Senjumaru's
                                                            ; five SY SK SR SS SI, 2141 the 6th character's six)
        ((<= 2150 c 2199) (start-gate (+ 10 (- c 2135))))   ; 2135+k: pairing k alone, k 15-64 (ROSTER-PAIRS; ten characters)
        ((loop for (lo hi fn) in *char-debug* thereis (and (<= lo c hi) (progn (funcall fn c) t))))   ; a character's own
        ((= c 2100) (setf *skip-cines* (not *skip-cines*)) (when *skip-cines* (skip-cine)))
        ((= c 2101) (setf *konpaku-start* 2))
        ((= c 2102) (setf *turbo* (not *turbo*)))
        ((= c 2103) (setf *hitboxes* (not *hitboxes*)))
        ((= c 2104) (setf *intents* (not *intents*)))
        ((= c 2105) (do-entities (e (b brain)) (setf (brain-off b) (not (brain-off b)))))
        ((= c 2106) (setf *perf-log* (not *perf-log*)))
        ((= c 2107) (when (entity-alive-p *p1*) (log-msg "~a" (state-hash-line))))
        ((= c 2108))                                     ; a no-op: it filled the Reiatsu, which left 2026-11-13 (R6; scripts still send it)
        ((= c 2109) (toggle-cam))
        ((<= 2110 c 2113) (start-gate (- c 2110)))
        ((<= 2114 c 2117) (start-gate (- c 2114)) (setf *combat-log* t *gate-log* t))
        ((<= 2120 c 2123) (setf (svref *no-draw* (- c 2120)) (not (svref *no-draw* (- c 2120)))))
        ((= c 2209) (setf *cine-hold* nil) (ensure-battle :ichigo :kenpachi) (place *p1* *p2* 3.0) (match-over *p1*))
        ((<= 2200 c 2299) (force-cine (- c 2200)))
        ((<= 10000 c 19999) (cine-at (floor (- c 10000) 1000) (mod c 1000)))
        ((<= 35000 c 35999) (cine-at (+ 9 (floor (- c 35000) 1000)) (mod c 1000)))
        ((= c 2320) (probe-mash))
        ((= c 2321) (force-burst))
        ((<= 2610 c 2612) (burst-burn-test (- c 2610)))
        ((= c 2328) (hud-cons-check))
        ((= c 2329) (brush-cons-check))
        ((= c 2390) (vfx5-cons-check))
        ((= c 2391) (vfx6-cons-check))
        ((= c 2326) (ensure-battle :ichigo :kenpachi) (place *p1* *p2* 3.0) (clash! *p1* *p2*))
        ((<= 2322 c 2325) (ensure-battle :ichigo :kenpachi) (place *p1* *p2* 3.5)
         (setf (gauges-fs (gauges *p1*)) *fs-max* (gauges-burst (gauges *p1*)) nil *one-hand* (one-hand-effective-p))   ; (the deck)
         (when (< c 2325) (burst! *p1* (nth (- c 2322) '(:white :blue :orange)))))
        ((= c 2393) (place *p1* *p2* 2.2)
         (dolist (e (list *p1* *p2*))                   ; a switched-off CPU lets go of what it held (a guard)
           (vpad-clear! (pilot-vpad (pilot e))) (let ((b (brain e))) (when b (setf (brain-press-left b) 0)))))
        ((<= 2394 c 2397) (string-test (- c 2394)))
        ((<= 2700 c 2709) (portrait-test (- c 2700)))
        ((<= 2300 c 2399) (force-special (- c 2300)))
        ((= c 2400) (setf *god* (not *god*)))
        ((<= 2600 c 2699) (setf *red-threshold* (/ (- c 2600) 100.0)))
        ((<= 81020 c 81022) (setf *gate-difficulty* (nth (- c 81020) '(:easy :normal :hard))))
        ((<= 22000 c 22999) (setf *gg-regen* (/ (- c 22000) 10.0)))
        ((<= 23000 c 23999) (setf *gg-regen-guardless* (/ (- c 23000) 10.0)))
        ((<= 26000 c 26999) (scale-k-links (- c 26000)))
        ((<= 30000 c 30999) (setf *gate-seed0* (- c 30000)))
        ((<= 31101 c 31199) (setf *gate-seeds* (- c 31100)))
        ((<= 2510 c 2512) (setf (fighter-ptr (fighter *p1*)) (- c 2509)))   ; P1's SP pointer 1 / 2 / 3 (the stance shots; no kit has a fourth, so 2513 below is reachable)
        ((= c 2513) (slowmo *core-clash-slowmo-scale* 3.0))                 ; 3 s of the cancel's slow motion (the smooth-draw check)
        ((= c 2514) (setf *scene-transparent* (not *scene-transparent*)))    ; the transparent scene (DUEL_WEBUI §4)
        ((= c 2515) (webhud-consing))                                         ; the battle screens' sync (DUEL_WEBUI §7)
        ((= c 2509) (setf *lhud-shapes* (case *lhud-shapes* ((nil) t) ((t) :back) (t nil))))   ; the paint shapes' test card (DUEL_LISP_HUD §10)
        ((= c 2518) (setf *lhud-still* (not *lhud-still*)))                  ; the Lisp HUD's still mode (phase 0: the legibility card)
        ((= c 2519) (lhud-consing) (lm-consing))                              ; the Lisp HUD's consing and time (DUEL_LISP_HUD §4.7; the menus' line §15)
        ((<= 2401 c 2404) (lm-results-scene (- c 2401)))                      ; a K.O. into RESULTS (the Lisp menus' review, DUEL_LISP_HUD §15)
        ((= c 2516) (let ((q (pos-of *p2*))) (set-reaction *p1* :knockdown 0 (aref q 0) (aref q 2) 0.0)))   ; P1 knocked down (the wake-up roll, DEVLOG §614)
        ((<= 2520 c 2599) (setf (camera-shift-x *camera*) (/ (- c 2550) 100f0)))   ; the lens shift across = (k - 30) / 100
        ((<= 2505 c 2506) (lhud-scene (= c 2506)))       ; the Lisp HUD's phone scenes (DUEL_LISP_HUD §13)
        ((<= 2820 c 2822) (setf (gauges-fs (gauges *p2*)) (f32 (nth (- c 2820) '(100.0 130.0 300.0)))) (steal-fs-line "victim"))   ; (SP scenes, S1: P2's flash-step 100 / 130 / 300, after a steal scene's setup)
        ((<= 2823 c 2826) (setf (gauges-fs (gauges *p1*)) (f32 (nth (- c 2823) '(300.0 100.0 10.0 0.0)))))   ; (S8: P1's flash-step 300 / 100 / 10 / 0, for the HUD's SP cues: full, one cell, short, empty)
        ((<= 2800 c 2815) (practice-cancel-scene c))      ; PRACTICE's GUARD ALL cancelling dummy (DUEL_CORE §9)
        ((= c 2495) (lhud-scene nil :intro t))            ; the same with the intro played (DUEL_LISP_HUD §14: the card, READY / 斬)
        ((= c 2496) (lhud-scene nil :picks '(:kenpachi :ichigo))   ; human Kenpachi in his Shikai vs Ichigo (the KAIHO strip on the left plate)
         (force-form *p1* :nozarashi) (setf (gauges-meter (gauges *p1*)) 2f0 (gauges-meter-idle (gauges *p1*)) 0))
        ((= c 2497) (when (and *p1* (eq *flow* :battle)) (match-over *p1*)))   ; P2 K.O.'d now: the finish, then the results
        ((= c 2507) (setf *hand* (if (eq *hand* :left) :right :left)))   ; the hand, for this run (the setting is not saved)
        ((= c 2508) (lhud-p2-form))                         ; P2 Kenpachi's next form (the plate's form seals, tag and kit strip)
        ((<= 2440 c 2449) (lhud-review (- c 2440)))
        ((<= 2500 c 2503)
         (setf *picks* (nth (- c 2500) '((:ichigo :kenpachi) (:kenpachi :ichigo) (:ichigo :ichigo) (:kenpachi :kenpachi)))
               *mode* :vs-cpu *match-seed* 1 *probe* nil *one-hand* (one-hand-effective-p))
         (let ((*skip-cines* t)) (start-match))
         (setf (brain-off (brain *p2*)) t))
        ((= c 2504)                                          ; human Kenpachi vs a HARD Ichigo CPU that learns (DUEL_AI_STRATEGY §8.14)
         (setf *picks* '(:kenpachi :ichigo) *mode* :vs-cpu *difficulty* :hard *probe* nil *one-hand* (one-hand-effective-p)
               *learn-debug-off* nil *fq-tables* nil)          ; (as in play; the next attach reads the page)
         (let ((*skip-cines* t)) (start-match)))))

;;; ---------------------------------------------------------------- overlays
(defun draw-hitboxes ()
  "Hurt cylinders (green), open melee windows (red: the move's volumes, DRAW-VOL, and a reach line),
hazards (orange)."
  (flet ((ring (x y z r cr cg cb) (draw-circle x y z r cr cg cb :segments 12 :width 0.015 :alpha 0.9)))
    (dolist (e (list *p1* *p2*))
      (let* ((p (pos-of e)) (b (model-body (model e))) (f (fighter e)) (mv (fighter-move f)))
        (ring (aref p 0) (+ 0.05 (aref p 1)) (aref p 2) (body-hurt-r b) 0.2 1.0 0.3)
        (ring (aref p 0) (+ (aref p 1) (body-hurt-h b)) (aref p 2) (body-hurt-r b) 0.2 1.0 0.3)
        (when (and mv (eq (fighter-state f) :move) (eq (fighter-phase f) :main))
          (loop for w across (mv-hits mv)
                when (and (<= (hw-from w) (fighter-sf f)) (< (fighter-sf f) (hw-to w)))
                  do (let* ((yaw (yaw-of e)) (r (mv-reach mv)))
                       (fx-line (aref p 0) 1.0 (aref p 2) (+ (aref p 0) (* r (fwd-x yaw))) 1.0 (+ (aref p 2) (* r (fwd-z yaw)))
                                0.04 1.0 0.1 0.1 1.0)
                       (dolist (v (hw-vols w)) (draw-vol v (aref p 0) (aref p 1) (aref p 2) yaw)))))))
    (do-entities (h (hz hazard))
      (when (hazard-hw hz) (ring (hazard-x hz) 1.0 (hazard-z hz) (max 0.3 (hazard-size hz)) 1.0 0.6 0.1)))))

;;; ---------------------------------------------------------------- the portrait probes (2700+k)
(defvar *frame-probe* nil "The framing / text probe runs (PORTRAIT-TEST 0).")
(defvar *frame-counts* (make-array 6 :initial-element 0) "Samples, P1 in, P2 in, both in, frames seen, the frame counter.")
(defvar *text-min* (list 1000 nil) "The smallest glyph px seen by the probe and the flow it was drawn in.")
(declaim (type f32vec *probe-v*))
(defvar *probe-v* (make-f32 3))

(defun fighter-screen-box (e)
  "Values x0 y0 x1 y1 (window px) of fighter E's drawn bulk (his hurt cylinder + 0.25 m around, 0.35 m over his head),
or NIL when a corner is behind the camera."
  (let* ((p (pos-of e)) (b (model-body (model e))) (r (+ 0.25 (body-hurt-r b))) (top (+ 0.35 (body-hurt-h b)))
         (x0 1e9) (y0 1e9) (x1 -1e9) (y1 -1e9) (v *probe-v*))
    (dolist (dx (list (- r) r) (values x0 y0 x1 y1))
      (dolist (dz (list (- r) r))
        (dolist (y (list 0.0 top))
          (unless (world-to-screen v (f32 (+ (aref p 0) dx)) (f32 (+ (aref p 1) y)) (f32 (+ (aref p 2) dz))) (return-from fighter-screen-box nil))
          (setf x0 (min x0 (aref v 0)) x1 (max x1 (aref v 0)) y0 (min y0 (aref v 1)) y1 (max y1 (aref v 1))))))))

(defun frame-probe-step ()
  "Once a frame after the HUD (main.lisp GAME-FRAME) while *FRAME-PROBE*: the text floor over every portrait screen, and
every 30th battle frame (no cinematic, not paused) whether each fighter's box sits in the arena band."
  (let ((c *frame-counts*) (w (window-width)) (h (window-height)))
    (when (portrait-p)
      (when (< *ui-text-min* (first *text-min*)) (setf *text-min* (list *ui-text-min* *flow*)))
      (when (and (eq *flow* :battle) (not *cine*) (not *paused*) (zerop (mod (incf (svref c 5)) 30)))
        (flet ((in (e) (multiple-value-bind (x0 y0 x1 y1) (fighter-screen-box e)   ; his upper half clear of both HUD blocks,
                         (and x0 (>= (- (min x1 w) (max x0 0)) (* 0.7 (- x1 x0)))       ; >= 70 % of his width on the screen
                              (>= y0 (* h (aref *band* 2))) (<= (* 0.5 (+ y0 y1)) (* h (aref *band* 3)))))))
          (let ((a (in *p1*)) (b (in *p2*)))
            (incf (svref c 0)) (when a (incf (svref c 1))) (when b (incf (svref c 2))) (when (and a b) (incf (svref c 3))))))))
  (setf *ui-text-min* 1000))

(defun frame-probe-line ()
  (let ((c *frame-counts*) (n (max 1 (svref *frame-counts* 0))))
    (log-msg "duel frame ~dx~d (css ~dx~d) band ~,3f-~,3f: p1 ~d/~d p2 ~d/~d both ~d/~d (~,1f %); text min ~a px in ~a, floor ~d px"
             (window-width) (window-height) (round (window-width) (pixel-density)) (round (window-height) (pixel-density))
             (aref *band* 2) (aref *band* 3) (svref c 1) (svref c 0) (svref c 2) (svref c 0) (svref c 3) (svref c 0)
             (/ (* 100.0 (svref c 3)) n) (first *text-min*) (second *text-min*) (ceiling (* 11 (pixel-density)) 7))))

(defun portrait-test (k)
  (case k
    (0 (if *frame-probe* (frame-probe-line) (setf *frame-probe* t))
       (when (and *p1* (entity-alive-p *p1*))
         (let ((d (pixel-density)))
           (flet ((b (e) (let ((l (multiple-value-list (fighter-screen-box e))))   ; (NIL when a corner is behind the camera:
                           (if (car l) l (list 0.0 0.0 0.0 0.0)))))                ; the title's demo; zeros, not a division by NIL)
             (log-msg "duel frame boxes (css): p1 ~{~,0f~^ ~} p2 ~{~,0f~^ ~} fov ~,1f shift ~,3f eye ~{~,2f~^ ~} at ~{~,2f~^ ~}"
                      (mapcar (lambda (v) (/ v d)) (b *p1*)) (mapcar (lambda (v) (/ v d)) (b *p2*))
                      (/ (camera-fov *camera*) (deg 1)) (camera-shift-y *camera*) (coerce *cam-eye* 'list) (coerce *cam-at* 'list))))))
    (1 (place *p1* *p2* 24.0))
    (2 (let ((p (pos-of *p1*)) (yaw (yaw-of *p1*)))          ; to his left, 4 m, facing him: the view lags behind
         (v3-set! (pos-of *p2*) (f32 (+ (aref p 0) (* 4 (fwd-z yaw)))) 0f0 (f32 (- (aref p 2) (* 4 (fwd-x yaw)))))
         (face-each-other *p2* *p1*)))
    (3 (place *p1* *p2* 1.0))
    (4 (let ((c0 (cons-bytes)) (p (pos-of *p1*)) (q (pos-of *p2*)) (dt 0.016f0) (asp (f32 (window-aspect))))
         (dotimes (i 100) (%portrait-camera p q dt nil))
         (let ((c1 (cons-bytes)))
           (dotimes (i 100) (%portrait-dolly asp))
           (let ((c2 (cons-bytes)))
             (log-msg "portrait consing: 100 x camera ~d B, 100 x dolly ~d B" (- c1 c0) (- c2 c1))))))))

(defun debug-hud (w h s)
  (declare (ignore h))
  (when (and *intents* (member *flow* '(:battle)))
    (dolist (e (list *p1* *p2*))
      (let ((b (brain e)) (v *hud-v*) (p (pos-of e)))
        (when (and b (world-to-screen v (aref p 0) 2.7 (aref p 2)))
          (ui-text (format nil "~a" (or (brain-act b) ""))
                   (aref v 0) (aref v 1) :scale s :align :center :color '(0.5 1 0.6 1) :shadow t)))))
  (when *turbo*
    (ui-text (format nil "TURBO  T ~d  ~a" *match-tick* *flow*) (* 0.5 w) (* 40 s) :scale (* 2 s) :align :center :color '(0.5 1 0.6 1))))
