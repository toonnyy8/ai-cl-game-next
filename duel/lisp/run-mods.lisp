(in-package :duel)
(defvar *run-mods* nil "The held DANGAI rewards' modifier plist (DUEL_ROGUE §4.4); NIL outside a run.")
(defvar *run-mods-who* nil "The fighter *RUN-MODS* applies to (P1).")
(defun rmod (e key default) "KEY of *RUN-MODS* for fighter E, else DEFAULT (DUEL_ROGUE §4.4)." (if (and *run-mods* (eq e *run-mods-who*)) (getf *run-mods* key default) default))
