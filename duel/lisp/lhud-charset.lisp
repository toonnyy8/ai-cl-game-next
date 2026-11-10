;;;; lhud-charset.lisp — the Lisp HUD's closed character set (docs/duel/DUEL_LISP_HUD.md §4.2, §9): which characters tools/sdf-bake.py
;;;; bakes in which face and tier. Pure data: the forms evaluate to nothing, tools/sdf-bake.py and tests/duel-rules/lhud-charset.lisp
;;;; read this file as text. Every other CJK / symbol character of duel/web/hud.js and menu.js is baked in the sans by the bake's own
;;;; scan of those two files (the sans is the page's body face and the fallback of every face), so a string that is missing here still
;;;; shows, only in the wrong face; the host test fails when the scan finds a character no face has.
;;;;   (kj "…")    Mincho, body tier (<= 40 px): names, seals, the callout's kanji, the menu's seals and crumbs
;;;;   (bigkj "…") Mincho, display tier (> 40 px): the big seals, emblems, finish words, the intro's name column, the menu's kanji
;;;;   (big "…")   the display face, display tier: the wordmark, names, READY / K.O. / TIME, digits (the combo and clock digits too)
;;;;   (lhud-shape "…") drawn as polygons by the HUD, in no face (the keycap and menu glyphs no baked face carries)

(in-package :duel)

(defmacro bigkj (s) "Mincho glyphs of the display tier (the bake reads these)." s)
(defmacro lhud-shape (s) "Characters the Lisp HUD draws as shapes, not text (the bake and the charset test read these)." s)

;; fighters: the plates' kanji, the intro's full names, the menu's jp names, the kit strip, the tags
(kj "山本更木朽木黒崎修多羅リジェ檜佐木")
(kj "山本元柳斎重國更木剣八朽木ルキア黒崎一護修多羅千手丸リジェ・バロ檜佐木修兵")
(kj "呑腕解風死分身毀止爆技斬覺")
;; the pointer seals and the forms' seals
(kj "拖肩構旋墜狂壞重月亂鎖影投刈雷散聚鎌絞縛")
;; the callout's kanji (hud.js MOVES, CRY)
(kj "綴雷電縛後薙旋風旋刈連刈短刈刈上交刈蓄電放電蓄纏斬首掛刈れ鎖雨絞縄解縛絞首")
(kj "月牙天衝月牙十字衝双牙乱月月落峰打ち落牙鎖盾鎖引残像影討分身ぶった斬る")
(kj "俺に斬れねえもんはねえ飲み干せ噛み千切り盾ごと殴り飛ばし真っ二つ斬月")
;; the menus: seals, crumbs, the vertical tagline, the mode kanji, the emblems
(kj "戦稽闘観設操書再選題魂道勝対戦稽古決闘観戦設定操作指南剣月風")
(kj "一対一・死神の決闘")

(bigkj "魂剣月風止斬決着時間切れ勝")
(bigkj "対戦稽古決闘観戦設定操作指南")
(bigkj "山本元柳斎重國更木剣八朽木ルキア黒崎一護修多羅千手丸リジェ・バロ檜佐木修兵")

(big "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.:-–—·×/!?'+→∞,%()")

(lhud-shape "⇧␣▶◀✚↺")
