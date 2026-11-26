;;;; trace.lisp — what record.lisp and replay.lisp share: the trace format, its parser, the out-of-band events and how they apply.
;;;; A trace (build/oracle/traces/<name>.trace) is a sequence of lines, read in order (records are keyed by their order, not by the
;;;; tick: BEGIN-BATTLE resets *MATCH-TICK* to 0 after the intro, and a trial file's trials share one match):
;;;;   # ...                       comments: how it was made; "# trial begin NAME" / "# trial end NAME | ..." (trial.lisp's own lines)
;;;;   S cmds <debug command> ...  start: a fresh image (SG-INIT), these commands queued, then tools/simgate/run.lisp's frames until the
;;;;                               gate / match is over (no E or F lines follow)
;;;;   S trials <file>             start: a fresh image (SG-INIT) and one frame (tools/simgate/trial.lisp's start; it runs no step), then
;;;;                               the E and F lines below, in order. The trace is self-describing: <file> (the trial file it was
;;;;                               recorded from, from the repo root) is for reference; a replay never reads it or runs trial.lisp
;;;;   E <action> <arg> ...        an out-of-band action the trial runner took between frames: apply it now (grammar below)
;;;;   e [  tick] ...              a combat log line that E line's action printed (compared with what the applied action prints)
;;;;   R [  tick] ...              a combat log line the trial runner printed between frames outside any E action (its script's "P1
;;;;                               press ...", "P1 at simf N", "simf N"): not the sim's, never compared
;;;;   F                           run one frame (ENGINE::%FRAME, 1/60 s, not turbo): its steps' records follow
;;;;   [  tick] ...                a combat log line of the sim, printed during the step (in a cmds trace: or between its frames)
;;;;   C [  tick] ...              a combat log line the CPUs printed inside BRAIN-SYSTEM (for reference: a sim without the CPU cannot
;;;;                               print it; never compared)
;;;;   T tick vt1 downs1 sx1 sy1 vt2 downs2 sx2 sy2 rnd
;;;;   H duel hash t=...           STATE-HASH-LINE at the step's end
;;;;   B <field> ...               the sim state's raw bits at the step's end (TR-B-LINE), or "B =": the same text as the trace's last B
;;;;                               line. A step's record is its [ / C lines, T, H, B
;;;;   # B fields: <name> ...      (the second line) the B fields' names in order (TR-B-NAMES): the globals, p1.*, p2.*, "|", then one
;;;;                               hazard's fields, repeated per live hazard in entity order after the "|". Per side: pos, motion,
;;;;                               every slot of FIGHTER, GAUGES, ICS, HSS, YSS; per hazard every slot. Values as TR-B-ENC writes
;;;;                               them (a single-float its IEEE bits as 8 hex digits, a double 16, an integer decimal, ...)
;;;; T: on a step that ran the sim's systems (a sim frame: the vpad ticks advance) the values right after BRAIN-SYSTEM, i.e. what the
;;;; brains wrote for FIGHTER-SYSTEM to read and the sim stream after their draws; on any other step (intro / cinematic / hitstop /
;;;; slow-motion wait) the values at the step's end. vtK = side K's vpad tick, downsK = its nine buttons as 3 hex digits (bit i =
;;;; *VPAD-ACTIONS* element i: bit 0 :mod, 1 :quick, 2 :flash, 3 :sig, 4 :guard, 5 :breaker, 6 :kikon, 7 :step, 8 :awaken), sxK / syK =
;;;; its stick as single-floats printed shortest round-trip (PRIN1 with single-float the default format: "0.3", "-1.0", "-0.0"; Rust's
;;;; f32::from_str reads them back exactly), rnd = (SIM-RND-STATE) as 8 hex digits. A replay writes downs with VPAD-SET! in bit order
;;;; (as the CPU's AI-PRESS-WRITE! does) after the step's VPAD-BEGIN-STEP!, so the press / since / modded stamps follow from the edges.
;;;;
;;;; E grammar (SIDE = 0 for P1 / 1 for P2; values are Lisp-printed: integers, single-floats as T's sticks, keywords :NAME, T / NIL):
;;;;   E set SIDE <accessor> <value>   a field of side SIDE's component: (SETF (<accessor> obj) value), obj = the accessor's component:
;;;;                                   gauges-* -> GAUGES, fighter-* -> FIGHTER, hss-* -> HS (Hisagi's state; attached if missing).
;;;;                                   The fields: *TR-SIDE-FIELDS*. Emitted for each field that changed since the last E / F line.
;;;;   E set - <global> <value>        a global: *COMBAT-LOG* *SKIP-CINES* *TIMER* (SETF SYMBOL-VALUE); SIM-RND-STATE (SETF (SIM-RND-STATE))
;;;;   E battle <C1> <C2>              (ENSURE-BATTLE C1 C2 :CPU T): a CPU vs CPU match of those characters (a new one, cinematics skipped,
;;;;                                   unless one of them is already in battle)
;;;;   E form SIDE <form>              (FORCE-FORM e form)
;;;;   E hisagi-reset SIDE             (HS-RESET e)
;;;;   E place <dist>                  (PLACE P1 P2 dist): DIST m apart on the x axis around the centre, facing, idle, no hazards
;;;;   E vpad-clear SIDE               (VPAD-CLEAR! his vpad)
;;;;   E clear-hazards                 (CLEAR-HAZARDS)
;;;;   E skip-cine                     (SKIP-CINE)
;;;;   E burst-end SIDE                (BURST-END! e)
;;;;   E full-gauges SIDE <meter>      (FULL-GAUGES! e meter)
;;;;   E cmd <n>                       (DEBUG-COMMAND n)
;;;;   E core-start SIDE <move>        (CORE-START! e move), move = the key of his kit's KIT-MOVES table
(in-package :duel)

(defun tr-split (s)
  (loop for start = 0 then (1+ p) for p = (position #\Space s :start start)
        for w = (subseq s start p) when (plusp (length w)) collect w while p))

(defun tr-print (x) (let ((*read-default-float-format* 'single-float) (*package* (find-package :duel))) (prin1-to-string x)))
(defun tr-value (s) (let ((*read-default-float-format* 'single-float) (*read-eval* nil) (*package* (find-package :duel))) (read-from-string s)))
(defun tr-float (x) (tr-print x))
(defun tr-read-float (s) (coerce (tr-value s) 'single-float))

(defun tr-side-now (e)
  (let ((vp (pilot-vpad (pilot e))))
    (list (vpad-tick vp)
          (loop for a across *vpad-actions* for bit from 0 sum (if (vpad-down vp a) (ash 1 bit) 0))
          (vpad-sx vp) (vpad-sy vp))))

(defun tr-t-fields ()
  "The T fields now: (tick vt1 downs1 sx1 sy1 vt2 downs2 sx2 sy2 rnd)."
  (append (list *match-tick*) (tr-side-now *p1*) (tr-side-now *p2*) (list (sim-rnd-state))))

(defun tr-t-line (tf)
  (destructuring-bind (tick vt1 d1 x1 y1 vt2 d2 x2 y2 rnd) tf
    (format nil "T ~d ~d ~3,'0x ~a ~a ~d ~3,'0x ~a ~a ~8,'0x" tick vt1 d1 (tr-float x1) (tr-float y1) vt2 d2 (tr-float x2) (tr-float y2) rnd)))

(defun tr-parse-t (line)
  (destructuring-bind (tick vt1 d1 x1 y1 vt2 d2 x2 y2 rnd) (rest (tr-split line))
    (list (parse-integer tick) (parse-integer vt1) (parse-integer d1 :radix 16) (tr-read-float x1) (tr-read-float y1)
          (parse-integer vt2) (parse-integer d2 :radix 16) (tr-read-float x2) (tr-read-float y2) (parse-integer rnd :radix 16))))

(defun tr-side (tf k) "Side K's (vt downs sx sy) of T fields TF." (subseq tf (+ 1 (* 4 k)) (+ 5 (* 4 k))))
(defun tr-rnd (tf) (nth 9 tf))

(defun tr-read (path)
  "A trace -> (values start items b-names): START the S line's words after S; ITEMS a vector, in order, of (:step sim-log-lines t-fields
h-line b-pos), (:event words e-lines) and (:frame); B-NAMES the header's B field names. B-POS is the file position of the step's B text
(a \"B =\" line: the last full B line's), read back with TR-B-AT."
  (with-open-file (in path)
    (let ((start nil) (log nil) (tf nil) (items (make-array 0 :adjustable t :fill-pointer t)) (names nil) (prev-b nil))
      (loop for pos = (file-position in) for l = (read-line in nil) while l
            do (cond ((zerop (length l)))
                     ((eql 0 (search "# B fields: " l)) (setf names (rest (rest (rest (tr-split l))))))
                     ((member (char l 0) '(#\# #\C #\R)))
                     ((char= (char l 0) #\S) (setf start (rest (tr-split l))))
                     ((char= (char l 0) #\E) (vector-push-extend (list :event (rest (tr-split l)) nil) items))
                     ((char= (char l 0) #\e) (push (subseq l 2) (third (aref items (1- (fill-pointer items))))))
                     ((char= (char l 0) #\F) (vector-push-extend (list :frame) items))
                     ((char= (char l 0) #\[) (push l log))
                     ((char= (char l 0) #\T) (setf tf (tr-parse-t l)))
                     ((char= (char l 0) #\H)
                      (vector-push-extend (list :step (nreverse log) tf (subseq l 2) nil) items)
                      (setf log nil tf nil))
                     ((char= (char l 0) #\B)
                      (unless (string= l "B =") (setf prev-b pos))   ; (a position, not the text: the B lines outgrow the 32-bit host's heap)
                      (setf (fifth (aref items (1- (fill-pointer items)))) prev-b))))
      (loop for it across items when (eq (first it) :event) do (setf (third it) (reverse (third it))))
      (values start items names))))

(defvar *tr-b-stream* nil "(path . stream): TR-B-AT's open trace.")
(defun tr-b-at (path pos)
  "The B line at file position POS of the trace PATH (TR-READ's b-pos), through one stream kept open."
  (unless (equal path (car *tr-b-stream*)) (setf *tr-b-stream* (cons path (open path))))
  (file-position (cdr *tr-b-stream*) pos)
  (read-line (cdr *tr-b-stream*)))

(defun tr-lines (text)
  (with-input-from-string (in text) (loop for l = (read-line in nil) while l collect l)))
(defun tr-log-p (l) "A combat log line (\"[  tick] ...\")?" (and (plusp (length l)) (char= (char l 0) #\[)))
(defun tr-trial-p (l) "trial.lisp's begin / end line?" (or (eql 0 (search "trial begin " l)) (eql 0 (search "trial end " l))))

(defun tr-log-equal (want got)
  "The recorded sim log WANT against a brainless replay's GOT: equal line for line, but a recorded move / step / dash line may end in its
brain's why (fighter.lisp: \" TRIAL\", scripted.lisp's only BRAIN-WHY), which a detached brain cannot print."
  (and (= (length want) (length got))
       (every (lambda (w g) (or (string= w g)
                                (and (> (length w) (length g)) (string= g w :end2 (length g)) (string= (subseq w (length g)) " TRIAL"))))
              want got)))

(defun tr-run-frames (cap)
  "tools/simgate/run.lisp's loop (the queued commands' frame, then frames until the gate or the match is over), the console bound to the
string stream CAP (the hooks drain it). Exits 3 / 4 as run.lisp does."
  (flet ((frame () (let ((*standard-output* cap)) (engine::%frame))))
    (frame)
    (unless (loop repeat 2000000
                  do (unless (frame) (ext:quit 3))
                  thereis (and (null *gate*) (not *gate-busy*) (null *gate-results*) (not (battle-p))))
      (ext:quit 4))))

;;; ---------------------------------------------------------------- the E lines' fields and actions
(defparameter *tr-side-fields*
  '(gauges-awakened gauges-konpaku gauges-sub gauges-sub-s gauges-drive gauges-awaken gauges-meter gauges-fs gauges-burst gauges-burn
    gauges-reishi fighter-xch fighter-xch-done fighter-hoho-lock fighter-ptr fighter-state fighter-guard-t hss-bound hss-bind-arm
    hss-unbind)
  "The per-side fields an E set line may name (every field trial.lisp's TRIAL-RUN sets between frames, besides its actions).")
(defparameter *tr-globals* '(*combat-log* *skip-cines* *timer* sim-rnd-state) "The globals an E set line may name.")

(defun tr-sides () "The live fighters, as (side . entity)." (loop for e in (list *p1* *p2*) for k from 0 when (and e (fighter e)) collect (cons k e)))
(defun tr-entity (k) (if (zerop k) *p1* *p2*))
(defun tr-side-of (e) (cond ((eql e *p1*) 0) ((eql e *p2*) 1) (t (error "trace: ~s is neither fighter" e))))

(defun tr-obj (acc e &optional make)
  "ACC's component of E (HS for hss-*: only Hisagi's, attached when MAKE); NIL if he has none."
  (let ((n (symbol-name acc)))
    (cond ((eql 0 (search "GAUGES-" n)) (gauges e))
          ((eql 0 (search "FIGHTER-" n)) (fighter e))
          ((eql 0 (search "HSS-" n)) (if make (hs e) (hss e)))
          (t (error "trace: no field ~s" acc)))))

(defun tr-fields-now ()
  "Every tracked field now: a list of ((side . name) . value), side - for a global."
  (append (loop for g in *tr-globals* collect (cons (cons '- g) (if (eq g 'sim-rnd-state) (sim-rnd-state) (symbol-value g))))
          (loop for (k . e) in (tr-sides)
                append (loop for acc in *tr-side-fields* for o = (tr-obj acc e) when o collect (cons (cons k acc) (funcall acc o))))))

(defun tr-fields-diff (old new)
  "The fields of NEW whose value is not EQL to OLD's (or that OLD lacks), as E set words."
  (loop for ((k . name) . v) in new
        for was = (assoc (cons k name) old :test #'equal)
        unless (and was (eql (cdr was) v)) collect (list "set" (if (eq k '-) "-" (princ-to-string k)) (tr-print name) (tr-print v))))

(defun tr-move-key (e mv)
  "The key of MV in E's kit's KIT-MOVES."
  (maphash (lambda (k v) (when (eq v mv) (return-from tr-move-key k))) (kit-moves (kit-of e)))
  (error "trace: ~s is not a move of ~s's kit" mv (fighter-character (fighter e))))

(defun tr-apply-event (words)
  "Apply one E line's WORDS (TR-READ's), as the grammar in the header says."
  (let ((a (first words)) (args (mapcar #'tr-value (rest words))))
    (flet ((side (i) (tr-entity (nth i args))))
      (cond ((string= a "set")
             (let ((name (second args)) (v (third args)))
               (if (eq (first args) '-)
                   (if (eq name 'sim-rnd-state) (setf (sim-rnd-state) v) (setf (symbol-value name) v))
                   (eval `(setf (,name ',(tr-obj name (side 0) t)) ',v)))))
            ((string= a "battle") (ensure-battle (first args) (second args) :cpu t))
            ((string= a "form") (force-form (side 0) (second args)))
            ((string= a "hisagi-reset") (hs-reset (side 0)))
            ((string= a "place") (place *p1* *p2* (first args)))
            ((string= a "vpad-clear") (vpad-clear! (pilot-vpad (pilot (side 0)))))
            ((string= a "clear-hazards") (clear-hazards))
            ((string= a "skip-cine") (skip-cine))
            ((string= a "burst-end") (burst-end! (side 0)))
            ((string= a "full-gauges") (full-gauges! (side 0) (second args)))
            ((string= a "cmd") (debug-command (first args)))
            ((string= a "core-start") (let ((e (side 0))) (core-start! e (gethash (second args) (kit-moves (kit-of e))))))
            (t (error "trace: unknown event ~s" words))))))

;;; ---------------------------------------------------------------- the B line: the sim state's raw bits (M1 Task 1)
(defun tr-f32-bits (x)
  "X's IEEE bits as an integer: 32 for a single-float, 64 for a double-float (INTEGER-DECODE-FLOAT, no FFI; ECL hands back a subnormal's
mantissa normalized, so it is renormalized here). A NaN or an infinity is an error."
  (when (or (ext:float-nan-p x) (ext:float-infinity-p x)) (error "trace: ~s is not finite" x))
  (multiple-value-bind (p bias w) (if (typep x 'double-float) (values 53 1075 64) (values 24 150 32))
    (multiple-value-bind (m e s) (integer-decode-float x)
      (let ((sign (if (minusp s) (ash 1 (1- w)) 0)))
        (if (zerop m)
            sign
            (let* ((n (integer-length m)) (m (ash m (- p n))) (biased (+ e (- n p) bias)))
              (logior sign (if (<= biased 0)
                               (ash m (1- biased))
                               (logior (ash biased (1- p)) (- m (ash 1 (1- p))))))))))))

(defun tr-bits-selftest ()
  "TR-F32-BITS on known values (record.lisp / replay.lisp exit 2 when it fails)."
  (every (lambda (c) (= (tr-f32-bits (car c)) (cdr c)))
         (list (cons 1.0f0 #x3F800000) (cons -0.0f0 #x80000000) (cons 0.1f0 #x3DCCCCCD) (cons least-positive-single-float #x00000001)
               (cons 1.0d0 #x3FF0000000000000))))

(defun tr-b-enc (v s &optional (depth 0))
  "Write one B value to stream S (no spaces): single-float 8 hex digits of its bits, double-float 16, integer decimal, a symbol PRIN1
(keywords :NAME, T / NIL), a string PRIN1 (spaces as _), a MOVE #m:NAME, a KIT #k:CHARACTER/FORM, another struct #TYPE{slot,...} (its slots in order), a list
(a,b,...), a vector [a,b,...], a function #FN, a hash table #HASH:<count>, anything else #<TYPE>; nesting below depth 4 is #...."
  (cond ((typep v 'single-float) (format s "~8,'0X" (tr-f32-bits v)))
        ((typep v 'double-float) (format s "~16,'0X" (tr-f32-bits v)))
        ((integerp v) (format s "~d" v))
        ((symbolp v) (write-string (tr-print v) s))
        ((stringp v) (write-string (substitute #\_ #\Space (tr-print v)) s))
        ((> depth 3) (write-string "#..." s))
        ((typep v 'move) (write-string "#m:" s) (write-string (tr-print (mv-name v)) s))
        ((typep v 'kit) (format s "#k:~a/~a" (tr-print (kit-character v)) (tr-print (kit-form v))))
        ((typep v 'structure-object)
         (format s "#~a{" (tr-print (type-of v)))
         (loop for sd in (clos:class-slots (class-of v)) for first = t then nil
               do (unless first (write-char #\, s)) (tr-b-enc (slot-value v (clos:slot-definition-name sd)) s (1+ depth)))
         (write-char #\} s))
        ((consp v)
         (write-char #\( s)
         (loop for (x . rest) on v for first = t then nil
               do (unless first (write-char #\, s)) (tr-b-enc x s (1+ depth))
                  (unless (listp rest) (write-string ",." s) (tr-b-enc rest s (1+ depth))))
         (write-char #\) s))
        ((vectorp v)
         (write-char #\[ s)
         (loop for x across v for first = t then nil do (unless first (write-char #\, s)) (tr-b-enc x s (1+ depth)))
         (write-char #\] s))
        ((functionp v) (write-string "#FN" s))
        ((hash-table-p v) (format s "#HASH:~d" (hash-table-count v)))
        (t (format s "#~a" (substitute #\_ #\Space (tr-print (type-of v)))))))

(defun tr-b-value (v) "One B field as a string (TR-B-ENC)." (with-output-to-string (s) (tr-b-enc v s)))

(defun tr-src (file) (merge-pathnames (concatenate 'string "../../../duel/lisp/" file) (directory-namestring *load-truename*)))
(defparameter *tr-sources* (list (cons 'fighter (tr-src "components.lisp")) (cons 'gauges (tr-src "components.lisp"))
                                 (cons 'hazard (tr-src "components.lisp")) (cons 'ics (tr-src "ichigo.lisp"))
                                 (cons 'hss (tr-src "hisagi.lisp")) (cons 'yss (tr-src "yama.lisp")))
  "Where each component the B line covers is defined.")

(defun tr-slots (component &optional type)
  "The slot names of (DEFCOMPONENT COMPONENT ...) in its source (*TR-SOURCES*), in slot order; only those whose :TYPE is TYPE if given."
  (let ((file (cdr (assoc component *tr-sources*))))
    (with-open-file (in file)
      (let ((*package* (find-package :duel)) (*read-eval* nil) (*read-default-float-format* 'single-float))
        (loop for form = (read in nil in) until (eq form in)
              when (and (consp form) (eq (first form) 'defcomponent) (eq (second form) component))
                return (loop for s in (cddr form)
                             when (and (not (stringp s)) (or (null type) (and (consp s) (equal (getf (cddr s) :type) type))))
                               collect (if (consp s) (first s) s))
              finally (error "trace: no (defcomponent ~s) in ~a" component file))))))

(defun tr-acc (component slot)
  "(e) -> SLOT of E's COMPONENT, or :ABSENT when E has none."
  (let ((get (fdefinition component)) (acc (fdefinition (intern (format nil "~a-~a" component slot) :duel))))
    (lambda (e) (let ((c (funcall get e))) (if c (funcall acc c) :absent)))))

(defparameter *tr-b-globals*
  (append (list (cons "*timer*" (lambda () *timer*)) (cons "*hitstop*" (lambda () *hitstop*)) (cons "*slow-acc*" (lambda () *slow-acc*)))
          (loop for i below (length engine::*slowmo*) collect (let ((i i)) (cons (format nil "*slowmo*[~d]" i) (lambda () (aref engine::*slowmo* i)))))
          (list (cons "*flow*" (lambda () *flow*)) (cons "cine-cf" (lambda () (if *cine* (cine-cf *cine*) -1)))))
  "The B line's globals: (name . thunk).")

(defparameter *tr-b-side*
  (flet ((slots (c) (loop for s in (tr-slots c) collect (cons (string-downcase (format nil "~a-~a" c s)) (tr-acc c s)))))
    (append (loop for i below 3 for n in '("x" "y" "z") collect (let ((i i)) (cons (format nil "pos-~a" n) (lambda (e) (aref (pos-of e) i)))))
            (list (cons "yaw" #'yaw-of))
            (loop for i below 3 for n in '("x" "y" "z") collect (let ((i i)) (cons (format nil "motion-vel-~a" n) (lambda (e) (aref (motion-vel (motion e)) i)))))
            (loop for i below 3 for n in '("x" "y" "z") collect (let ((i i)) (cons (format nil "motion-kb-~a" n) (lambda (e) (aref (motion-kb (motion e)) i)))))
            (list (cons "motion-kb-left" (tr-acc 'motion 'kb-left)) (cons "motion-grounded" (tr-acc 'motion 'grounded)))
            (slots 'fighter) (slots 'gauges) (slots 'ics) (slots 'hss) (slots 'yss)))
  "The B line's per-side fields: (name . (lambda (entity))), names qualified by component: pos / motion, then every slot of FIGHTER,
GAUGES and the kit components ICS (Ichigo), HSS (Hisagi), YSS (Yamamoto) in slot order; a kit component the fighter lacks is :ABSENT.")

(defparameter *tr-b-hazard*
  (loop for s in (tr-slots 'hazard)
        collect (cons (string-downcase (symbol-name s))
                      (if (eq s 'owner)
                          (lambda (hz) (let ((o (hazard-owner hz))) (cond ((null o) nil) ((eql o *p1*) :p1) ((eql o *p2*) :p2) (t o))))
                          (fdefinition (intern (format nil "HAZARD-~a" s) :duel)))))
  "The B line's per-hazard fields (after the |): every HAZARD slot; OWNER as :P1 / :P2 (the fighter's side), else its handle or NIL.")

(defun tr-b-names ()
  "The B fields' names, as the trace header's \"# B fields:\" line lists them: the globals, p1.*, p2.*, |, then one hazard's."
  (append (mapcar #'car *tr-b-globals*)
          (loop for p in '("p1" "p2") append (loop for f in *tr-b-side* collect (format nil "~a.~a" p (car f))))
          (list "|") (mapcar #'car *tr-b-hazard*)))

(defun tr-b-line ()
  "The B line now (\"B ...\", full: the recorder writes \"B =\" for a repeat)."
  (with-output-to-string (s)
    (write-string "B" s)
    (dolist (f *tr-b-globals*) (write-char #\Space s) (tr-b-enc (funcall (cdr f)) s))
    (dolist (e (list *p1* *p2*)) (dolist (f *tr-b-side*) (write-char #\Space s) (tr-b-enc (funcall (cdr f) e) s)))
    (write-string " |" s)
    (do-entities (h (hz hazard))
      (dolist (f *tr-b-hazard*) (write-char #\Space s) (tr-b-enc (funcall (cdr f) hz) s)))))

(defun tr-b-diff (names want got)
  "The first field where the B lines WANT and GOT differ, named through the header's NAMES, or NIL if equal."
  (let* ((w (rest (tr-split want))) (g (rest (tr-split got))) (fixed (position "|" names :test #'string=))
         (nh (- (length names) fixed 1)) (i (mismatch w g :test #'string=)))
    (when i
      (flet ((name (i) (if (<= i fixed) (nth i names)
                           (multiple-value-bind (h j) (floor (- i fixed 1) nh) (format nil "hz~d.~a" h (nth (+ fixed 1 j) names)))))
             (at (l) (or (nth i l) "<none>")))
        (format nil "B field ~a: want ~a got ~a" (name i) (at w) (at g))))))
