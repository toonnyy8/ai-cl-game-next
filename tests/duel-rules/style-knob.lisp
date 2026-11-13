;; ================================================================ style knobs (strategy-glue.lisp STYLE-KNOB, DUEL_AI_STRATEGY §11.6)
;; A matchup style CPU reads its decision tunables as (style-knob b :KEY default) = (strat-out (brain-now b) :KEY default), so the
;; checks run on STRAT-OUT (the brain is not host-loadable). The keys are read from the style sources' text, so a new knob is covered.
(in-package :duel)

(defun sk-keys ()
  "Every arm key the style CPUs read through STYLE-KNOB / STYLE-DIF / STYLE-ROLL, plus *IKS-MIX-KEYS*'s (lower-case strings, no colon)."
  (let ((keys nil))
    (dolist (f '("duel/lisp/cpu-ki-ken.lisp" "duel/lisp/cpu-kh-ken.lisp" "duel/lisp/cpu-ki-ichigo.lisp") (nreverse keys))
      (dolist (l (un-lines f))
        (dolist (pre '("(style-knob b :" "(style-dif b :" "(style-roll b :" " :iks-mix-"))
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
  ;; the scan finds them all: Kenpachi 25 (cpu-ki-ken), his KH styles 4 (cpu-kh-ken), Ichigo 24 (cpu-ki-ichigo, 5 of them the mode mix)
  (check (= 53 (length keys)))
  (check (= 25 (count-if (lambda (k) (string= "kk-" (subseq k 0 3))) keys)))
  (check (= 24 (count-if (lambda (k) (string= "iks-" (subseq k 0 4))) keys)))
  ;; a style prefix on every key, so none collides with the shared keys (:range :ns :hoho ...)
  (check (every (lambda (k) (some (lambda (p) (eql 0 (search p k))) '("kk-" "iks-" "kso-" "khf-"))) keys))
  ;; an arm's :BASE sets a knob, a firing rule replaces it, a rule that does not fire leaves the base; absent: the style's own value (EQ)
  (let ((d (list 1.5)))
    (dolist (k kws)
      (let ((arm (list :base (list k 7.0) :rules (list (list '((:dj :in)) (list k 3.0))))))
        (check (and (~= 7.0 (strat-out (cons arm '(:dj 3.0)) k 1.0))
                    (~= 3.0 (strat-out (cons arm '(:dj 0.5)) k 1.0))
                    (eq d (strat-out (cons '(:base (:range 0.7 :ns 0.3)) '(:dj 0.5)) k d))
                    (eq d (strat-out nil k d)))))))
  ;; no shipped strategy names a knob (every library unit and table), and no arm file of the SP search: their play is unchanged
  (check (notany (lambda (v) (sk-tree-has v keys)) (list *strat-styles* *strat-data* *strat-units* *strat-rule-bases* *strat-library*)))
  (dolist (f (append (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/arms/*.lisp" *load-truename*))
                     (directory (merge-pathnames "../../docs/research/strategy-drsi/sp/arms/*/*.lisp" *load-truename*))))
    (unless (string= "dump" (pathname-name f))          ; (the arm writer, a script)
      (with-open-file (s f :external-format :utf-8)
        (let ((*read-eval* nil))
          (check (not (loop for form = (read s nil :eof) until (eq form :eof) thereis (sk-tree-has form keys))))))))
  ;; KNOBS.md documents every key (§6's tables)
  (let ((doc (format nil "~{~a~%~}" (un-lines "docs/research/strategy-drsi/sp/KNOBS.md"))))
    (dolist (k keys) (check (search (format nil "`:~a`" k) doc)))))
