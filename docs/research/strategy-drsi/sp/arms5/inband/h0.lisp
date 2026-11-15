;;;; arms5/inband/h0.lisp — Hisagi's arm 0 candidates for the in-band batch (arms5/inband.md §1): the old arm 0 (cells-h/final/h4-all),
;;;; his own arm 0 with the clash restored (h5-all, = arms5/hisagi/arms-clash.lisp's), and as the arms5 batch built it (:clash-p 0: h5-all0).
(:id :h4-all :fn hisagi-hk-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0))
(:id :h5-all :fn hisagi-own-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0 :hb-band 1.0))
(:id :h5-all0 :fn hisagi-own-style :ken-ranged t :apply (:hisagi) :base (:hk-pot 1.0 :hb-band 1.0 :clash-p 0.0))
