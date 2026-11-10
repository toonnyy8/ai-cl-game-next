;;;; lhud-data.lisp — the Lisp HUD's battle tables (docs/duel/DUEL_LISP_HUD.md §4.2, §13): what hud.js keeps in its own tables
;;;; (FIGHTERS, MOVES, the tag rewrites), moved here so the Lisp HUD reads the same model the page reads and turns its ASCII into
;;;; the same kanji. Plain CL (host-tested in tests/duel-rules/lhud-geom.lisp); the JS copies are frozen as the reference while both
;;;; renderers coexist (DUEL_LISP_HUD §6), this file is the one edited.
;;;; Strings carry their face for tools/sdf-bake.py: (kj "…") the Mincho (.seal, .kj, .ck), (zh "…") the sans (CJK inside a Latin
;;;; face falls back to it, as the browser does: the seal names 「拖 · DRAG」, the tags 風死 / 分身); untagged = ASCII.
(in-package :duel)

(defmacro kj (s) "A string drawn in the Mincho (the bake reads these)." s)
(defmacro zh (s) "A string drawn in, or falling back to, the sans (the bake reads these)." s)
(defmacro big (s) "Glyphs the display tier carries (the bake reads these)." s)
(big "0123456789")                                        ; (the combo count at 6.2u: 79 px at 1280 x 720)

(defparameter *lhud-ptr0* (list (list (zh "一") "PTR 1") (list (zh "二") "PTR 2") (list (zh "三") "PTR 3"))
  "hud.js PTR0: the seals of a kit without its own (the retired kits).")

(defparameter *lhud-fighters*
  ;; roster index (kit.lisp *ROSTER*) -> (NAME KANJI SEALS FORMS): hud.js FIGHTERS. NAME upper case (the CSS upper-cases it); SEALS
  ;; the pointer seals ((glyph name) ...), FORMS (("FORM" seals) ...) by the plate label's form, or the form + " " + the tag
  (vector (list "YAMAMOTO" (kj "山本") nil nil)
          (list "KENPACHI" (kj "更木")
                (list (list (kj "拖") (zh "拖 · DRAG")) (list (kj "肩") (zh "肩 · SHOULDER")) (list (kj "構") (zh "構 · CHUDAN")))
                (list (list "SHIKAI" (list (kj "旋") (zh "旋 · KAITEN")) (list (kj "墜") (zh "墜 · TSUITEN")))
                      (list "KYORAN" (list (kj "狂") (zh "狂嵐 · KYORAN")))
                      (list "ZANKAI" (list (kj "壞") (zh "斬壞 · ZANKAI")))))
          (list "RUKIA" (kj "朽木") nil nil)
          (list "ICHIGO" (kj "黒崎")
                (list (list (kj "重") (zh "重 · CLEAVER")) (list (kj "月") (zh "月 · GETSUGA")) (list (kj "亂") (zh "亂 · RANGETSU")))
                (list (list "KESSA" (list (kj "鎖") (zh "鎖 · CHAINS")) (list (kj "月") (zh "月 · 漆黒")) (list (kj "影") (zh "影 · 千影")))))
          (list "SENJUMARU" (kj "修多羅") nil nil)
          nil
          (list "LILLE" (kj "リジェ") nil nil)
          (list "HISAGI" (kj "檜佐木")
                (list (list (kj "投") (zh "投 · NAGI")) (list (kj "刈") (zh "刈 · KARI")) (list (kj "雷") (zh "縛雷 · SHIBARI")))
                (list (list "FUSHI NO KOJO RANGED" (list (kj "散") (zh "散 · SPREAD")) (list (kj "聚") (zh "聚 · GATHER")))
                      (list "FUSHI NO KOJO BIND" (list (kj "鎌") (zh "鎌 · KAMA")) (list (kj "絞") (zh "絞 · SHIBORI")))))))

(defparameter *lhud-moves*
  ;; a callout's romaji (upper case) -> its kanji (hud.js MOVES; the romaji alone when it is not here)
  (list (cons "TSUZURI RAIDEN" (kj "綴雷電")) (cons "SHIBARI" (kj "縛")) (cons "USHIRO-NAGI" (kj "後薙")) (cons "TSUMUJI" (kj "旋風"))
    (cons "SEN-GARI" (kj "旋刈")) (cons "REN-GARI" (kj "連刈")) (cons "TAN-GARI" (kj "短刈")) (cons "KARI-AGE" (kj "刈上"))
    (cons "KO-GARI" (kj "交刈")) (cons "CHIKUDEN" (kj "蓄電")) (cons "HODEN" (kj "放電")) (cons "TAME" (kj "蓄")) (cons "MATOI" (kj "纏"))
    (cons "KIRI" (kj "斬")) (cons "KUBIKAKE" (kj "首掛")) (cons "KARE, KAZESHINI" (kj "刈れ")) (cons "KUSARI-AME" (kj "鎖雨"))
    (cons "KOJO" (kj "絞縄")) (cons "KAIBAKU" (kj "解縛")) (cons "KOSHU" (kj "絞首")) (cons "GETSUGA TENSHO" (kj "月牙天衝"))
    (cons "GETSUGA JUJISHO" (kj "月牙十字衝")) (cons "SOGA" (kj "双牙")) (cons "RANGETSU" (kj "乱月")) (cons "TSUKI-OTOSHI" (kj "月落"))
    (cons "MINEUCHI" (kj "峰打ち")) (cons "RAKUGA" (kj "落牙")) (cons "KUSARI-TATE" (kj "鎖盾")) (cons "KUSARI-BIKI" (kj "鎖引"))
    (cons "ZANZO" (kj "残像")) (cons "KAGE-UCHI" (kj "影討")) (cons "BUNSHIN" (kj "分身")) (cons "BUTTAGIRU" (kj "ぶった斬る"))
    (cons "ORE NI KIRENEE MON WA NEE" (kj "俺に斬れねえもんはねえ")) (cons "NOMIHOSE" (kj "飲み干せ"))
    (cons "KAMICHIGIRI" (kj "噛み千切り")) (cons "TATE-GOTO" (kj "盾ごと")) (cons "NAGURI-TOBASHI" (kj "殴り飛ばし"))
    (cons "MAPPUTATSU" (kj "真っ二つ"))))

;;; ---------------------------------------------------------------- pure lookups (each called only when its model string changed)
(defun lhud-fighter (roster+1)
  "The *LHUD-FIGHTERS* entry of the model's roster value (V o+0: roster index + 1), or NIL."
  (let ((k (1- roster+1))) (and (<= 0 k (1- (length *lhud-fighters*))) (svref *lhud-fighters* k))))

(defun lhud-label-name (label)
  "hud.js nameOf's fallback: the plate label's first part (before two spaces), upper case (the CSS's); \"—\" when empty."
  (let* ((l (or label "")) (cut (search "  " l)) (n (string-trim " " (subseq l 0 (or cut (length l))))))
    (if (plusp (length n)) (string-upcase n) (zh "—"))))

(defun lhud-label-form (label)
  "hud.js formOf: the plate label's form, after two or more spaces (\"\" when none)."
  (let* ((l (or label "")) (cut (search "  " l)))
    (if cut (string-trim " " (subseq l cut)) "")))

(defun lhud-seals (entry form tag)
  "hud.js seals(s): the seals of the fighter ENTRY in FORM (its own by the form + \" \" + TAG, then the form), its sealed ones, or PTR0."
  (if (or (null entry) (null (third entry)))
      *lhud-ptr0*
      (let ((forms (fourth entry)))
        (or (cdr (assoc (concatenate 'string form " " (or tag "")) forms :test #'string=))
            (cdr (assoc form forms :test #'string=))
            (third entry)))))

(defun lhud-move-kanji (romaji)
  "hud.js MOVES: the kanji of a callout's ROMAJI (case ignored), or NIL."
  (and romaji (cdr (assoc romaji *lhud-moves* :test #'string-equal))))

(defun lhud-tag-segments (label tag)
  "hud.js tagHTML, as segments (STRING . JADE-P) in the order drawn, upper case (the CSS's text-transform; kanji untouched): the
form (lower-cased by the page, upper-cased by the CSS), a jade \" · \", then the tag: 風死 · IN HAND / THROWN / RETURNING (Hisagi's
sickle), 分身 · ×N (KESSA's clones), nothing for a kit strip's kind (NOME / UDE / KAIHO), else the tag itself."
  (let* ((form (string-upcase (lhud-label-form label))) (tg (or tag ""))
         (n (and (> (length tg) 9) (string= "BUNSHIN x" tg :end2 9) (digit-char-p (char tg 9))))
         (out (cond ((string= tg "KAZESHINI IN") (list (cons (zh "風死") nil) (cons " · " t) (cons "IN HAND" nil)))
                    ((string= tg "KAZESHINI OUT") (list (cons (zh "風死") nil) (cons " · " t) (cons "THROWN" nil)))
                    ((string= tg "KAZESHINI ...") (list (cons (zh "風死") nil) (cons " · " t) (cons "RETURNING" nil)))
                    (n (list (cons (zh "分身") nil) (cons " · " t) (cons (format nil (zh "×~d") n) nil)))
                    ((member tg '("NOME" "UDE" "KAIHO" "") :test #'string=) nil)
                    (t (list (cons (string-upcase tg) nil))))))
    (append (when (plusp (length form)) (list (cons form nil)))
            (when (and (plusp (length form)) out) (list (cons " · " t)))
            out)))

(defun lhud-kit-kind (tag)
  "The kit strip under the bar by the tag (DUEL_WEBUI §13): 1 NOME, 2 UDE, 3 KAIHO, 0 none."
  (cond ((equal tag "NOME") 1) ((equal tag "UDE") 2) ((equal tag "KAIHO") 3) (t 0)))
