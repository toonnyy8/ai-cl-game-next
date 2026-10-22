# DANGAI batch 1 (the skeleton) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** a playable DANGAI run (DUEL_ROGUE.md batch 1): a MODE row, the 10-step layout with elites and a boss
(without its rule), two doors between steps (two opponents, or a rest), the run cleared at step 10 then the
continuation, its own best record. No rewards, conditions or boss rules yet (batches 2–3).

**Architecture:** the run IS an ENDLESS run (`*mode*` = `:endless`) with `*rogue*` = T. ENDLESS's code (endless.lisp:
the carry, STAGE CLEAR, RESULTS, the record) takes four small `*rogue*` branches; the new pure rules live in
`rogue-rules.lisp` (host-tested), the doors screen and the debug entry in `rogue.lisp`. With `*rogue*` NIL every
ENDLESS path is byte-identical to today.

**Tech Stack:** Common Lisp (ECL → wasm), host ECL for tests, `tests/scripts/duel.py` browser scripts, `tools/simgate.py`.

## Global Constraints

- Shell: `E=/media/8tsp/projects/ecl-24.5.10/ecl-emscripten-host/bin/ecl`. Bounded waits only; never `pkill -f` /
  `pgrep -f`. Subagents never push or deploy.
- Code comments in English, matching the files' density (docstrings on every defun / defparameter).
- No character names in rogue-rules.lisp / rogue.lisp (the name-leak rule of the endless files).
- Determinism: doors and rests come from ENDLESS-LCG keyed on (run seed, step), never `sim-rnd`.
- Byte-identity with `*rogue*` NIL: simgate 28 pairings x 10 seeds identical to the parent commit; cvc 3/3; looks: only
  the MODE screen's stills may change (the new row).
- After any Lisp change finish with `./build.sh duel` (0 warnings) and `tools/pkgcheck.sh duel` (0).
- Commit trailers (every commit):
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and
  `Claude-Session: https://claude.ai/code/session_01NjLTcb3WzxAXSr1sgk5QhQ`

## File map

| File | Change |
|---|---|
| `duel/lisp/endless-rules.lisp` | `ramp-difficulty` (ENDLESS-DIFFICULTY delegates to it) |
| `duel/lisp/rogue-rules.lisp` (new) | layout, ramp per step, rests, doors, the rest's carry |
| `duel/lisp/endless.lisp` | `*rogue*`, `+pg-rogue+`, `endless-row`, four `*rogue*` branches |
| `duel/lisp/rogue.lisp` (new) | the DOORS screen (flow `:doors`), taking a door, its drawing |
| `duel/MANIFEST` | `rogue-rules.lisp` after `endless-rules.lisp`; `rogue.lisp` after `endless.lisp` |
| `duel/lisp/flow.lisp` | the MODE row, `go-mode` indices, `:doors` in FLOW-UPDATE |
| `duel/lisp/hud-screens.lisp` | `:doors` in HUD-DRAW |
| `duel/lisp/camera.lisp` | `:doors` keeps the results' shot |
| `duel/lisp/debug.lisp` | 84000–84999 |
| `duel/web/pwa.js` | page 50–69 = `soulduel.rogue.<k-50>` |
| `tests/duel-rules-test.lisp`, `tests/duel-rules/rogue.lisp` (new) | host checks |
| `tests/scripts/duel.py`, `tests/style-gates.py` | the MODE row shift; `duel-rogue.json` |
| docs | DUEL_ROGUE "Built", DUEL_GAMEPLAY debug range, manual.html, DEVLOG, docs/README |

---

### Task 1: the pure rules (rogue-rules.lisp) and their host checks

**Files:**
- Modify: `duel/lisp/endless-rules.lisp` (ENDLESS-DIFFICULTY)
- Create: `duel/lisp/rogue-rules.lisp`
- Create: `tests/duel-rules/rogue.lisp`
- Modify: `tests/duel-rules-test.lisp:14,17` (the two load lists)

**Interfaces:**
- Produces: `(ramp-difficulty floor row &optional levels)`, `*rogue-steps*` 10, `*rogue-boss-row*`,
  `*rogue-rest-konpaku*` 3, `(rogue-step-kind step)` → `:normal | :elite | :boss`, `(rogue-ramp step)` → a ramp row
  `(stage steps awaken awakened reishi-%)`, `(rogue-rest-steps seed)` → list of steps, `(rogue-doors seed step prev
  roster)` → list of plists `(:kind :fight :opponent c)` / `(:kind :rest)`, `(rogue-rest carry)` → carry plist.

- [ ] **Step 1: write the failing checks** — `tests/duel-rules/rogue.lisp`:

```lisp
;; ================================================================ DANGAI (docs/duel/DUEL_ROGUE.md, rogue-rules.lisp)
(in-package :duel)
(defparameter *rg-roster* '(:yamamoto :kenpachi :rukia :ichigo :senjumaru :barro :hisagi))
;; the layout: elites at 3 6 9 (and every third step on), the boss at 10 only
(check (equal (loop for st from 1 to 13 collect (rogue-step-kind st))
              '(:normal :normal :elite :normal :normal :elite :normal :normal :elite :boss :normal :elite :normal)))
;; the ramp: a normal step is ENDLESS's; an elite is harder than the normal step it replaces; the boss is HARD from any floor
(check (equal (rogue-ramp 1) (endless-ramp 1)))
(check (> (second (rogue-ramp 3)) (second (endless-ramp 3))))
(check (equal (rogue-ramp 10) *rogue-boss-row*))
(check (every (lambda (fl) (eq :hard (ramp-difficulty fl (rogue-ramp 10)))) '(:easy :normal :hard)))
;; ENDLESS's difficulty unchanged by the split into RAMP-DIFFICULTY
(check (loop for fl in '(:easy :normal :hard)
             always (loop for n from 1 to 15 always (eq (endless-difficulty fl n) (ramp-difficulty fl (endless-ramp n))))))
;; rests: at most 2 a run, normal steps 4-9 only, and some seeds have them
(check (loop for seed from 1 to 200
             always (let ((r (rogue-rest-steps seed)))
                      (and (<= (length r) 2) (every (lambda (st) (and (<= 4 st 9) (eq :normal (rogue-step-kind st)))) r)))))
(check (loop for seed from 1 to 50 thereis (rogue-rest-steps seed)))
;; doors: 1-2, the fights' opponents distinct and never PREV, one door at the boss, a rest only on a rest step, replayable
(check (loop for seed from 1 to 100
             always (loop for st from 2 to 15
                          for prev = (nth (mod (+ seed st) 7) *rg-roster*)
                          for d = (rogue-doors seed st prev *rg-roster*)
                          for fights = (loop for x in d when (eq (getf x :kind) :fight) collect (getf x :opponent))
                          always (and (<= 1 (length d) 2)
                                      (= (length fights) (length (remove-duplicates fights)))
                                      (not (member prev fights))
                                      (or (/= st 10) (= 1 (length d)))
                                      (eq (and (find :rest d :key (lambda (x) (getf x :kind))) t)
                                          (and (member st (rogue-rest-steps seed)) t))
                                      (equal d (rogue-doors seed st prev *rg-roster*))))))
(check (= 1 (length (rogue-doors 1 2 :rukia '(:rukia :ichigo)))))        ; one opponent left after PREV: one door
(check (and (= 9 (getf (rogue-rest '(:konpaku 8 :form :base)) :konpaku))
            (= 6 (getf (rogue-rest '(:konpaku 3 :form :base)) :konpaku))))
```

In `tests/duel-rules-test.lisp` add `"rogue-rules"` after `"endless-rules"` in the first list and `"rogue"` at the end
of the second list.

- [ ] **Step 2: run, expect failures** — `$E --norc --load tests/duel-rules-test.lisp 2>&1 | tail -3`. Expected: a load
  error (rogue-rules.lisp missing).

- [ ] **Step 3: implement.** In `endless-rules.lisp` replace ENDLESS-DIFFICULTY with:

```lisp
(defun ramp-difficulty (floor row &optional (levels '(:easy :normal :hard)))
  "The CPU difficulty of ramp ROW for a run started at FLOOR: the row's steps above it, clamped at the last of LEVELS."
  (nth (min (1- (length levels)) (+ (or (position floor levels) 0) (second row))) levels))

(defun endless-difficulty (floor stage &optional (levels '(:easy :normal :hard)))
  "The CPU difficulty at STAGE for a run started at FLOOR: the ramp's steps above it, clamped at the last of LEVELS."
  (ramp-difficulty floor (endless-ramp stage) levels))
```

Create `duel/lisp/rogue-rules.lisp`:

```lisp
;;;; rogue-rules.lisp — DANGAI 斷界行 (docs/duel/DUEL_ROGUE.md) as pure rules: the run's layout, the ramp per step, the
;;;; rest doors, the doors between steps, a rest's carry. Plain CL over endless-rules.lisp, host-tested
;;;; (tests/duel-rules/rogue.lisp); the mode (the doors screen, the record) is rogue.lisp over endless.lisp.
;;;; No character names in here.
(in-package :duel)

(defparameter *rogue-steps* 10 "A run: steps 1-10, the boss at 10; after it the continuation (DUEL_ROGUE §2).")
(defparameter *rogue-boss-row* '(10 2 100 t 150)
  "The boss's ramp row: two steps over any floor (HARD), awakened at FIGHT, Reishi 150 % (DUEL_ROGUE §5, R4).")
(defparameter *rogue-rest-from* 4 "The first step that may offer a rest door (DUEL_ROGUE §3).")
(defparameter *rogue-rest-max* 2 "A run offers at most this many rest doors (DUEL_ROGUE §3).")
(defparameter *rogue-rest-konpaku* 3 "A rest door: Konpaku + this, at most *KONPAKU-MAX* (DUEL_ROGUE §3).")

(defun rogue-step-kind (step)
  "STEP's kind (1-based): :boss at *ROGUE-STEPS*, :elite every third step (3 6 9, and on in the continuation), :normal."
  (cond ((= step *rogue-steps*) :boss) ((zerop (mod step 3)) :elite) (t :normal)))

(defun rogue-ramp (step)
  "STEP's ramp row (stage steps awaken awakened reishi-%): a normal step ENDLESS's own; an elite the row two stages on with
one more difficulty step (at most 2); the boss *ROGUE-BOSS-ROW*."
  (case (rogue-step-kind step)
    (:boss *rogue-boss-row*)
    (:elite (let ((r (copy-list (endless-ramp (+ step 2))))) (setf (second r) (min 2 (1+ (second r)))) r))
    (t (endless-ramp step))))

(defun rogue-lcg-at (seed step salt)
  "The doors' own draw for (SEED, STEP, SALT): ENDLESS-LCG, never SIM-RND (how a fight goes never changes the doors)."
  (endless-lcg (endless-lcg (+ (* seed 7919) (* step 104729) (* salt 15485863) 3))))

(defun rogue-rest-steps (seed)
  "The steps of run SEED whose second door is a rest: normal steps from *ROGUE-REST-FROM* before the boss, a 1-in-3 draw
each, at most *ROGUE-REST-MAX* (pure in SEED, so the doors replay)."
  (let ((out nil))
    (loop for st from *rogue-rest-from* below *rogue-steps*
          when (and (eq (rogue-step-kind st) :normal) (< (length out) *rogue-rest-max*)
                    (zerop (mod (floor (rogue-lcg-at seed st 1) 65536) 3)))
            do (push st out))
    (nreverse out)))

(defun rogue-doors (seed step prev roster)
  "The doors before STEP (2 on) of run SEED, PREV the last opponent fought: plists (:kind :fight :opponent c) or
(:kind :rest). Two doors with two different opponents, neither PREV while ROSTER allows (one door when only one is
left); the boss step one door; on a rest step (ROGUE-REST-STEPS) the second door is the rest."
  (let* ((pool (or (remove prev roster) roster)) (n (length pool))
         (x (rogue-lcg-at seed step 2)) (i (mod (floor x 65536) n))
         (j (mod (+ i 1 (mod (floor (endless-lcg x) 65536) (max 1 (1- n)))) n))
         (a (list :kind :fight :opponent (nth i pool))))
    (cond ((eq (rogue-step-kind step) :boss) (list a))
          ((member step (rogue-rest-steps seed)) (list a (list :kind :rest)))
          ((= n 1) (list a))
          (t (list a (list :kind :fight :opponent (nth j pool)))))))

(defun rogue-rest (carry)
  "CARRY (ENDLESS-CARRY's plist) after a rest door: Konpaku + *ROGUE-REST-KONPAKU*, at most *KONPAKU-MAX*."
  (let ((c (copy-list carry)))
    (setf (getf c :konpaku) (min *konpaku-max* (+ (getf c :konpaku) *rogue-rest-konpaku*)))
    c))
```

Add `lisp/rogue-rules.lisp` to `duel/MANIFEST` on the line after `lisp/endless-rules.lisp`.

- [ ] **Step 4: run, expect pass** — `$E --norc --load tests/duel-rules-test.lisp 2>&1 | tail -1`. Expected:
  `duel-rules-test: 9898 checks, ALL PASS` (9888 + 10; the exact total is whatever it prints with ALL PASS).

- [ ] **Step 5: commit** — `git add duel/lisp/endless-rules.lisp duel/lisp/rogue-rules.lisp duel/MANIFEST
  tests/duel-rules-test.lisp tests/duel-rules/rogue.lisp && git commit -m "DANGAI batch 1: the pure rules (layout,
  ramp per step, rests, doors) and their host checks (DUEL_ROGUE §2-§3)"` plus the trailers.

### Task 2: the run (endless.lisp branches, rogue.lisp, flow, page, debug)

**Files:**
- Modify: `duel/lisp/endless.lisp` (vars at the top; ENDLESS-BEST, ENDLESS-NEXT-STAGE, ENDLESS-APPLY!,
  ENDLESS-SAVE-RECORD, ENDLESS-OVER, ENDLESS-CLEAR-LINES, ENDLESS-CHOOSE, ENDLESS-DEBUG)
- Create: `duel/lisp/rogue.lisp`; `duel/MANIFEST` (`lisp/rogue.lisp` after `lisp/endless.lisp`)
- Modify: `duel/lisp/flow.lisp:302` (`*mode-menu*`), `:387-394` (the MODE rows), the `go-mode` calls (`:344,347,397,
  401,403`), `:419` (`:doors`), `:18` (the `*flow*` docstring)
- Modify: `duel/lisp/hud-screens.lisp:232`, `duel/lisp/camera.lisp:283`, `duel/lisp/debug.lisp:604`, `duel/web/pwa.js:58,68`

**Interfaces:**
- Consumes: Task 1's functions.
- Produces: `*rogue*` (defvar in endless.lisp), `+pg-rogue+` 50, `(endless-row n)`, `(rogue-open-doors)`,
  `(rogue-doors-update)`, `(hud-rogue-doors w h s)`, flow state `:doors`, debug `84000+100c+n`, `84980` (the clear),
  `84990` (the autopilot, door 0 every step), log lines `duel rogue door i step n kind [opponent]`.

- [ ] **Step 1: endless.lisp.** After `(defvar *endless-debug* ...)` add:

```lisp
(defvar *rogue* nil "This ENDLESS run is DANGAI (rogue.lisp, DUEL_ROGUE.md): the MODE row DANGAI and debug 84000+ set it.")
(defvar *rogue-next* nil "DANGAI: the opponent of the door taken, for ENDLESS-NEXT-STAGE (NIL: ENDLESS's bag).")
```

After `(defconstant +pg-endless+ ...)` add:

```lisp
(defconstant +pg-rogue+ 50 "Page get / set 50 + 2i: roster index i's best DANGAI steps, 51 + 2i its seconds (i < 10).")
(defun endless-pg () "The record's page base: DANGAI's or ENDLESS's." (if *rogue* +pg-rogue+ +pg-endless+))
(defun endless-row (n) "Stage N's ramp row: DANGAI's per step (ROGUE-RAMP) or ENDLESS's." (if *rogue* (rogue-ramp n) (endless-ramp n)))
```

In ENDLESS-BEST and ENDLESS-SAVE-RECORD replace every `+pg-endless+` by `(endless-pg)`.

In ENDLESS-NEXT-STAGE replace `(endless-opponent *endless-seed* n (playable-roster))` by
`(or (shiftf *rogue-next* nil) (endless-opponent *endless-seed* n (playable-roster)))`.

In ENDLESS-APPLY! replace `(r (endless-ramp n)) (d (endless-difficulty *endless-floor* n *difficulties*))` by
`(r (endless-row n)) (d (ramp-difficulty *endless-floor* r *difficulties*))`.

In ENDLESS-CLEAR-LINES: `(r (endless-ramp next))` → `(r (endless-row next))`; the NEXT line (vector element 5)
becomes

```lisp
(if *rogue*
    (format nil "NEXT  STAGE ~d~@[  ~a~]" next (case (rogue-step-kind next) (:elite "ELITE") (:boss "BOSS")))
    (format nil "NEXT  STAGE ~d  ~a  ~a" next (kit-name (find-kit opp :base))
            (endless-difficulty *endless-floor* next *difficulties*)))
```

and element 6 becomes `(if (and *rogue* (= n *rogue-steps*)) "RUN CLEAR" <the existing format form>)`. (Both
branches keep ENDLESS's strings byte-identical.)

In ENDLESS-CHOOSE replace the final `(endless-next-stage)` by `(if *rogue* (rogue-open-doors) (endless-next-stage))`.

In ENDLESS-OVER: vector element 0 → `(format nil "~:[ENDLESS~;DANGAI~]  ~a" *rogue* (kit-name ...))`; element 1 →
`(format nil "STAGES CLEARED  ~d~:[~;  RUN CLEAR~]" *endless-cleared* (and *rogue* (>= *endless-cleared* *rogue-steps*)))`.

ENDLESS-DEBUG takes `&optional rogue` and sets `*rogue* rogue` in the 990–993 branch and in the final (`t`) branch,
right before `endless-start`/`endless-auto-next`; the 980–989 branches leave it alone (they act on the running run).

- [ ] **Step 2: rogue.lisp.**

```lisp
;;;; rogue.lisp — DANGAI 斷界行 (docs/duel/DUEL_ROGUE.md), batch 1: the run is an ENDLESS run (endless.lisp: the carry,
;;;; STAGE CLEAR, RESULTS, the record) with *ROGUE* set; this file is the DOORS screen between steps (flow state :doors:
;;;; ROGUE-DOORS' doors, a rest or the next fight). The rules are rogue-rules.lisp. Debug 84000-84999 (debug.lisp:
;;;; ENDLESS-DEBUG with ROGUE). Log: "duel rogue door i step n kind [opponent]".
(in-package :duel)

(defvar *rogue-doors* nil "The DOORS screen's doors (ROGUE-DOORS' plists).")

(defun rogue-door-label (d)
  "A door's row: REST, or the opponent's name."
  (if (eq (getf d :kind) :rest) "REST" (kit-name (find-kit (getf d :opponent) :base))))

(defun rogue-door-note (d step)
  "What the selected door leads to: the rest's Konpaku, or the step's kind, CPU difficulty, awakening and Reishi."
  (if (eq (getf d :kind) :rest)
      (format nil "KONPAKU +~d" *rogue-rest-konpaku*)
      (let ((r (rogue-ramp step)))
        (format nil "~@[~a  ~]~a~:[~;  AWAKENED~]  REISHI ~d%"
                (case (rogue-step-kind step) (:elite "ELITE") (:boss "BOSS"))
                (ramp-difficulty *endless-floor* r *difficulties*) (fourth r) (fifth r)))))

(defun rogue-open-doors ()
  "After STAGE CLEAR's CONTINUE / REVERT (the carry made) or a rest: the next step's doors (the DOORS screen)."
  (let ((next (1+ *endless-stage*)))
    (setf *rogue-doors* (rogue-doors *endless-seed* next (first *endless-foes*) (playable-roster))
          *endless-lines* (vector (format nil "STAGE ~d" next)
                                  (format nil "KONPAKU  ~d" (getf *endless-carry* :konpaku))
                                  (mapcar #'rogue-door-label *rogue-doors*)
                                  (mapcar (lambda (d) (rogue-door-note d next)) *rogue-doors*)))
    (set-flow :doors)))

(defun rogue-take (i)
  "Door I: a rest (Konpaku +3, the step passed, the record checked, the next doors) or the next fight."
  (let ((d (nth i *rogue-doors*)))
    (log-msg "duel rogue door ~d step ~d ~(~a~)~@[ ~(~a~)~]" i (1+ *endless-stage*) (getf d :kind) (getf d :opponent))
    (if (eq (getf d :kind) :rest)
        (progn (incf *endless-stage*) (incf *endless-cleared*)
               (setf *endless-carry* (rogue-rest *endless-carry*))
               (endless-save-record)
               (rogue-open-doors))
        (progn (setf *rogue-next* (getf d :opponent)) (endless-next-stage)))))

(defun rogue-doors-update ()
  "DOORS per frame: the rows take input after 1 s, as STAGE CLEAR; the autopilot takes door 0."
  (cond (*endless-auto* (rogue-take 0))
        ((> *ft* 1.0) (let ((i (menu-nav (length *rogue-doors*)))) (when i (rogue-take i))))))

(defun hud-rogue-doors (w h s)
  "DOORS: the next stage, P1's Konpaku, the doors as rows with the selected one's note above them."
  (let ((l *endless-lines*))
    (multiple-value-bind (cx y pw) (results-card w h s)
      (ui-big-text (svref l 0) (round cx) (round (+ y (* 4 s))) (fit-scale (svref l 0) (* 3 s) (- pw (* 8 s)))
                   '(1 0.92 0.8 1) '(0.7 0.18 0.05 1) s :shear 0.0)
      (hud-text (svref l 1) cx (+ y (* 6 s) (* 11 (max 1 (round (* 1.5 s))))) (fit-scale (svref l 1) (* 1.5 s) (- pw (* 8 s)))
                *dim* :align :center)
      (when (> *ft* 1.0)
        (let* ((y0 (if (portrait-p) 0.8 0.72)) (note (nth *menu* (svref l 3))))
          (hud-text note cx (- (* y0 h) (* 14 s)) (fit-scale note (* 1.5 s) (- pw (* 8 s))) *ember* :align :center)
          (hud-menu (svref l 2) y0 w h s cx))))))
```

- [ ] **Step 3: the hooks.**
  - flow.lisp `*mode-menu*`: insert `"DANGAI"` after `"ENDLESS"`. The `:mode` case becomes
    `((0 1 2 3 4 5) (setf *mode* (nth i '(:vs-cpu :endless :endless :practice :vs-player :cpu-cpu)) *rogue* (= i 2)
    *one-hand* (and (< i 4) (one-hand-effective-p))) (go-select))`, then `(6 (set-flow :settings)) (7 (set-flow
    :controls)) (8 (open-manual))`. Every `(go-mode 5)` → `(go-mode 6)`, every `(go-mode 6)` → `(go-mode 7)` (do the 6s
    first). FLOW-UPDATE: add `(:doors (rogue-doors-update))` after `(:clear ...)`. The `*flow*` docstring: add `:doors
    (DANGAI)`.
  - hud-screens.lisp HUD-DRAW: add `(:doors (hud-rogue-doors w h s))` after the `:clear` clause.
  - camera.lisp MENU-CAMERA: `((:results :clear) ...` → `((:results :clear :doors) ...`.
  - debug.lisp: next to the 80000 clause add `((<= 84000 c 84999) (endless-debug (- c 84000) t))` (the 80000 clause
    passes NIL: `(endless-debug (- c 80000) nil)`).
  - pwa.js: in `get` add `if (k >= 50 && k < 70) return +(stored('soulduel.rogue.' + (k - 50)) || 0) | 0;` and in `set`
    `if (k >= 50 && k < 70) store('soulduel.rogue.' + (k - 50), String(v));` next to the endless lines.

- [ ] **Step 4: build and smoke** — `./build.sh duel 2>&1 | tail -2` (0 warnings), `tools/pkgcheck.sh duel` (0 0),
  `node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 8 --shot /tmp/claude-0/smoke.png` (exit 0). Host tests ALL PASS.

- [ ] **Step 5: commit** (the trailers): "DANGAI batch 1: the run on ENDLESS (*rogue*), the DOORS screen, the MODE row,
  page 50-69, debug 84000-84999 (DUEL_ROGUE §2-§3, §8)".

### Task 3: scripts, gates and docs

**Files:** `tests/scripts/duel.py`, `tests/style-gates.py`, `docs/duel/DUEL_ROGUE.md`, `docs/duel/DUEL_GAMEPLAY.md`,
`duel/web/manual.html`, `docs/DEVLOG.zh-TW.md`, `docs/README.md` (this plan's line).

- [ ] **Step 1: the row shift.** In `tests/scripts/duel.py` and `tests/style-gates.py`, every MODE-menu navigation
  that reaches a row ≥ 2 (PRACTICE … MANUAL) gets one more `ArrowDown` (keyboard) or its touch row index + 1
  (`row(0.52, i)` → `row(0.52, i + 1)`; a raw y such as `451` is the row's y: add one ROW, 36.67 px, when the row
  is ≥ 2). Find them with `grep -n "mode\|ArrowDown\|row(0.52" tests/scripts/duel.py tests/style-gates.py`. Regenerate:
  `python3 tests/scripts/duel.py`.
- [ ] **Step 2: `duel-rogue.json`** — add after the endless scripts:

```python
# DANGAI (docs/duel/DUEL_ROGUE.md batch 1; --fixed-dt 16.666667 --secs 60): MODE row 2 -> P1 Kenpachi -> START NORMAL;
# stage 1 cleared by 80980 -> CONTINUE -> DOORS (shot) -> door 0 -> stage 2 cleared -> CONTINUE -> DOORS -> door 1 ->
# pause RETIRE -> RESULTS ("DANGAI  ..."). Log: "duel rogue door 0 step 2 fight ...", "duel rogue door 1 step 3 ...".
def rogue_script():
    def es(t, n): return {"at": round(t, 2), "shot": f"{SHOTS}rogue-{n}.png"}
    t = T0; ev = [cmd(t - 0.5, 2106)]
    ev += tap(t, "Enter") + tap(t + 1.8, "ArrowDown") + tap(t + 2.0, "ArrowDown") + tap(t + 2.3, "Enter")
    ev += tap(t + 3.0, "KeyD") + tap(t + 3.3, "Enter") + tap(t + 4.8, "Enter") + tap(t + 6.5, "Escape")
    t += 8.0
    ev += [cmd(t, 80980), es(t + 5.0, "clear")] + tap(t + 6.0, "Enter") + [es(t + 7.5, "doors")] + tap(t + 8.0, "Enter")
    ev += tap(t + 10.0, "Escape"); t += 12.0
    ev += [cmd(t, 80980)] + tap(t + 6.0, "Enter") + [es(t + 7.5, "doors-2")] + tap(t + 8.0, "ArrowDown") + tap(t + 8.3, "Enter")
    ev += tap(t + 10.0, "Escape"); t += 12.0
    ev += tap(t, "Escape") + tap(t + 0.8, "ArrowDown") + tap(t + 1.1, "Enter") + [es(t + 6.0, "results")]
    return ev
write("rogue", rogue_script())
```

  Run it: `node tools/run.mjs dist/duel --fixed-dt 16.666667 --secs 60 --script tests/scripts/duel-rogue.json` and check
  the log for two `duel rogue door` lines, `duel endless over`, and the shots (doors listed, the note line).
  Also run `duel-endless.json` (`--secs 110`): its log lines unchanged ("over stages 3 ... record T", the autopilot's gate line).
- [ ] **Step 3: gates.** Host tests ALL PASS; `python3 tests/debug-ranges-check.py` 0 errors (after Step 4's doc line);
  `python3 tools/simgate.py --summary --seeds 10` rows identical to the parent commit's (`git worktree add` the parent,
  run the same command there, `cmp` the two outputs); `python3 tests/style-gates.py cvc dist/duel` 3/3;
  `python3 tests/style-gates.py looks BASE dist/duel --jobs 4` with BASE = the parent's dist: only the MODE screen's
  stills differ (report every differing still).
- [ ] **Step 4: docs.** DUEL_GAMEPLAY "Debug commands": a row `84000+100c+n / 84980 / 84990 | DANGAI (DUEL_ROGUE.md):
  a debug run of roster c from step n (seed 1, no record); clear the stage (as 80980); the autopilot (door 0, CONTINUE)`.
  DUEL_ROGUE: a "Built: batch 1" section (what exists, the log lines, the deviations: the doors are STAGE CLEAR-style
  rows, not cards yet; the doors draw both opponents from the roster without PREV, not ENDLESS's bag; the reward type
  is not on the doors until batch 2). manual.html: a DANGAI row in the MODE table and a short `<h3 id="dangai">` section
  (zh-TW: 10 關、第 3/6/9 關精英、第 10 關頭目、過關後選兩扇門之一、休息點魂魄 +3、打贏頭目算通關可續打；獎勵之後加入).
  DEVLOG §310 opening 「使用者：「先走 2」」. docs/README: this plan's line.
- [ ] **Step 5: commit, build** — `./build.sh duel` last; commit with the trailers.

## Self-review notes

- Spec coverage (batch 1 of DUEL_ROGUE §10): MODE row (T2), layout / elites / boss (T1), doors + rests (T1, T2), run
  clear + continuation (T2: RUN CLEAR line, the continuation is CONTINUE after step 10), record (T2: page 50+),
  determinism (T1), byte-identity (T3). Rewards, conditions, boss rules, UPGRADE at rests, unlocks / ranks: later
  batches by design.
- Names used across tasks: `rogue-step-kind`, `rogue-ramp`, `ramp-difficulty`, `rogue-rest-steps`, `rogue-doors`,
  `rogue-rest`, `*rogue-steps*`, `*rogue-rest-konpaku*`, `*rogue*`, `*rogue-next*`, `+pg-rogue+`, `endless-row`,
  `endless-pg`, `rogue-open-doors`, `rogue-take`, `rogue-doors-update`, `hud-rogue-doors`: consistent.
