;; ================================================================ style knobs (strategy-glue.lisp STYLE-KNOB, DUEL_AI_STRATEGY §11.6)
;; A matchup style CPU reads its decision tunables as (style-knob b :KEY default) = (strat-out (brain-now b) :KEY default), so the
;; checks run on STRAT-OUT (the brain is not host-loadable). The keys are read from the style sources' text, so a new knob is covered.
(in-package :duel)

(defun sk-keys ()
  "Every arm key the style CPUs read through STYLE-KNOB / STYLE-DIF / STYLE-ROLL / STYLE-ON, plus *IKS-MIX-KEYS*'s (lower-case strings, no colon)."
  (let ((keys nil))
    (dolist (f '("duel/lisp/cpu-ki-ken.lisp" "duel/lisp/cpu-kh-ken.lisp" "duel/lisp/cpu-ki-ichigo.lisp"
                 "duel/lisp/cpu-hisagi-range.lisp" "duel/lisp/cpu-hk-hisagi.lisp") (nreverse keys))
      (dolist (l (un-lines f))
        (dolist (pre '("(style-knob b :" "(style-dif b :" "(style-roll b :" "(style-on b :" " :iks-mix-"))
          (loop for p = (search pre l) then (search pre l :start2 (1+ p)) while p
                do (let* ((s (+ p (length pre) (if (char= (char pre 0) #\Space) -8 0)))
                          (e (position-if (lambda (c) (member c '(#\Space #\) #\())) l :start s))
                          (k (subseq l s e)))
                     (pushnew k keys :test #'string=))))))))

(defun sk-tree-has (tree names)
  "Does TREE (conses, symbols, numbers ...) hold a keyword named in NAMES anywhere?"
  (cond ((keywordp tree) (member (string-downcase (symbol-name tree)) names :test #'string=))
        ((consp tree) (or (sk-tree-has (car tree) names) (sk-tree-has (cdr tree) names)))))

(let* ((keys (sk-keys)) (kws (mapcar (lambda (k) (intern (string-upcase k) :keyword)) keys)))
  ;; the scan finds them all: Kenpachi 25 (cpu-ki-ken), his KH styles 4 (cpu-kh-ken), Ichigo 24 (cpu-ki-ichigo, 5 of them the mode mix),
  ;; Hisagi 14 (PLAN4 B3, KNOBS.md §6.6: the ranged mode's distance rule 7, cpu-hisagi-range; the HK style's kite 7, cpu-hk-hisagi),
  ;; Ichigo 8 more (PLAN4 B3, KNOBS.md §6.7: the patience and pointer-2 switches, the hover adds, the retreat, the steer, KESSA's chains)
  ;; PLAN4 P5 (2026-11-15): Kenpachi's 8 more (KNOBS.md §6.1 / §6.2: the wave mix 5, :kk-lunge-any, :kk-p2-or, :khf-bait-fs)
  (check (= 83 (length keys)))
  (check (= 7 (count-if (lambda (k) (string= "hr-" (subseq k 0 3))) keys)))
  (check (= 7 (count-if (lambda (k) (eql 0 (search "hkk-" k))) keys)))
  (check (= 32 (count-if (lambda (k) (string= "kk-" (subseq k 0 3))) keys)))
  (check (= 32 (count-if (lambda (k) (string= "iks-" (subseq k 0 4))) keys)))
  ;; a style prefix on every key, so none collides with the shared keys (:range :ns :hoho ...)
  (check (every (lambda (k) (some (lambda (p) (eql 0 (search p k))) '("kk-" "iks-" "kso-" "khf-" "hr-" "hkk-"))) keys))
  ;; an arm's :BASE sets a knob, a firing rule replaces it, a rule that does not fire leaves the base; absent: the style's own value (EQ)
  (let ((d (list 1.5)))
    (dolist (k kws)
      (let ((arm (list :base (list k 7.0) :rules (list (list '((:dj :in)) (list k 3.0))))))
        (check (and (~= 7.0 (strat-out (cons arm '(:dj 3.0)) k 1.0))
                    (~= 3.0 (strat-out (cons arm '(:dj 0.5)) k 1.0))
                    (eq d (strat-out (cons '(:base (:range 0.7 :ns 0.3)) '(:dj 0.5)) k d))
                    (eq d (strat-out nil k d)))))))
  ;; no library unit or table names a knob but the searched arms the final tables ship (DUEL_AI_STRATEGY §11.16: units :c-*, tables :f-*;
  ;; §11.27: the re-collection's units :x-*; §11.29, PLAN4 B4: the one-job arms :a4-* / :h4-*, whose keys ARE their jobs, and the T0 tables
  ;; :t0-* that name them), and no seed arm of the SP search (the library's arms written out, sp/arms/*.lisp, and the pilot's): their play is
  ;; unchanged. The searched arms (sp/arms/r<n>/, x1/, arms4/) name knobs by design.
  (flet ((unsearched (l &rest pres) (remove-if (lambda (u) (some (lambda (pre) (eql 0 (search pre (symbol-name (getf u :id))))) pres)) l)))
    (check (notany (lambda (v) (sk-tree-has v keys)) (list *strat-styles* *strat-data* (unsearched *strat-units* "C-" "X-" "A4-" "H4-") *strat-rule-bases*
                                                           (unsearched *strat-library* "F-" "T0-"))))
    (check (sk-tree-has *strat-units* keys)))
  (dolist (f (append (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/arms/*.lisp" *load-truename*))
                     (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/arms/pilot/*.lisp" *load-truename*))))
    (unless (string= "dump" (pathname-name f))          ; (the arm writer, a script)
      (with-open-file (s f :external-format :utf-8)
        (let ((*read-eval* nil))
          (check (not (loop for form = (read s nil :eof) until (eq form :eof) thereis (sk-tree-has form keys))))))))
  ;; KNOBS.md documents every key (§6's tables)
  (let ((doc (format nil "~{~a~%~}" (un-lines "docs/research/strategy-drsi/sp/KNOBS.md"))))
    (dolist (k keys) (check (search (format nil "`:~a`" k) doc)))))

;; ================================================================ the exchange keys (DUEL_AI_STRATEGY §11.23, PLAN3 X1)
;; The shared exchange layer's eight knobs as arm keys, read in core-ai.lisp as scales on the per-difficulty value: a chance through
;; STRAT-SCALE (x k, within 0-1; CAI-ROLL), the margin and the wait through STRAT-MUL (x k, >= 0; the wait rounded to frames), :XCH-J
;; through XCH-J-WEIGHTS (xch-ai test). Not style keys: the scan above (67) is the style CPUs' own; these get their own list.
(let* ((xkeys '(:xch-sa-p :xch-carry-p :xch-j :clash-p :clash-margin :xch-sa-wait :awaken-break-p :awaken-kikon-p))
       (names (mapcar (lambda (k) (string-downcase (symbol-name k))) xkeys))
       (src (format nil "~{~a~%~}" (un-lines "duel/lisp/core-ai.lisp"))))
  ;; each one read in core-ai.lisp (its readers CAI-XCH-STEP, CAI-CLASH, CAI-AWAKEN-BREAK's callers, CAI-MARGIN)
  (dolist (n names) (check (search (format nil ":~a " n) src)))
  ;; no key: the value itself (EQ), so no arm before X1 plays differently; a key scales it, a chance kept within 0-1
  (let ((now (cons '(:base (:range 0.7)) '(:dj 1.0))) (p 0.55))
    (check (eq p (strat-scale now :clash-p p)))
    (check (eq p (strat-scale nil :clash-p p)))
    (check (eql 4 (strat-mul now :xch-sa-wait 4)))
    (check (eql 4 (strat-mul nil :xch-sa-wait 4)))
    (check (eq *cai-clash-margin* (strat-mul now :clash-margin *cai-clash-margin*))))
  (flet ((arm (k v) (cons (list :base (list k v)) '(:dj 1.0))))
    (check (~= 1.0 (strat-scale (arm :clash-p 2.0) :clash-p 0.6)))
    (check (~= 0.0 (strat-scale (arm :clash-p -1.0) :clash-p 0.6)))
    (check (~= 0.3 (strat-scale (arm :awaken-kikon-p 0.5) :awaken-kikon-p 0.6)))
    (check (eql 6 (strat-mul (arm :xch-sa-wait 1.5) :xch-sa-wait 4)))          ; (frames: a fixnum)
    (check (eql 5 (strat-mul (arm :xch-sa-wait 1.125) :xch-sa-wait 4)))        ; (4.5: half up)
    (check (eql 0 (strat-mul (arm :xch-sa-wait -2.0) :xch-sa-wait 4)))         ; (kept >= 0)
    (check (~= 1.5 (strat-mul (arm :clash-margin 1.5) :clash-margin 1.0)))
    (check (~= 0.0 (strat-mul (arm :clash-margin -1.0) :clash-margin 1.0)))
    ;; EASY <= NORMAL <= HARD under any one scale (a chance, and the wait's frames a monotone map)
    (dolist (k '(0.0 0.5 1.0 1.5 3.0))
      (dolist (pl (list *cai-xch-sa-p* *cai-clash-p* *cai-awaken-break-p* *cai-awaken-kikon-p*))
        (flet ((s (d) (strat-scale (arm :clash-p k) :clash-p (getf pl d))))
          (check (<= (s :easy) (s :normal) (s :hard)))))))
  ;; no shipped strategy, unit, table, seed arm or final table names one (proof 4 of §11.23: no key, no change), but the re-collection's
  ;; arms the five tables of §11.27 ship: the units :x-*, those five :f-* entries (which name them by id and hold them once expanded), and
  ;; their five raw files in sp/final/ (proved = the lookup by sp/final/proofs.sh). The other four final tables (ih-hisagi and the mirrors) and
  ;; every unit before §11.27 still hold none, so their play is unchanged.
  ;; §11.29 (PLAN4 B4): the six exchange data units :d-x-* (one per pairing side, laid under a T0 table's arms by its :WITH) and the six
  ;; cross-pairing :t0-* entries that name them hold them too; the three mirror T0 tables (no :WITH) and the one-job arm units hold none.
  (let ((x-units (remove-if-not (lambda (u) (eql 0 (search "X-" (symbol-name (getf u :id))))) *strat-units*))
        (x-data (remove-if-not (lambda (u) (eql 0 (search "D-X-" (symbol-name (getf u :id))))) *strat-data*))
        (x-tables '(:f-ki-kenpachi :f-ki-ichigo :f-kh-kenpachi :f-kh-hisagi :f-ih-ichigo
                    :t0-ki-ichigo :t0-ki-kenpachi :t0-kh-kenpachi :t0-kh-hisagi :t0-ih-ichigo :t0-ih-hisagi)))   ; (*STRAT-LIBRARY* holds them expanded)
    (check (= 13 (length x-units)))
    (check (= 6 (length x-data)))
    (check (and (sk-tree-has x-units names) (sk-tree-has x-data names)))
    (check (every (lambda (id) (sk-tree-has (strat-by-id id) names)) x-tables))
    (check (notany (lambda (v) (sk-tree-has v names))
                   (list *strat-styles* (set-difference *strat-data* x-data) (set-difference *strat-units* x-units) *strat-rule-bases*
                         (remove-if (lambda (e) (member (getf e :id) x-tables)) *strat-library*)))))
  (dolist (f (append (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/arms/*.lisp" *load-truename*))
                     (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/arms/pilot/*.lisp" *load-truename*))
                     (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/final/*.lisp" *load-truename*))))
    (unless (member (pathname-name f) '("dump" "ki-kenpachi" "ki-ichigo" "kh-kenpachi" "kh-hisagi" "ih-ichigo") :test #'string=)
      (with-open-file (s f :external-format :utf-8)
        (let ((*read-eval* nil))
          (check (not (loop for form = (read s nil :eof) until (eq form :eof) thereis (sk-tree-has form names))))))))
  ;; KNOBS.md documents every one (§6.5)
  (let ((doc (format nil "~{~a~%~}" (un-lines "docs/research/strategy-drsi/sp/KNOBS.md"))))
    (dolist (n names) (check (search (format nil "`:~a`" n) doc)))))
