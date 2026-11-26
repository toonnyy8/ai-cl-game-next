;;;; extract.lisp — the Bevy port's data extractor (docs/bevy/plans/2026-11-26-m0-extractor-oracle.md Tasks 4-5): the frozen game's
;;;; data as JSON, read from the native image after every :load step (never retyped, never from MV-SPEC: a derived form's spec holds
;;;; the base numbers).
;;;;   env LD_PRELOAD=$PWD/build/simgate/muslm.so $ECL_HOST --norc --load tools/port/extract/extract.lisp -- build/simgate/duel.fas MODE [OUT-DIR]
;;;; (musl, the game's libm, is required: weapon meshes and colours call sin / cos / pow; the run exits 1 without it.)
;;;; MODE: moves | kits (that file only) | all (every file: moves kits clips poses rig bodies glyphs debug_ranges tables tuning weapons,
;;;; the hud-font copies, then every file read back for the shape rule and the float checksum, then manifest.json) | census (exit 1
;;;; unless each file holds what the image holds: every MOVE once by identity, the registries' counts, the tuning names = the source
;;;; DEFPARAMETERs, the manifest's counts and checksum).
;;;; OUT-DIR defaults to rs/duel-data/data. The image comes from simlib.build() (tools/simlib.py).
;;;; Move ids: "<char>/<form>/<name>[#n]" for a MOVE in a kit's KIT-MOVES (kits in sorted order; a shared object is claimed by the form
;;;; that defines it, KIT-INHERIT followed up, else the first kit); a MOVE only in a variable: "var/<variable>/<name>#<index>" (index =
;;;; the vector position; in a hash table, the rank among same-name objects sorted by their JSON). Hook / code fields are written as
;;;; symbol names (the JSON writer's rule).
(load (merge-pathnames "../../simgate/prelude.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "json.lisp" (directory-namestring *load-truename*)) :verbose nil)
(load (merge-pathnames "defparams.lisp" (directory-namestring *load-truename*)) :verbose nil)
(in-package :duel)

(defparameter *x-root* (truename (merge-pathnames "../../../" (directory-namestring *load-truename*))))
(defparameter *x-mode* (or (second cl-user::*sg-args*) "all"))
(defparameter *x-out* (if (third cl-user::*sg-args*)
                          (pathname (concatenate 'string (string-right-trim "/" (third cl-user::*sg-args*)) "/"))
                          (merge-pathnames "rs/duel-data/data/" *x-root*)))
(cl-user::sg-init)                                      ; every :load step, as the page starts (the state a match starts from)
(unless (with-open-file (in "/proc/self/maps") (loop for l = (read-line in nil) while l thereis (search "muslm.so" l)))
  (format t "extract: musl libm not loaded: run under env LD_PRELOAD=<repo>/build/simgate/muslm.so (the game's libm; weapon meshes and ~
             colours call sin / cos / pow)~%")
  (finish-output)
  (ext:quit 1))

;;; ---------------------------------------------------------------- helpers
(defun x-key (k) (cl-user::json-key k))
(defun x-json (x) (with-output-to-string (s) (cl-user::extract-json x s)))
(defun x-sorted-kits ()
  "((char form kit) ...) sorted by char then form name."
  (let ((rows nil))
    (maphash (lambda (c forms) (dolist (cf forms) (push (list c (car cf) (cdr cf)) rows))) *kits*)
    (sort rows (lambda (a b) (let ((ca (x-key (first a))) (cb (x-key (first b))))
                               (or (string< ca cb) (and (string= ca cb) (string< (x-key (second a)) (x-key (second b))))))))))
(defun x-slot-names (type) (mapcar #'clos:slot-definition-name (clos:class-slots (find-class type))))
(defun x-json-name (slot) (if (eq slot 'clip-2) "clip2" (substitute #\_ #\- (string-downcase (symbol-name slot)))))

;;; Code fields: every non-keyword symbol written, by field path (the report's list of names to port by hand).
(defvar *x-syms* (make-hash-table :test 'equal) "field path -> list of symbol names written there.")
(defun x-note-syms (x path)
  (cond ((and x (symbolp x) (not (keywordp x)) (not (eq x t))) (pushnew (symbol-name x) (gethash path *x-syms*) :test #'string=))
        ((consp x) (x-note-syms (car x) path) (when (listp (cdr x)) (x-note-syms (cdr x) path)))
        ((and (vectorp x) (not (stringp x)) (eq (array-element-type x) t)) (loop for y across x do (x-note-syms y path)))))
(defun x-note-plist (plist path)
  (loop for (k v) on plist by #'cddr do (x-note-syms v (format nil "~a.~a" path (x-key k)))))

;;; ---------------------------------------------------------------- the data files (Task 5)
(defparameter *x-files* '("bodies.json" "clips.json" "debug_ranges.json" "glyphs.json" "kits.json" "moves.json" "poses.json" "rig.json"
                          "tables.json" "tuning.json" "weapons.json")
  "Every data file, sorted by name: the float checksum's order (manifest.json is not one).")
(defparameter *x-collapse* '(("moves.json" 0) ("kits.json" 1 2) ("clips.json" 0) ("poses.json" 0) ("bodies.json" 0) ("weapons.json" 0)
                             ("glyphs.json" 0) ("debug_ranges.json" 0) ("tables.json" 1))
  "The shape rule's entry levels per file (JSON-SHAPE-CONFLICTS): depths whose key / index is an entry name, written '*' (tables.json:
the entries of each table; tuning.json none: its values are unrelated).")
(defparameter *x-copies* '("hud-font/atlas.r8" "hud-font/metrics.bin") "Files copied byte for byte from duel/ (the HUD's baked SDF atlas).")
(defun x-bytes (path)
  (with-open-file (in path :element-type '(unsigned-byte 8))
    (let ((v (make-array (file-length in) :element-type '(unsigned-byte 8)))) (read-sequence v in) v)))
(defun x-copy-hud-font ()
  (dolist (f *x-copies*)
    (let ((to (merge-pathnames f *x-out*)))
      (ensure-directories-exist to)
      (with-open-file (out to :direction :output :if-exists :supersede :element-type '(unsigned-byte 8))
        (write-sequence (x-bytes (merge-pathnames (concatenate 'string "duel/" f) *x-root*)) out))
      (format t "copied ~a~%" (namestring to)))))
(defun x-collapse (file) (cdr (assoc file *x-collapse* :test #'string=)))
(defparameter *x-defparams* (let ((*default-pathname-defaults* *x-root*)) (cl-user::source-defparameters '("engine" "duel")))
  "Every source DEFPARAMETER name of the engine and the game, MANIFEST order.")
(defun x-count (file tree)
  "The manifest's count of FILE (a JSON-READ tree): kits.json its forms, rig.json its joints, any other its top-level entries."
  (flet ((get (k o) (cdr (assoc k (cdr o) :test #'equal))))
    (cond ((string= file "kits.json") (loop for (nil . forms) in (cdr (get "kits" tree)) sum (length (cdr forms))))
          ((string= file "rig.json") (length (cdr (get "joints" tree))))
          (t (length (cdr tree))))))
(defun x-checksum (tree-of)
  "The float checksum over every data file (TREE-OF: file name -> its JSON-READ tree), in *X-FILES* order, as 16 hex digits."
  (let ((h cl-user::+fnv-basis+))
    (dolist (f *x-files*) (setf h (cl-user::json-tree-fnv h (funcall tree-of f))))
    (format nil "~(~16,'0x~)" h)))

;;; ---------------------------------------------------------------- move ids
(defvar *x-ids* (make-hash-table :test 'eq) "MOVE -> id.")
(defvar *x-id-owner* (make-hash-table :test 'equal) "id -> MOVE.")
(defvar *x-kit-collisions* 0 "Two objects under one name in one kit's table (never expected: a hash table).")
(defun x-claim (mv id)
  (unless (gethash mv *x-ids*)
    (let ((final (loop for n from 0 for try = (if (zerop n) id (format nil "~a#~d" id n))
                       unless (gethash try *x-id-owner*) return try)))
      (unless (string= final id) (incf *x-kit-collisions*))
      (setf (gethash mv *x-ids*) final (gethash final *x-id-owner*) mv))))
(defun x-claim-var (var objs)
  "Claim ids for OBJS ((index . MOVE) ...) from variable VAR not claimed yet."
  (loop for (i . mv) in objs
        unless (gethash mv *x-ids*)
          do (setf (gethash mv *x-ids*) (format nil "var/~a/~a#~d" (string-downcase (string-trim "*" (symbol-name var))) (x-key (mv-name mv)) i))
             (when (gethash (gethash mv *x-ids*) *x-id-owner*) (error "id clash ~a" (gethash mv *x-ids*)))
             (setf (gethash (gethash mv *x-ids*) *x-id-owner*) mv)))
(defun x-rank-by-content (objs)
  "OBJS (MOVEs from a hash table, not yet claimed) as ((rank . MOVE) ...): rank among same-name objects sorted by their JSON."
  (let* ((objs (remove-duplicates (remove-if (lambda (m) (gethash m *x-ids*)) objs)))
         (keyed (sort (mapcar (lambda (m) (list (x-key (mv-name m)) (x-json (x-move-object m)) m)) objs)
                      (lambda (a b) (or (string< (first a) (first b)) (and (string= (first a) (first b)) (string< (second a) (second b))))))))
    (loop with last = nil with n = 0 for (name nil m) in keyed
          do (setf n (if (equal name last) (1+ n) 0) last name)
          collect (cons n m))))
(defun x-vector-objs (v)
  "((position . MOVE) ...) of a vector of MOVEs or of lists of MOVEs (*YA-REACH-COPIES*: one list per level)."
  (loop for x across v for i from 0 append (if (listp x) (mapcar (lambda (m) (cons i m)) x) (list (cons i x)))))
(defvar *x-inherited-claims* 0 "Ids claimed under an ancestor form instead of the sorted-first form that holds the object (ruling 3).")
(defun x-defining-form (c kit n mv)
  "The form that defines MV under name N for KIT: the furthest ancestor (KIT-INHERIT, followed up) whose table holds the same object."
  (loop for k = kit then p
        for p = (and (kit-inherit k) (cdr (assoc (kit-inherit k) (gethash c *kits*))))
        while (and p (eq (gethash n (kit-moves p)) mv))
        finally (return (kit-form k))))
(defun x-assign-ids ()
  (loop for (c f kit) in (x-sorted-kits)
        do (let ((names nil))
             (maphash (lambda (n mv) (unless (eq n (mv-name mv)) (error "kit ~s ~s: key ~s holds move ~s" c f n (mv-name mv))) (push n names)) (kit-moves kit))
             (dolist (n (sort names #'string< :key #'x-key))
               (let* ((mv (gethash n (kit-moves kit))) (owner (x-defining-form c kit n mv)))
                 (when (and (not (gethash mv *x-ids*)) (not (eq owner f))) (incf *x-inherited-claims*))
                 (x-claim mv (format nil "~a/~a/~a" (x-key c) (x-key owner) (x-key n)))))))
  (x-claim-var '*moves* (x-rank-by-content (loop for m being the hash-values of *moves* collect m)))
  (x-claim-var '*cadence-moves* (x-rank-by-content (loop for k being the hash-keys of *cadence-moves* using (hash-value m)
                                                          collect (car k) collect m)))
  (x-claim-var '*ya-reach-copies* (x-vector-objs *ya-reach-copies*))
  (x-claim-var '*ya-garb-copies* (x-vector-objs *ya-garb-copies*))
  (x-claim-var '*hs-k1-scaled* (x-vector-objs *hs-k1-scaled*))
  (loop for (c f kit) in (x-sorted-kits)
        do (maphash (lambda (mv cls) (declare (ignore cls)) (unless (gethash mv *x-ids*) (error "kit ~s ~s classes an unclaimed move ~s" c f (mv-name mv))))
                    (kit-cls kit))))

;;; ---------------------------------------------------------------- dumps
(defparameter *x-move-objects* '(params) "Move slots written as a JSON object (a plist; NIL -> {}).")
(defparameter *x-kit-objects* '(hooks commands core clip-map look-clips meter) "Kit slots written as a JSON object.")
(defparameter *x-skip* '(spec) "Slots never written: the DEFMOVE / DEFKIT plist (a derived form's holds the base numbers).")
(defun x-shape (v objectp)
  "A slot value as written: a plist slot -> an object; any other list -> an array (NIL -> [] only for the list slots the caller
names; a scalar slot's NIL stays null)."
  (cond (objectp (cl-user::json-object v))
        ((consp v) (cl-user::json-array v))
        (t v)))
(defparameter *x-move-lists* '(hits flags on-frame) "Move slots that are lists: NIL -> [].")
(defparameter *x-hw-lists* '(vols flags))
(defparameter *x-kit-lists* '(strings passives hide enter-clips run-clips))

(defun x-hitwin-object (hw)
  (cl-user::json-object
   (loop for slot in (x-slot-names 'hitwin)
        for v = (slot-value hw slot)
        do (x-note-syms v (format nil "move.hits.~a" (x-json-name slot)))
        collect (x-json-name slot)
        collect (if (member slot *x-hw-lists*) (cl-user::json-array (coerce v 'list)) (x-shape v nil)))))
(defun x-move-object (mv)
  "MV as a JSON object (a forced plist with string keys), its id included when it has one."
  (cl-user::json-object
   (append
    (let ((id (gethash mv *x-ids*))) (and id (list "id" id)))
    (loop for slot in (x-slot-names 'move)
          for v = (slot-value mv slot)
          for key = (x-json-name slot)
          unless (member slot *x-skip*)
            do (if (eq slot 'params) (x-note-plist v "move.params") (unless (eq slot 'hits) (x-note-syms v (format nil "move.~a" key))))
            and collect key
            and collect (cond ((eq slot 'hits) (cl-user::json-array (map 'list #'x-hitwin-object v)))
                              ((member slot *x-move-lists*) (cl-user::json-array v))
                              (t (x-shape v (member slot *x-move-objects*))))))))
(defun x-kit-object (kit)
  (cl-user::json-object
   (loop for slot in (x-slot-names 'kit)
         for v = (slot-value kit slot)
         for key = (x-json-name slot)
         unless (member slot *x-skip*)
           collect key
           and collect (case slot
                         (cls (cl-user::json-object (loop for mv being the hash-keys of v using (hash-value c)
                                                          collect (gethash mv *x-ids*) collect c)))
                         (moves (cl-user::json-array (sort (loop for mv being the hash-values of v collect (gethash mv *x-ids*)) #'string<)))
                         (sp v)
                         (t (if (member slot *x-kit-objects*) (x-note-plist v (format nil "kit.~a" key)) (x-note-syms v (format nil "kit.~a" key)))
                            (cond ((member slot *x-kit-lists*) (cl-user::json-array v))
                                  ((and (member slot '(l-after-k l-after-j)) (consp v)) (cl-user::json-object v))
                                  (t (x-shape v (member slot *x-kit-objects*)))))))))

(defun x-other (x)
  (cond ((move-p x) (or (gethash x *x-ids*) (error "unclaimed move ~s in data" (mv-name x))))
        ((hitwin-p x) (x-hitwin-object x))                    ; (*PERFECT-HW*, a standalone hitwin: ruling 2)
        (t nil)))

(defvar *x-write-hash* (make-hash-table :test 'equal) "File -> the float hash of what the writer wrote (checked against the file read back).")
(defun x-write (name fn)
  (let ((path (merge-pathnames name *x-out*)) (cl-user::*json-float-hash* cl-user::+fnv-basis+))
    (ensure-directories-exist path)
    (with-open-file (out path :direction :output :if-exists :supersede :external-format :utf-8)
      (funcall fn out))
    (setf (gethash name *x-write-hash*) cl-user::*json-float-hash*)
    (format t "wrote ~a~%" (namestring path))))
(defun x-write-entries (name pairs &optional array)
  "NAME as one JSON object of PAIRS ((key-string . value) ...) sorted by key (ARRAY: a JSON array of PAIRS, values in order), one entry
a line. -> the entry count."
  (unless array
    (setf pairs (sort (copy-list pairs) #'string< :key #'car))
    (loop for (a b) on pairs when (and b (string= (car a) (car b))) do (error "~a: key ~a twice" name (car a))))
  (x-write name (lambda (out)
                  (write-line (if array "[" "{") out)
                  (loop for (e . more) on pairs
                        do (if array
                               (cl-user::extract-json e out)
                               (progn (cl-user::json-write-string (car e) out) (write-char #\: out) (cl-user::extract-json (cdr e) out)))
                           (write-line (if more "," "") out))
                  (write-line (if array "]" "}") out)))
  (length pairs))

(defun x-write-moves ()
  (let ((ids (sort (loop for id being the hash-keys of *x-id-owner* collect id) #'string<)))
    (x-write "moves.json"
             (lambda (out)
               (write-line "[" out)
               (loop for (id . more) on ids
                     do (cl-user::extract-json (x-move-object (gethash id *x-id-owner*)) out)
                        (write-line (if more "," "") out))
               (write-line "]" out)))
    (format t "moves ~d~%" (length ids))))

(defun x-write-kits ()
  (let ((tree (make-hash-table :test 'equal)))
    (loop for (c f kit) in (x-sorted-kits)
          do (let ((forms (or (gethash (x-key c) tree) (setf (gethash (x-key c) tree) (make-hash-table :test 'equal)))))
               (setf (gethash (x-key f) forms) (x-kit-object kit))))
    (x-write "kits.json"
             (lambda (out)
               (cl-user::extract-json (cl-user::json-object (list "kits" tree "roster" (cl-user::json-array *roster*)
                                                                  "retired" (cl-user::json-array *retired*)))
                                      out)
               (terpri out)))))

;;; ---------------------------------------------------------------- Task 5's dumps
(defun x-arr (x)
  "X with every list (deep) a forced array, a dotted tail its last element: a positional grammar (body shapes, palettes, glyph
polygons), never the plist guess (a shape (:sphere 0.1 :c :skin) would pass for a plist)."
  (if (consp x)
      (cl-user::json-array (mapcar #'x-arr (if (null (cdr (last x))) x (append (butlast x 0) (list (cdr (last x)))))))
      x))
(defun x-name-pairs (table fn)
  "((json-key . (FN value)) ...) of the hash TABLE."
  (loop for k being the hash-keys of table using (hash-value v) collect (cons (x-key k) (funcall fn v))))

(defun x-clip-object (c)
  (let ((n (engine::clip-n c)) (poses (engine::clip-poses c)))
    (assert (= (length poses) (* n engine::+pose-n+)))
    (cl-user::json-object
     (list "dur" (engine::clip-dur c) "loop" (engine::clip-loop c) "times" (engine::clip-times c) "snaps" (engine::clip-snaps c)
           "poses" (cl-user::json-array (loop for k below n collect (subseq poses (* k engine::+pose-n+) (* (1+ k) engine::+pose-n+))))
           "marks" (cl-user::json-object (engine::clip-marks c))))))

(defun x-rig ()
  "*RIG* as the game reads it: offset = *RIG-OFF* (engine coords: x = r, y = u, z = -f), flex sign and mirror as the f32 tables."
  (cl-user::json-object
   (list "joints" (cl-user::json-array
                   (loop for (name parent) in engine::*rig* for j from 0
                         collect (cl-user::json-object
                                  (list "name" name "parent" parent "offset" (subseq engine::*rig-off* (* 3 j) (+ 3 (* 3 j)))
                                        "flex_sign" (aref engine::*rig-fsign* j) "mirror" (aref engine::*rig-mirror* j)))))
         "aliases" (cl-user::json-object (loop for (a . js) in engine::*joint-alias* append (list a (cl-user::json-array js))))
         "mirror_pairs" (cl-user::json-array (loop for (r . l) in engine::*mirror-pairs* collect (cl-user::json-array (list r l))))
         "key_ease" engine::*key-ease*)))

(defun x-body-object (b)
  "Every BODY slot but its name (the key) and the mesh handles PARTS / EXTRAS / HULLS (stubs in the native image)."
  (cl-user::json-object
   (list "scale" (body-scale b) "width" (body-width b) "hunch" (body-hunch b) "hurt_r" (body-hurt-r b) "hurt_h" (body-hurt-h b)
         "palette" (x-arr (body-palette b)) "spec" (x-arr (body-spec b)) "rim" (body-rim b) "props" (body-props b)
         "girth" (x-arr (body-girth b)) "clips" (cl-user::json-object (body-clips b)) "ink" (x-arr (body-ink b)))))

(defun x-section-verts (fn glow)
  "Weapon section FN run on a fresh mesh builder (a :GLOW one first coloured white, as BUILD-WEAPON's BUILD-MESH does): its vertices,
9 floats each (position, normal, colour), read from MB-DATA before any MB-BUILD."
  (let ((mb (make-mesh-builder)))
    (when glow (mb-color mb 1 1 1))
    (funcall fn mb)
    (let ((d (engine::mb-data mb)) (n (engine::mb-fill mb)))
      (assert (zerop (mod n 9)))
      (cl-user::json-array (loop for i from 0 below n by 9 collect (subseq d i (+ i 9)))))))
(defun x-weapon-object (w)
  (cl-user::json-object
   (list "len" (weapon-len w) "base" (weapon-base w)
         "sections" (cl-user::json-array
                     (loop for s in (weapon-sections w)
                           collect (if (eq (first s) :solid)
                                       (destructuring-bind (ink fn &optional ink-color) (rest s)
                                         (cl-user::json-object (list "kind" "solid" "ink" ink "ink_color" ink-color "verts" (x-section-verts fn nil))))
                                       (destructuring-bind (e hex fn) (rest s)
                                         (cl-user::json-object (list "kind" "glow" "emissive" e "color" hex "verts" (x-section-verts fn t))))))))))

(defun x-glyphs ()
  (loop for (code adv . polys) in *glyph-outlines* collect (cl-user::json-array (list code adv (x-arr polys)))))

(defun x-debug-ranges ()
  (mapcar (lambda (r) (cl-user::json-array (list (first r) (second r) (and (third r) (symbol-name (third r))))))
          (sort (copy-list engine::*debug-ranges*) (lambda (a b) (or (< (first a) (first b)) (and (= (first a) (first b)) (< (second a) (second b))))))))

(defparameter *x-tables*
  '(("stage_ruins" . *stage-ruins*) ("plaza_cracks" . *plaza-cracks*) ("stamp_kinds" . *stamp-kinds*)
    ("fz_sets" . *fz-sets*) ("fz_skill" . *fz-skill*) ("fz_as_now" . *fz-as-now*) ("fz_ns_turn" . *fz-ns-turn*) ("fz_ns_cont" . *fz-ns-cont*)
    ("fz_kikon" . *fz-kikon*) ("fz_hoho" . *fz-hoho*) ("fz_cancel" . *fz-cancel*) ("fz_burst" . *fz-burst*)
    ("strat_bias_keys" . *strat-bias-keys*) ("strat_styles" . *strat-styles*) ("strat_data" . *strat-data*) ("strat_units" . *strat-units*)
    ("strat_rule_bases" . *strat-rule-bases*) ("strat_units_expanded" . *strat-units-expanded*) ("strat_library" . *strat-library*)
    ("strat_payoff" . *strat-payoff*) ("strat_lookup" . *strat-lookup*)
    ("lhud_fighters" . *lhud-fighters*) ("lhud_moves" . *lhud-moves*) ("commands" . *commands*) ("vpad_actions" . *vpad-actions*))
  "tables.json: name -> the variable (its value after load: *STRAT-LIBRARY* expanded, with its :FQ Q tables).")
(defun x-strat-unit-p (x)
  (and (consp x) (eq (car x) :id) (null (cdr (last x))) (evenp (length x)) (loop for (k) on x by #'cddr always (keywordp k))))
(defun x-strat (x)
  "A strategy table's value with its plists as objects (strategy.lisp reads them with GETF): the writer's guess applied all the way
down, except that a unit (a plist keyed :ID first) is an object even when every element is a keyword ((:id :st-generic)), and a unit's
:BASE is an object even when a key repeats (the first wins, as GETF: a composed :BASE lists its data units' keys before its own)."
  (cond ((x-strat-unit-p x)
         (cl-user::json-object (loop for (k v) on x by #'cddr
                                     append (list k (case k (:base (cl-user::json-object v)) ((:apply :data) (cl-user::json-array v)) (t (x-strat v)))))))
        ((cl-user::json-plist-p x) (cl-user::json-object (loop for (k v) on x by #'cddr append (list k (x-strat v)))))
        ((and (consp x) (null (cdr (last x))) (some #'consp x)) (cl-user::json-array (mapcar #'x-strat x)))
        (t x)))
(defun x-table-value (var)
  "VAR's value as tables.json (and tuning.json, for the same variable) writes it."
  (if (string= (symbol-name var) "*STRAT-" :end1 (min 7 (length (symbol-name var)))) (x-strat (symbol-value var)) (symbol-value var)))
(defun x-tables ()
  (loop for (name . var) in *x-tables*
        do (x-note-syms (symbol-value var) (format nil "tables.~a" name))
        collect (cons name (x-table-value var))))

(defun x-tuning-reason (v)
  "NIL when V can be written, else why not: \"function\" or \"move\" (one inside it), or \"unprintable\" (a cycle, an object the writer
can't write, or an error writing it)."
  (let ((on (make-hash-table :test 'eq)) (reason nil))
    (labels ((walk (x)
               (cond (reason)
                     ((functionp x) (setf reason "function"))
                     ((move-p x) (setf reason "move"))
                     ((consp x)
                      (loop for tail = x then (cdr tail)
                            while (consp tail)
                            do (when (gethash tail on) (setf reason "unprintable") (return))
                               (setf (gethash tail on) t)
                               (walk (car tail))
                            finally (walk tail))
                      (loop for tail = x then (cdr tail) while (and (consp tail) (gethash tail on)) do (remhash tail on)))
                     ((or (hash-table-p x) (and (vectorp x) (not (stringp x)) (eq (array-element-type x) t)))
                      (if (gethash x on) (setf reason "unprintable")
                          (progn (setf (gethash x on) t)
                                 (if (hash-table-p x) (maphash (lambda (k v) (walk k) (walk v)) x) (map nil #'walk x))
                                 (remhash x on)))))))
      (walk v))
    (or reason
        (let ((cl-user::*json-unserialisable* nil))
          (handler-case (progn (x-json v) (and cl-user::*json-unserialisable* "unprintable"))
            (error () "unprintable"))))))
(defvar *x-skipped* nil "(name . why) of every tuning entry written as skipped.")
(defun x-tuning ()
  (loop for sym in *x-defparams*
        for v = (symbol-value sym)
        for why = (x-tuning-reason v)
        do (if why (push (cons (symbol-name sym) why) *x-skipped*) (x-note-syms v (format nil "tuning.~a" (symbol-name sym))))
        collect (cons (symbol-name sym) (cond (why (cl-user::json-object (list "kind" "skipped" "why" why)))
                                              ((rassoc sym *x-tables*) (x-table-value sym))
                                              (t v)))))

(defun x-write-rest ()
  "Task 5's files (weapons last: their section lambdas touch the mesh builder globals), then the checks of every data file read back
and manifest.json."
  (x-write-entries "clips.json" (x-name-pairs engine::*clips* #'x-clip-object))
  (x-write-entries "poses.json" (x-name-pairs engine::*poses* #'identity))
  (x-write "rig.json" (lambda (out) (cl-user::extract-json (x-rig) out) (terpri out)))
  (x-write-entries "bodies.json" (x-name-pairs *bodies* #'x-body-object))
  (x-write-entries "glyphs.json" (x-glyphs) t)
  (x-write-entries "debug_ranges.json" (x-debug-ranges) t)
  (x-write-entries "tables.json" (x-tables))
  (x-write-entries "tuning.json" (x-tuning))
  (x-write-entries "weapons.json" (x-name-pairs *weapons* #'x-weapon-object))
  (x-copy-hud-font)
  (format t "tuning skipped ~d~%" (length *x-skipped*))
  (dolist (why '("function" "move" "unprintable"))
    (format t "  ~a ~d:~{ ~a~}~%" why (count why *x-skipped* :key #'cdr :test #'string=)
            (sort (loop for (n . w) in *x-skipped* when (string= w why) collect n) #'string<)))
  ;; read every data file back: the shape rule, the writer's float hash = the reader's, the counts, the checksum
  (let ((trees (make-hash-table :test 'equal)) (fail nil))
    (dolist (f *x-files*) (setf (gethash f trees) (cl-user::json-read-file (merge-pathnames f *x-out*))))
    (dolist (f *x-files*)
      (let ((c (cl-user::json-shape-conflicts (gethash f trees) (x-collapse f))))
        (when c (setf fail t) (format t "extract FAIL: ~a: an object and an array at one path: ~{~a~^, ~}~%" f c)))
      (let ((w (gethash f *x-write-hash*)) (r (cl-user::json-tree-fnv cl-user::+fnv-basis+ (gethash f trees))))
        (unless (eql w r) (setf fail t) (format t "extract FAIL: ~a: the floats read back differ from the ones written (~x / ~x)~%" f w r))))
    (when fail (finish-output) (ext:quit 1))
    (let ((sum (x-checksum (lambda (f) (gethash f trees)))))
      (x-write "manifest.json"
               (lambda (out)
                 (cl-user::extract-json
                  (cl-user::json-object (list "counts" (cl-user::json-object (loop for f in *x-files* append (list f (x-count f (gethash f trees)))))
                                              "skipped_tuning" (length *x-skipped*) "float_checksum" sum))
                  out)
                 (terpri out)))
      (format t "float checksum ~a~%" sum))))

;;; ---------------------------------------------------------------- census (its own walk: never the dump's)
(defun x-census-objects ()
  "Every distinct MOVE (EQ) the image holds in the places moves live: each kit's table and class keys, *MOVES*, *CADENCE-MOVES*'
keys and values, *YA-REACH-COPIES*, *YA-GARB-COPIES*, *HS-K1-SCALED*."
  (let ((seen (make-hash-table :test 'eq)) (out nil))
    (labels ((add (x) (cond ((move-p x) (unless (gethash x seen) (setf (gethash x seen) t) (push x out)))
                            ((consp x) (add (car x)) (add (cdr x)))
                            ((and (vectorp x) (not (stringp x))) (loop for y across x do (add y))))))
      (maphash (lambda (c forms) (declare (ignore c))
                 (dolist (cf forms)
                   (maphash (lambda (n m) (declare (ignore n)) (add m)) (kit-moves (cdr cf)))
                   (maphash (lambda (m cls) (declare (ignore cls)) (add m)) (kit-cls (cdr cf)))))
               *kits*)
      (maphash (lambda (n m) (declare (ignore n)) (add m)) *moves*)
      (maphash (lambda (k m) (add k) (add m)) *cadence-moves*)
      (add *ya-reach-copies*) (add *ya-garb-copies*) (add *hs-k1-scaled*))
    (values out seen)))

(defun x-sweep-moves (seen)
  "MOVE objects reachable from any bound symbol of DUEL / ENGINE / CL-USER (conses, general vectors, hash tables, structs) that
SEEN lacks: a copy kept somewhere the census list doesn't name."
  (let ((visited (make-hash-table :test 'eq)) (extra nil) (met 0))
    (labels ((walk (x)
               (loop
                 (cond ((or (null x) (numberp x) (symbolp x) (stringp x) (characterp x) (functionp x)) (return))
                       ((gethash x visited) (return)))
                 (setf (gethash x visited) t)
                 (cond ((consp x) (walk (car x)) (setf x (cdr x)))
                       (t (cond ((move-p x) (incf met) (unless (gethash x seen) (pushnew x extra)))
                                ((and (vectorp x) (eq (array-element-type x) t)) (loop for y across x do (walk y)))
                                ((hash-table-p x) (maphash (lambda (k v) (walk k) (walk v)) x))
                                ((typep x 'structure-object)
                                 (dolist (s (x-slot-names (type-of x))) (walk (slot-value x s)))))
                          (return))))))
      (dolist (p '(:duel :engine :cl-user))
        (do-symbols (s p)
          (when (and (eq (symbol-package s) (find-package p)) (boundp s)) (walk (symbol-value s))))))
    (values extra met)))

(defun x-census-moves ()
  "Task 4's census: every MOVE object of the image in moves.json, once. -> T when it fails."
  (multiple-value-bind (objs seen) (x-census-objects)
    (format t "census moves ~d~%" (length objs))
    (multiple-value-bind (extra met) (x-sweep-moves seen)
    (let ((owner (loop for m in objs when (find *perfect-hw* (mv-hits m)) collect (mv-name m)))
          (path (merge-pathnames "moves.json" *x-out*))
          (fail nil))
      (format t "census sweep reached ~d moves, extra ~d~%" met (length extra))
      (when extra (setf fail t) (format t "  not in the census places: ~s~%" (mapcar #'mv-name extra)))
      (format t "census perfect-hw owner ~:[none (a standalone hitwin, fighter.lisp *PERFECT-HW*)~;~:*~s~]~%" owner)
      (if (not (probe-file path))
          (progn (format t "census FAIL: no ~a~%" (namestring path)) (setf fail t))
          (let* ((text (with-open-file (in path :external-format :utf-8)
                         (let ((s (make-string (file-length in)))) (subseq s 0 (read-sequence s in)))))
                 (n (loop for i = (search "\"id\":\"" text) then (search "\"id\":\"" text :start2 (1+ i)) while i count t))
                 (missing (loop for m in objs for id = (gethash m *x-ids*)
                                unless (and id (search (format nil "\"id\":\"~a\"" id) text)) collect (or id (mv-name m)))))
            (format t "census moves.json ids ~d~%" n)
            (unless (= n (length objs)) (setf fail t) (format t "census FAIL: moves.json has ~d moves, the image ~d~%" n (length objs)))
            (when missing (setf fail t) (format t "census FAIL: missing ~d: ~s~%" (length missing) missing))
            (unless (= (hash-table-count *x-ids*) (length objs))
              (setf fail t) (format t "census FAIL: ~d ids claimed, ~d objects~%" (hash-table-count *x-ids*) (length objs)))))
      fail))))

(defun x-census-files ()
  "Task 5's census: each written file's entries (read back from the file) against the image's registries, the tuning names against
the source DEFPARAMETERs, the manifest's counts and checksum against the files. -> T when it fails."
  (let ((fail nil) (trees (make-hash-table :test 'equal)))
    (flet ((bad (fmt &rest args) (setf fail t) (format t "census FAIL: ~?~%" fmt args))
           (keys (tree) (mapcar #'car (cdr tree))))
      (dolist (f *x-files*)
        (let ((p (merge-pathnames f *x-out*)))
          (if (probe-file p) (setf (gethash f trees) (cl-user::json-read-file p)) (bad "no ~a" (namestring p)))))
      (flet ((same (what image-n file)
               (let ((tree (gethash file trees)))
                 (when tree
                   (let ((n (x-count file tree)))
                     (format t "census ~a image ~d ~a ~d~%" what image-n file n)
                     (unless (= image-n n) (bad "~a: the image ~d, ~a ~d" what image-n file n)))))))
        (same "clips" (hash-table-count engine::*clips*) "clips.json")
        (same "poses" (hash-table-count engine::*poses*) "poses.json")
        (same "bodies" (hash-table-count *bodies*) "bodies.json")
        (same "weapons" (hash-table-count *weapons*) "weapons.json")
        (same "glyphs" (length *glyph-outlines*) "glyphs.json")
        (same "debug-ranges" (length engine::*debug-ranges*) "debug_ranges.json")
        (same "rig joints" (length engine::*rig*) "rig.json")
        (same "kits" (loop for forms being the hash-values of *kits* sum (length forms)) "kits.json")
        (same "defparameters" (length *x-defparams*) "tuning.json"))
      (let ((tree (gethash "tuning.json" trees)))
        (when tree
          (let* ((want (sort (mapcar #'symbol-name *x-defparams*) #'string<)) (got (keys tree))
                 (skipped (loop for (k . v) in (cdr tree)
                                when (and (consp v) (eq (car v) :object) (equal (cdr (assoc "kind" (cdr v) :test #'equal)) "skipped"))
                                  collect (cons k (cdr (assoc "why" (cdr v) :test #'equal))))))
            (unless (equal want got) (bad "tuning.json keys differ from the source defparameters: ~s"
                                          (set-exclusive-or want got :test #'string=)))
            (format t "census tuning skipped ~d~{ ~a~}~%" (length skipped)
                    (loop for why in (remove-duplicates (mapcar #'cdr skipped) :test #'equal)
                          collect (format nil "~a:~d" why (count why skipped :key #'cdr :test #'equal))))
            (dolist (s skipped) (unless (member (cdr s) '("function" "move" "unprintable") :test #'equal) (bad "tuning ~a skipped for ~a" (car s) (cdr s)))))))
      (dolist (f *x-files*)
        (let ((tree (gethash f trees)))
          (when tree (let ((c (cl-user::json-shape-conflicts tree (x-collapse f)))) (when c (bad "~a: object and array at one path: ~{~a~^, ~}" f c))))))
      (dolist (f *x-copies*)
        (let ((to (merge-pathnames f *x-out*)))
          (unless (and (probe-file to) (equalp (x-bytes to) (x-bytes (merge-pathnames (concatenate 'string "duel/" f) *x-root*))))
            (bad "~a is not a copy of duel/~a" (namestring to) f))))
      (let ((mp (merge-pathnames "manifest.json" *x-out*)))
        (if (not (probe-file mp))
            (bad "no ~a" (namestring mp))
            (let* ((m (cdr (cl-user::json-read-file mp))) (counts (cdr (cdr (assoc "counts" m :test #'equal))))
                   (sum (when (= (hash-table-count trees) (length *x-files*)) (x-checksum (lambda (f) (gethash f trees))))))
              (dolist (f *x-files*)
                (let ((tree (gethash f trees)) (n (cdr (assoc f counts :test #'equal))))
                  (when (and tree (not (eql n (x-count f tree)))) (bad "manifest counts ~a ~s, the file ~d" f n (x-count f tree)))))
              (format t "census checksum ~a manifest ~a~%" sum (cdr (assoc "float_checksum" m :test #'equal)))
              (unless (equal sum (cdr (assoc "float_checksum" m :test #'equal))) (bad "float checksum differs from the manifest's"))))))
    fail))

(defun x-census ()
  (let ((fail (x-census-moves)))
    (when (x-census-files) (setf fail t))
    (format t "census ~:[PASS~;FAIL~]~%" fail)
    (finish-output)
    (ext:quit (if fail 1 0))))

;;; ---------------------------------------------------------------- main
(let ((cl-user::*json-other* #'x-other))
  (x-assign-ids)
  (cond ((string= *x-mode* "census") (x-census))
        ((member *x-mode* '("moves" "kits" "all") :test #'string=)
         (when (member *x-mode* '("moves" "all") :test #'string=) (x-write-moves))
         (when (member *x-mode* '("kits" "all") :test #'string=) (x-write-kits))
         (when (string= *x-mode* "all") (x-write-rest))
         (format t "kit-name collisions ~d~%" *x-kit-collisions*)
         (format t "ids claimed under the defining ancestor form ~d~%" *x-inherited-claims*)
         (format t "unserialisable ~d ~s~%" (length cl-user::*json-unserialisable*) (remove-duplicates cl-user::*json-unserialisable* :test #'string=))
         (format t "dropped keys ~d ~s~%" (length cl-user::*json-dropped*) (mapcar #'car cl-user::*json-dropped*))
         (format t "long-floats ~d~%" cl-user::*json-long-floats*)
         (let ((paths (sort (loop for p being the hash-keys of *x-syms* collect p) #'string<)))
           (dolist (p paths) (format t "code ~a: ~{~a~^ ~}~%" p (sort (copy-list (gethash p *x-syms*)) #'string<)))))
        (t (format t "unknown mode ~a~%" *x-mode*) (ext:quit 2))))
(finish-output)
(ext:quit 0)
