"""split.py SRC OUT — the round-3 bundle (three rules in one HISAGI-HK-STYLE) as one style with each rule's ACTION gated by a strategy key
(:hk-wake / :hk-pot / :hk-kite, read with STRAT-OUT); every rule's tracking still runs on every call, so a strategy with all three keys on
plays the bundle bit for bit."""
import sys
src, out = sys.argv[1], sys.argv[2]
s = open(src).read()
a = """    (prog1 (or (hkw-step e b f kit s d st) (hkb-step e b s d st)
               (and (member (fighter-state f) '(:idle :run)) (hkk-step e b f kit s d st))
               (hisagi-merged-style e b f kit s d))
      (setf (hks-hk-was st) (fighter-state f)))))"""
assert a in s, 'bundle dispatch not found'
s = s.replace(a, """    (prog1 (or (and (strat-out :hk-wake nil) (hkw-step e b f kit s d st))
               (hkb-gated e b s d st)
               (hkk-gated e b f kit s d st)
               (hisagi-merged-style e b f kit s d))
      (setf (hks-hk-was st) (fighter-state f)))))""")
a = "(defun hisagi-hk-style (e b f kit s d)"
s = s.replace(a, """(defun hkb-gated (e b s d st)
  "The Reishi pot under its key :HK-POT. Off: its episode tracking still runs (re-armed when the condition ends, disarmed when it opens)."
  (if (strat-out :hk-pot nil)
      (hkb-step e b s d st)
      (progn (unless (and (eq (burst-ok-p e) :white) (<= (reishi-frac (gauges e)) *hkb-below*)) (setf (hks-hk-armed st) t))
             nil)))

(defun hkk-gated (e b f kit s d st)
  "The kite under its key :HK-KITE (Hisagi idle / running). Off: its perceived-distance tracking still runs."
  (when (member (fighter-state f) '(:idle :run))
    (if (strat-out :hk-kite nil)
        (hkk-step e b f kit s d st)
        (progn (setf (hks-k-pd st) (f32 d) (hks-k-on st) nil (hks-k-go st) nil) nil))))

""" + a, 1)
open(out, 'w').write(s)
print('wrote', out)
