;;;; strat-judge-dump.lisp — the answer key of tests/strategy.rs `judgements_match_the_native_dump` (M2 Task 5): every Q-selector
;;;; judgement of a native CvC run (*STRAT-JUDGE-HOOK*, a tool's hook; nothing under duel/ changes), one line each:
;;;;   J <side> <tick> <table id> <arm> <cue>=<value> ... | <Q per arm>     (values ~S: integers as such, singles read back exactly)
;;;; Usage (a gate trace's start commands, its "S cmds" line; JD_MAX the last match tick):
;;;;   JD_MAX=1500 LD_PRELOAD=build/simgate/muslm.so $ECL_HOST --norc --load rs/duel-sim/tests/fixtures/strat-judge-dump.lisp \
;;;;     -- build/simgate/duel.fas 30000 31101 200110
;;;; strat-judgements.txt: every line of cvc-{kk,ki,ik,ii}-s1 (JD_MAX 1500), the tick-1 lines of the other eleven live gate traces,
;;;; each prefixed with its trace's name.
(load "tools/simgate/prelude.lisp" :verbose nil)
(in-package :duel)
(defvar *jd-max* (parse-integer (or (ext:getenv "JD_MAX") "1200")))
(setf *strat-judge-hook*
      (lambda (e b sw sub i feats)
        (declare (ignore b))
        (let ((*read-default-float-format* 'single-float))
          (format t "J ~d ~d ~(~a~) ~d" (fighter-side (fighter e)) *match-tick* (getf sw :id) i)
          (loop for (k v) on feats by #'cddr do (format t " ~(~a~)=~S" k v))
          (format t " |~{ ~S~}~%" (coerce (strat-fq-q (getf sw :fq) feats) 'list)))
        (values sub i)))
(cl-user::sg-init)
(cl-user::sg-queue)
(engine::%frame)
(loop repeat 400000 do (unless (engine::%frame) (ext:quit 3)) until (and (battle-p) (> *match-tick* *jd-max*)))
(finish-output)
(ext:quit 0)
