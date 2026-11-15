;;;; cpu-hisagi-own.lisp — Hisagi's own play (PLAN4 checkpoint 2a, 2026-11-15; docs/research/strategy-drsi/sp/kits/hisagi/strategies.md).
;;;; The user took every strategy of his kit study (「全部採用」) and, for the Shikai: 「改成修兵自己的打法」. Until now every Hisagi arm played
;;;; Kenpachi's brawler (KEN-KI-STYLE, through HISAGI-MERGED-STYLE) in the Shikai: it walked him to 1.7-3.0 m, inside NAGI's 3.0 m dead zone,
;;;; where sealed Kenpachi is faster with both buttons. HISAGI-OWN-STYLE is a strategy's :FN (only research arm files name it: no unit, table
;;;; or lookup entry); it plays HISAGI-HK-STYLE (cpu-hk-hisagi.lisp) with these rules in front of Kenpachi's code, each under its own arm key
;;;; (STYLE-ON; no key: off, the HK style unchanged):
;;;;   :HB-BAND  S1 鎖の間合い, the chain's band: in the Shikai he owns every free step. He stands at *HB-LO*-*HB-HI* (3.4-5.0 m): NAGI on
;;;;             his walk / run-in (its hit predicted inside 3.1-6.2 m), on his whiffs and his charges; the pointer's NS on a whiff that fits
;;;;             (NS3a: the universal punish); the back Step when he closes inside the floor; never an NS inside its dead zone; okizeme: the
;;;;             pointer's NS *HB-OKI-AT* frames after he is free with the opponent down (catalogue K: NAGI +40); the opener on a think timer.
;;;;   :HB-JCLASH  S2 J 側の相消: his NS (or AS) start in reach is answered with J1 (an arm turns the generic clash off with :CLASH-P 0, so
;;;;             he is never the NS side, and forces the AS on the cancel with :XCH-J 0: TSUMUJI wins against every answer, catalogue X-a).
;;;;   :HB-BIND  S4 縛りで追い上げ: behind in Reishi by *HB-BIND-GAP*, his ranged J strings run to J5 > AS3 (KAKE: the bind) and in the bind
;;;;             he seeks cancels (J1 into his NS: each evens 25 % of the gap); ahead, the ranged string ends in AS2 at J4 (never AS3) and a
;;;;             bind is left by J1-J5 > AS3.
;;;;   :HB-OLO / :HB-OHI / :HB-ONS-MIN  K1 突進には J: against his released forms the band moves out (5.8-6.4: beyond the Shikai lunge's 5.7)
;;;;             and no NS of his own starts inside :HB-ONS-MIN.
;;;;   :HB-ICH   I1 突きと月牙: Ichigo's NS3a rush is answered by NS2a / J1, never NAGI; his Getsuga charge by NAGI in its first 20 frames,
;;;;             else a Hoho late into the wave (*HB-ICH-HOHO*), never the back Step.
;;;; Every roll once per event (SIM-RND01 by difficulty); the state in BRAIN-STYLE (an HBS, which an HKS is the base of).
(in-package :duel)

(defparameter *hb-off* '(:easy nil :normal nil :hard nil)
  "A switch off at every difficulty: STYLE-ON's default for this file's rules, so no arm without the key plays them.")
(defparameter *hb-lo* 3.4
  "S1: the band's floor (m, perceived): sealed Kenpachi's J reaches 2.6, his Shikai J 3.4, NAGI's dead zone ends at 3.0 (sheet). 2026-11-15, mine.")
(defparameter *hb-hi* 5.0 "S1: the band's top (m): NS3a reaches 5.2, NAGI 6.4; the walk stops inside the band (it strafes).")
(defparameter *hb-nagi-min* 3.1 "S1: NAGI only when he will be at least this far at its hit (m): its dead zone 3.0 + 0.1.")
(defparameter *hb-nagi-max* 6.2 "S1: ... and at most this far (m; its arc reaches 6.0, the sim's band 6.4).")
(defparameter *hb-ns3-max* 5.0 "S1: NS3a SHIBARI (the 4.5 m line, no dead zone) from at most this far (m; it reaches 5.2).")
(defparameter *hb-ns2-max* 3.6 "S1: NS2a TAN-GARI from at most this far (m; it reaches 3.8).")
(defparameter *hb-react-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "S1: per event of his (an approach, a whiff, a charge; one roll each): the NAGI / NS answer. 2026-11-15, mine.")
(defparameter *hb-step-p* '(:easy 0.25 :normal 0.6 :hard 1.0)
  "S1: per stay inside the floor while he closes (one roll): the back Step (else the walk out). As *HKK-P*.")
(defparameter *hb-poke-p* '(:easy 0.2 :normal 0.35 :hard 0.5)
  "S1: per think decision (*CAI-THINK*) in the band with him free: the opener, the pointer's NS when it reaches (NS3a / NAGI / NS2a), so
a match against a waiting opponent still ends. 2026-11-15, mine.")
(defparameter *hb-oki-at* 40 "S1: okizeme: the pointer's NS this many frames after his first free step with the opponent down (catalogue K).")
(defparameter *hb-awaken-p* '(:easy 0.5 :normal 0.75 :hard 1.0)
  "S1: one roll a match, his first free Shikai step with the awakening gauge full: awaken there (KEN-KI-STYLE's door did it before).")
(defparameter *hb-jclash-p* '(:easy 0.3 :normal 0.6 :hard 1.0)
  "S2: per NS / AS start of his in reach (one roll): J1 into it (the cancel, Hisagi the J side).")
(defparameter *hb-bind-gap* 300 "S4: behind when his Reishi exceeds mine by this much (one bind cancel moves 12.5 % of the gap each way).")
(defparameter *hb-ich-hoho* 14
  "I1: the Hoho into Ichigo's wave segment (NS2c) at this frame of it (his charge's +50: catalogue G, a Hoho at +50 / +60 passes through).")
(defparameter *hb-ich-charge* '(:ic-n2a :ic-n2b :ic-k-n2a :ic-k-n2b) "I1: Ichigo's Getsuga charge segments.")
(defparameter *hb-ich-wave* '(:ic-n2c :ic-k-n2c) "I1: ... and the wave's.")

(defstruct (hbs (:include hks) (:constructor make-hbs ()))
  (pd 99.0 :type single-float)  ; the perceived distance at his last free Shikai step (closing in: it falls)
  (ev nil)                      ; inside an approach event (he closes in)
  (go nil)                      ; its NAGI roll said yes
  (in nil)                      ; inside the band's floor
  (step nil)                    ; its back-Step roll said yes
  (rkey -1 :type fixnum)        ; his move (SNAP-START) the reaction roll was made for
  (rgo nil)                     ; its roll
  (oki -1 :type fixnum)         ; the tick of his first free step with the opponent down (-1: none)
  (aw nil)                      ; the match's awaken roll: NIL unmade, :go, :no
  (ckey -1 :type fixnum)        ; S2: his move (SNAP-START) the J clash was rolled for
  (bkey -1 :type fixnum)        ; S4: his own NA link (CLS-T) the bind rule decided
  (bt 0 :type fixnum))          ; S4: the tick of the next J1 sought from the tip while behind
(inline-readers hbs)

(defun hb-ns (e b f kit s d mv nsmin)
  "Start MV (his pointer's NS) with a tap when D is out of its dead zone (MV-MIN-REACH + 0.1) and NSMIN, and his gauge pays for it. T."
  (when (and mv (>= d (+ (mv-min-reach mv e) 0.1)) (>= d nsmin) (kit-sp-start-p kit mv (gauges-fs (gauges e)) (gauges-burst (gauges e))))
    (clog "~a hb ~(~a~) at ~,1f" (side-name e) (mv-name mv) d)
    (hr-sp b f s) (hr-taken b f) t))

(defun hb-reach-ok-p (ptr d nmin)
  "Does pointer PTR's Shikai NS reach D from the band (NAGI NMIN-*HB-NAGI-MAX*, NS2a to *HB-NS2-MAX*, NS3a to *HB-NS3-MAX*)?"
  (case ptr (1 (<= nmin d *hb-nagi-max*)) (2 (<= d *hb-ns2-max*)) (t (<= d *hb-ns3-max*))))

(defun hb-behind-p (e b)
  "Is E behind in Reishi by the arm's :HB-BIND-GAP (*HB-BIND-GAP*)? (Both bars are on the HUD.)"
  (>= (- (gauges-reishi (gauges (fighter-opp (fighter e)))) (gauges-reishi (gauges e))) (style-knob b :hb-bind-gap *hb-bind-gap*)))

(defun hb-react (b s st)
  "One roll of *HB-REACT-P* per move of his (SNAP-START): T while this move's roll says yes."
  (unless (= (hbs-rkey st) (snap-start s))
    (setf (hbs-rkey st) (snap-start s) (hbs-rgo st) (style-roll b :hb-react-p *hb-react-p*)))
  (hbs-rgo st))

(defun hb-ich (e b f kit s d st nsmin)
  "I1 (:HB-ICH) against Ichigo's two long threats. Values: T when it pressed; second, :NO-NAGI while NAGI must wait (his rush starting,
his charge past its first 20 frames), so the band rule below neither NAGIs nor back-Steps."
  (let* ((mv (snap-move s)) (name (and mv (eq (snap-state s) :move) (mv-name mv))) (fr (+ (snap-sf s) (brain-delay b)))
         (ptr (mc-ptr f)))
    (cond ((member name '(:ic-n3a))
           (if (and (< fr (snap-s s)) (<= d 5.5) (hb-react b s st))
               (values (or (and (= ptr 2) (<= d *hb-ns2-max*) (hb-ns e b f kit s d (kit-core-move kit :ns 2) nsmin))
                           (progn (clog "~a hb J1 into his rush at ~,1f" (side-name e) d) (setf (brain-own-key b) -1)
                                  (cai-press b :quick 1) (hr-taken b f) t))
                       :no-nagi)
               (values nil :no-nagi)))
          ((member name *hb-ich-charge*)
           (let ((age (if (member name '(:ic-n2a :ic-k-n2a)) fr (+ 20 fr))))
             (if (and (<= age 20) (= ptr 1) (<= 4.0 d 6.0) (hb-react b s st))
                 (values (hb-ns e b f kit s d (kit-core-move kit :ns 1) (max nsmin *hb-nagi-min*)) :no-nagi)
                 (values nil :no-nagi))))
          ((member name *hb-ich-wave*)
           (if (and (>= fr (style-knob b :hb-ich-hoho *hb-ich-hoho*)) (hoho-ready-p e) (hb-react b s st))
               (progn (clog "~a hb Hoho through the wave at ~,1f" (side-name e) d) (mc-press b :hoho) (hr-taken b f) (values t :no-nagi))
               (values nil :no-nagi)))
          (t (values nil nil)))))

(defun hb-band (e b f kit s d st)
  "S1, the Shikai's free step (the file header). T: it owns every free Shikai step (NIL only in a cinematic or his intro)."
  (let* ((ss (snap-state s)) (fo (fighter (fighter-opp f))) (oalt (not (eq (fighter-form fo) :base)))   ; (his form: the HUD shows it)
         (lo (style-knob b :hb-lo *hb-lo*)) (hi (style-knob b :hb-hi *hb-hi*))
         (lo (if oalt (style-knob b :hb-olo lo) lo)) (hi (if oalt (style-knob b :hb-ohi hi) hi))
         (nsmin (if oalt (style-knob b :hb-ons-min 0.0) 0.0))
         (nmin (max nsmin (style-knob b :hb-nagi-min *hb-nagi-min*)))
         (v (if (> (hbs-pd st) 50.0) 0.0 (max 0.0 (- (hbs-pd st) d)))) (closing (> v 0.004))   ; (his perceived closing speed, m a step)
         (ptr (mc-ptr f)) (ns (kit-core-move kit :ns ptr)) (down (member ss '(:air :down :wakeup)))
         (dp (- d (* v (+ (brain-delay b) 20)))))       ; (where he will be at NAGI's hit, S 20)
    (setf (hbs-pd st) (f32 d))
    (when (member ss '(:cine :intro)) (return-from hb-band nil))
    (setf (hbs-oki st) (if down (if (minusp (hbs-oki st)) *match-tick* (hbs-oki st)) -1))
    (unless closing (setf (hbs-ev st) nil))
    (unless (< d lo) (setf (hbs-in st) nil))
    (when (and (gauges-awakened-ok-p e) (not (hbs-aw st)))                  ; (the awakening: one roll a match)
      (setf (hbs-aw st) (if (style-roll b :hb-awaken-p *hb-awaken-p*) :go :no)))
    (multiple-value-bind (ich-pressed hold)
        (if (and (not down) (style-on b :hb-ich *hb-off*)) (hb-ich e b f kit s d st nsmin) (values nil nil))
      (cond (ich-pressed t)
            ((and (eq (hbs-aw st) :go) (gauges-awakened-ok-p e))
             (clog "~a hb awaken" (side-name e)) (ai-press b :awaken 1 :modded t) t)
            ;; okizeme: the pointer's NS *HB-OKI-AT* frames after he is free with the opponent down
            ((and down (>= (- *match-tick* (hbs-oki st)) (style-knob b :hb-oki-at *hb-oki-at*)) (hb-reach-ok-p ptr d nmin)
                  (hb-ns e b f kit s d ns (if (= ptr 1) nmin nsmin))))
            ;; his whiff: the pointer's NS when it lands before he recovers (HKW-FITS-P: the reach, the dead zone, his recovery seen)
            ((and (not down) (not hold) (snap-recovering-p s) (null (snap-contact s)) (hkw-fits-p e ns s b d) (hb-react b s st)
                  (hb-ns e b f kit s d ns (if (= ptr 1) nmin nsmin))))
            ;; his charge (a segment with no hit of its own, no parry): NAGI into it
            ((and (not hold) (= ptr 1) (eq ss :move) (snap-move s) (zerop (length (mv-hits (snap-move s)))) (not (member :parry (snap-flags s)))
                  (not (getf (mv-params (snap-move s)) :hit-at)) (not (member (mv-name (snap-move s)) *hb-ich-wave*))   ; (KESSA's clones, the wave)
                  (<= nmin d *hb-nagi-max*) (hb-react b s st) (hb-ns e b f kit s d ns nmin)))
            ;; his walk / run-in: NAGI when its hit meets him in the band (one roll per approach)
            ((and (not hold) closing (= ptr 1) (not (eq ss :move))
                  (progn (unless (hbs-ev st) (setf (hbs-ev st) t (hbs-go st) (style-roll b :hb-react-p *hb-react-p*))) (hbs-go st))
                  (<= nmin dp 6.0) (<= d *hb-nagi-max*) (hb-ns e b f kit s d ns nmin))
             (setf (hbs-go st) nil) t)
            ;; inside the floor while he closes (or well inside it): the back Step, one roll per stay; cornered: the side Step
            ((and (not hold) (< d lo) (or closing (< d (- lo 0.5))) (not down)
                  (progn (unless (hbs-in st) (setf (hbs-in st) t (hbs-step st) (style-roll b :hb-step-p *hb-step-p*))) (hbs-step st)))
             (setf (hbs-step st) nil)
             (if (hr-cornered-p e (style-knob b :hr-edge *hr-edge*))
                 (progn (clog "~a hb side-step at ~,1f" (side-name e) d) (mc-press b :step-side))
                 (progn (clog "~a hb back-step at ~,1f" (side-name e) d) (mc-press b :step-out)))
             (hr-taken b f) t)
            (t (when (<= (decf (brain-decide-t b)) 0)                         ; (the think timer: the opener, the run-in from afar)
                 (setf (brain-decide-t b) (+ (getf *cai-think* (brain-difficulty b) 22) (floor (* 12 (sim-rnd01)))))
                 (cond ((> d 8.0) (ai-dash b 1 hi))
                       ((and (not down) (not hold) (not (eq ss :move)) (<= lo d (+ hi 0.5)) (hb-reach-ok-p ptr d nmin)
                             (style-roll b :hb-poke-p *hb-poke-p*))
                        (hb-ns e b f kit s d ns (if (= ptr 1) nmin nsmin)))))
               (unless (> (brain-press-left b) 0) (ai-walk e b (pilot-vpad (pilot e)) d lo hi))
               t)))))

(defun hb-shikai (e b f kit s d st)
  "HISAGI-HK-STYLE's own rule (its OWN argument): S1 on his free Shikai steps (and his Steps there: held, so Kenpachi's step-in J
never follows the back Step). NIL elsewhere or without :HB-BAND."
  (if (and (eq (fighter-form f) :base) (member (fighter-state f) '(:idle :run :step)) (hbs-p st) (style-on b :hb-band *hb-off*))
      (or (eq (fighter-state f) :step) (hb-band e b f kit s d st))
      (progn (when (hbs-p st) (setf (hbs-pd st) 99f0 (hbs-ev st) nil)) nil)))

(defun hb-jclash (e b f s0 d0 st)
  "S2's J1 into his NS / AS (CAI-CLASH's test, the J opener only; its own event key): free in the Shikai under :HB-JCLASH, or in the bind
under :HB-BIND while behind. T when it pressed."
  (when (and (member (fighter-state f) '(:idle :run))
             (case (fighter-form f)
               (:base (style-on b :hb-jclash *hb-off*))
               (:bankai-bind (and (style-on b :hb-bind *hb-off*) (hb-behind-p e b)))))
    (let* ((dl (min (brain-delay b) (brain-chance b *cai-clash-delay*)))
           (s (if (< dl (brain-delay b)) (or (brain-snap-ago b dl) s0) s0)) (d (if (eq s s0) d0 (snap-dist s e)))
           (mv (snap-move s)) (hits (if mv (length (mv-hits mv)) 0)))
      (multiple-value-bind (end reach)
          (and mv (clash-window hits (snap-active-end s) (snap-reach s) (getf (mv-params mv) :hit-at) (getf (mv-params mv) :hit-reach)))
        (when (and end (eq (clash-opener (cai-class-of (fighter-opp f) s)) :na) (/= (hbs-ckey st) (snap-start s)) (plusp reach)
                   (not (member :parry (snap-flags s))) (>= (- end (snap-sf s) dl) 1)
                   (if (plusp hits) (snap-near-p s e d (cai-margin b)) (< d (+ reach (cai-margin b)))))
          (setf (hbs-ckey st) (snap-start s))
          (when (style-roll b :hb-jclash-p *hb-jclash-p*)
            (mc-plan-drop f)
            (clog "~a hb J1 into his ~(~a~) at ~,1f" (side-name e) (cai-class-of (fighter-opp f) s) d)
            (setf (brain-own-key b) -1 (brain-r-kikon b) 1f0)
            (cai-press b :quick 1)
            t))))))

(defun hb-bind-link (e b f kit s st)
  "S4 (:HB-BIND) in his ranged / bind J string, on each link that lands (once): behind, the ranged string runs to J5 > AS3 (the bind) and
the bind's string stops at AS2 (J4); ahead, the ranged string stops at AS2 (J4) and the bind's runs to J5 > AS3 (out). T when it pressed."
  (when (and (eq (fighter-state f) :move) (eq (fighter-cls f) :na) (eq (fighter-contact f) :hit) (not (fighter-as-done f))
             (member (fighter-form f) '(:bankai :bankai-bind)) (/= (brain-decided b) (fighter-cls-t f)) (/= (hbs-bkey st) (fighter-cls-t f))
             (style-on b :hb-bind *hb-off*))
    (setf (hbs-bkey st) (fighter-cls-t f))
    (let* ((behind (hb-behind-p e b)) (ahead (> (gauges-reishi (gauges e)) (gauges-reishi (gauges (fighter-opp f)))))
           (n (fighter-presses f)) (bind (eq (fighter-form f) :bankai-bind))
           (act (cond ((if bind ahead behind) (if (>= n 5) :as :j))     ; (to AS3: the bind in, or out)
                      ((and (if bind behind ahead) (= n 4)) :as))))       ; (AS2 at J4: never AS3)
      (when act
        (setf (brain-decided b) (fighter-cls-t f))
        (clog "~a hb bind ~(~a~) at J~d (~a)" (side-name e) act n (if behind "behind" "ahead"))
        (if (eq act :j)
            (cai-press b :quick 1)
            (cai-sp b f s 1 (let ((as (kit-core-move kit :as (core-next-as f)))) (and as (getf (mv-params as) :no-kikon)))))
        t))))

(defun hb-bind-seek (e b f s d st)
  "S4 (:HB-BIND) free in the ranged mode and behind: J1 from where it reaches (3.2-6.2 m: its 3.0 m dead zone, the tip at 5.5-6.4), once
every 30 steps, so the string that ends in the bind starts. T when it pressed."
  (when (and (eq (fighter-form f) :bankai) (member (fighter-state f) '(:idle :run)) (>= *match-tick* (hbs-bt st))
             (style-on b :hb-bind *hb-off*) (hb-behind-p e b) (<= 3.2 d 6.2) (not (member (snap-state s) '(:move :cine :intro))))
    (setf (hbs-bt st) (+ *match-tick* 30))
    (clog "~a hb bind seek J1 at ~,1f" (side-name e) d)
    (setf (brain-own-key b) -1)
    (cai-press b :quick 1) (hr-taken b f)
    t))

(defun hisagi-own-style (e b f kit s d)
  "Hisagi's own play (the file header): S2's J clash and S4's bind rules first, then HISAGI-HK-STYLE with S1 as its own rule (before
Kenpachi's KI code). T when it decided."
  (let ((st (brain-style b)))
    (when (or (not (hbs-p st)) (< *match-tick* (hks-hk-tick st))) (setf st (make-hbs) (brain-style b) st))
    (if (or (hb-jclash e b f s d st) (hb-bind-link e b f kit s st) (hb-bind-seek e b f s d st))
        (progn (setf (hks-hk-tick st) *match-tick* (hks-hk-was st) (fighter-state f)) t)   ; (as HISAGI-HK-STYLE leaves them)
        (hisagi-hk-style e b f kit s d #'hb-shikai))))
