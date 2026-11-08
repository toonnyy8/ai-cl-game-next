;; s1-brawler: close-range pressure. Walks in to ~1.2-2.1 m (range x0.7), prefers J1 / Step-in over waiting, rarely Hohos away, goes on
;; (cont) after a landing, awakens early. When he is down it walks in and presses (KI Kenpachi's "meaty J1 on wake-up", expressed only
;; as a bias to walk in + J1 while his state class is 4; the exact meaty timing is NOT expressible, see README).
;; Borrows: Kenpachi's sealed brawl (stay inside his reach, win the J1 race), Ichigo's KESSA assault (awaken early, chain at 2.8-3.4 m).
(:id :s1-brawler
 :base (:range 0.7 :ns 0.35 :hoho 0.5 :cont 1.3 :awaken 3.0
        :b-walk-in 0.06 :b-j1 0.05 :b-step-in 0.03 :b-wait -0.05 :b-walk-out -0.08 :b-step-out -0.05)
 :rules
 ((((:ost :down)) (:b-walk-in 0.14 :b-j1 0.12 :b-wait -0.12))
  (((:dj :in)) (:b-j1 0.12 :b-step-out -0.1))
  (((:dj :afar)) (:b-walk-in 0.12 :b-step-in 0.08))
  (((:ost :active) (:dj :in)) (:b-hoho -0.05))))
