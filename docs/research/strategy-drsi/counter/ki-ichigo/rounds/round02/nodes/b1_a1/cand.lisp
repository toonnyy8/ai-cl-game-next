;; behind-red-extra: Ichigo's own style CPU (incumbent plays Kenpachi's) while behind on Konpaku, or the opponent is red, or (even lead and his move active), or he evades.
(:id :behind-red-extra
 :own (((:lead :behind)) ((:ored :yes)) ((:ost :active) (:lead :even)) ((:ost :evade)))
 :fn ichigo-ki-style)
