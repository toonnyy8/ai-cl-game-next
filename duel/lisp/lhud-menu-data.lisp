;;;; lhud-menu-data.lisp — the Lisp menus' tables (docs/duel/DUEL_LISP_HUD.md §15): what menu.js keeps in its own tables (MODES,
;;;; FIGHTERS cards, SETTINGS, BINDS, KEYS / PADS, COLS, RMENU, SCREENS, the phone's gesture card, the side titles), moved here so the
;;;; Lisp menus read the model the page read (webui.lisp *UI-SENT*) and show the same words. Plain CL, constant after load
;;;; (host-tested: tests/duel-rules/lhud-menu.lisp checks the counts against the model's rows); menu.js, the reference, was removed
;;;; 2026-11-11 (`git show 562acb37:duel/web/menu.js`): this file is the one edited. Upper case where the CSS upper-cases (the display face's display tier is upper
;;;; case only). Faces for tools/sdf-bake.py: (kj "…") Mincho, (bigkj "…") Mincho display tier, (zh "…") the sans; untagged = ASCII.
(in-package :duel)

(defparameter *lm-modes*
  ;; menu.js MODES: (EN ZH KANJI SEAL TEXT META), in *MODE-ROWS*' order
  (vector (list "VS CPU" (zh "對戰電腦") (bigkj "対戦") (kj "戦") (zh "選一位角色，和電腦一對一。三種難度，電腦依你的指針與距離出招。")
                (list "1 PLAYER" (zh "EASY · NORMAL · HARD")))
          (list "PRACTICE" (zh "練習") (bigkj "稽古") (kj "稽")
                (zh "和假人練習：暫停選單裡可以讓假人反擊、無限量表。練 NS 的節奏和毀魂技的按住時機。") (list "1 PLAYER" "DUMMY"))
          (list "VS PLAYER" (zh "雙人對戰") (bigkj "決闘") (kj "闘") (zh "兩個人在同一台電腦上對戰：一人用鍵盤，一人用手把，或兩支手把。")
                (list "2 PLAYERS" "KEYBOARD / PAD"))
          (list "CPU VS CPU" (zh "觀戰") (bigkj "観戦") (kj "観") (zh "看兩個電腦對打，觀察三角相剋：哪一招會被抵銷，哪一招能吃掉對方。")
                (list "SPECTATE"))
          (list "SETTINGS" (zh "設定") (bigkj "設定") (kj "設")
                (zh "單手模式、慣用手、滑動靈敏度、鏡頭、學習型電腦（可重置）、Hoho 提示與音量。") (list "7 OPTIONS"))
          (list "CONTROLS" (zh "操作") (bigkj "操作") (kj "操") (zh "鍵盤與手把的按鍵，可以重新綁定；手機上是單手手勢的說明。")
                (list "KEYBOARD" "PAD" "TOUCH"))
          (list "MANUAL" (zh "說明書") (bigkj "指南") (kj "書") (zh "完整的遊戲說明（在這個視窗打開，說明書的返回連結會回到這裡）。")
                (list "MANUAL"))))

(defparameter *lm-cards*
  ;; menu.js FIGHTERS by roster index: (EN JP EMBLEM TAGLINE ((THEME ZH) x3)); CARDS = *LM-CARD-ORDER*
  (list (cons 1 (list "KENPACHI" (kj "更木剣八") (bigkj "剣") (zh "吃招換招、越打越強的血戰狂人。靈壓是黃色的，所有型態都一樣。")
                      (list (list "HEAVY" (zh "AS1 搶走對手的瞬步")) (list "LAUNCH" (zh "AS2 把人擊飛")) (list "FINISHER" (zh "AS3 高傷害")))))
        (cons 3 (list "ICHIGO" (kj "黒崎一護") (bigkj "月") (zh "雙刀近身猛攻。三個指針各一個主題，卍解後換成血鎖、黑色月牙和分身。")
                      (list (list "THE CLEAVER" (zh "大刀之重 · 落牙")) (list "GETSUGA" (zh "月牙蓄力 · 十字衝")) (list "THE RUSH" (zh "亂月 → 月落")))))
        (cons 7 (list "HISAGI" (kj "檜佐木修兵") (bigkj "風") (zh "鎖鏈連著兩把鐮刀的中距離全能型；卍解後垂鏈遠距抽打，鎖住對手就換成近身捆綁戰。")
                      (list (list "HEAVY" (zh "AS1 搶走對手的瞬步")) (list "LAUNCH" (zh "AS2 把人擊飛")) (list "FINISHER" (zh "AS3 高傷害")))))))
(defparameter *lm-card-order* #(1 3 7) "menu.js CARDS: the cards left to right (roster indices).")
(defun lm-card (r) "The card of roster index R, or NIL." (cdr (assoc r *lm-cards*)))
(defun lm-card-name (r) "The card's name of roster index R, or the dash." (or (first (lm-card r)) (zh "—")))
(defparameter *lm-diffs* #("EASY" "NORMAL" "HARD"))

(defparameter *lm-settings*
  ;; menu.js SETTINGS: (EN OPTIONS DROPS HELP), in SETTINGS-SHOWN's order (control.lisp *SETTINGS* less the hidden rows)
  (vector (list "ONE-HAND" #("AUTO" "ON" "OFF") nil (zh "AUTO：用觸控手機直拿時自動切成單手模式。"))
          (list "HAND" #("LEFT" "RIGHT") nil (zh "拇指操作區在哪一側。手機上的選單也會換到那一側。"))
          (list "SENSITIVITY" #("1" "2" "3" "4" "5") t (zh "越高，越短的滑動就算 Step。預設 3（28 CSS px）。"))
          (list "CAMERA" #("BEHIND" "SIDE") nil (zh "VS CPU 與練習、雙手操作時的鏡頭。"))
          (list "LEARNING CPU" #("ON" "OFF") nil (zh "對戰電腦（困難）：電腦會學你的習慣，每場結束後記下來，存在這台裝置上。"))
          (list "PERFECT HINT" #("OFF" "ON") nil (zh "現在 Hoho 會是完美閃避時，頭上出現 HOHO!。"))
          (list "VOLUME" #("0" "1" "2" "3" "4" "5") t (zh "音樂和音效的總音量。0 是靜音，預設 5（最大聲）。"))))
(defparameter *lm-set-extra*
  (vector (list "RESET LEARNING" (zh "清除電腦學到的習慣，從頭開始。")) (list "BACK" nil))
  "The two action rows after the settings (menu.js .set.back).")

(defparameter *lm-binds*
  ;; menu.js BINDS: (EN SMALL), *BIND-ACTIONS*' order; then RESET DEFAULTS and BACK
  (vector (list "MOVE UP" (zh "移動")) (list "MOVE DOWN" (zh "移動")) (list "MOVE LEFT" (zh "移動")) (list "MOVE RIGHT" (zh "移動"))
          (list "ATTACK" (zh "加 Shift 是 SP")) (list "STEP" (zh "加 Shift 是 Hoho")) (list "FUNCTION" (zh "功能鍵")) (list "BURST" (zh "加 Shift 是覺醒"))
          (list "RESET DEFAULTS" (zh "這一欄回到預設")) (list "BACK" (zh "回到模式選單"))))
(defparameter *lm-keys*
  (coerce (append (loop for c across "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" collect (string c))
                  '("SPACE" "ENTER" "TAB" "BACKSPACE" "-" "=" "[" "]" ";" "'" "`" "," "." "/" "\\" "CAPSLOCK" "INSERT" "HOME" "PAGEUP"
                    "DELETE" "END" "PAGEDOWN" "UP" "DOWN" "LEFT" "RIGHT" "KP0" "KP1" "KP2" "KP3" "KP4" "KP5" "KP6" "KP7" "KP8" "KP9"
                    "KP /" "KP *" "KP -" "KP +" "KP ENTER" "KP ." "SHIFT" "RSHIFT" "CTRL" "RCTRL" "ALT" "RALT" "F1" "F2" "F3" "F4" "F5"
                    "F6" "F7" "F8" "F9" "F10" "F11" "F12"))
          'simple-vector)
  "menu.js KEYS: the names of *BIND-KEYS* (the model's V50-57 = 1 + the place).")
(defparameter *lm-pads* #("A" "B" "X" "Y" "LB" "RB" "LT" "RT" "LS" "RS" "BACK" "D-UP" "D-DOWN" "D-LEFT" "D-RIGHT") "menu.js PADS.")
(defun lm-bind-name (code pad)
  "menu.js bindName: the name of binding CODE (1-based) in the keys' or the pads' list, else the dash."
  (let* ((l (if pad *lm-pads* *lm-keys*))) (if (< 0 code (1+ (length l))) (svref l (1- code)) (zh "—"))))
(defparameter *lm-cols* (vector (zh "P1 · KEYS") (zh "P1 · PAD") (zh "P2 · KEYS") (zh "P2 · PAD")) "menu.js COLS.")
(defparameter *lm-kbd-rows* '(("Q" "W" "E" "R" "T" "Y" "U" "I" "O" "P") ("A" "S" "D" "F" "G" "H" "J" "K" "L") ("SHIFT" "Z" "X" "C" "V" "B" "N" "M"))
  "menu.js buildKbd's three rows of caps (640 x 196 viewBox; 40 px caps 6 apart, rows indented 18, SHIFT 70 wide; then SPACE).")

(defparameter *lm-rmenu* (vector (list "REMATCH" (zh "再戰") (kj "再")) (list "CHARACTER SELECT" (zh "換角色") (kj "選")) (list "TITLE" (zh "回到標題") (kj "題")))
  "menu.js RMENU: RESULTS' rows (EN ZH SEAL).")
(defparameter *lm-screens* (vector nil (cons (kj "魂") "TITLE") (cons (kj "道") "MODE") (cons (kj "設") "SETTINGS") (cons (kj "操") "CONTROLS")
                                   (cons (kj "選") "SELECT") (cons (kj "勝") "RESULTS"))
  "menu.js SCREENS: the crumb's kanji and word by screen code (V0).")

(defparameter *lm-title-sub* (vector (zh "攻擊與 SP 的三角相剋") (zh "按住 SP 接毀魂技")) "TITLE's .t-sub.")
(defparameter *lm-title-vert* (kj "一対一・死神の決闘") "TITLE's vertical line (.t-vert).")
(defparameter *lm-set-p* (zh "改動立刻生效，並存在這台裝置上。左右鍵或點選項切換；在手機上切換 HAND，選單會換邊。") "SETTINGS' side text.")
(defparameter *lm-ctl-p* (zh "兩顆戰鬥鍵：攻擊 J，加上功能鍵 Shift 就是 SP。沒有防禦；深度在出手和換招的時機。選一列再按新的鍵（或手把按鈕）即可改綁定。")
  "CONTROLS' side text, keys.")
(defparameter *lm-ctl-p-phone* (zh "手機是單手觸控：一隻拇指負責移動、步法、攻擊與 SP。點一下回到選單。") "CONTROLS' side text, the phone.")
(defparameter *lm-combos* (vector (cons "J" "SP") (cons " " (zh "Hoho 閃步")) (cons "P" (zh "覺醒")))
  "CONTROLS' .combos: ⇧ + the cap (\" \" = the space glyph ␣, a shape) and the word.")

(defparameter *lm-phone*
  ;; menu.js PHONE_SVG's texts (560 x 330 viewBox): (X Y CLASS STRING); class :big 22px display, :zh 11px sans, :mono 12px mono,
  ;; :red the mono in blood
  (list (list 318 64 :big "SP") (list 318 86 :zh (zh "上半：點擊 = SP")) (list 318 140 :zh (zh "出招中按住 = 毀魂技"))
        (list 318 196 :big "ATTACK") (list 318 218 :zh (zh "下半：點擊 = 攻擊"))
        (list 32 64 :big "GESTURES") (list 32 102 :mono "FLICK") (list 132 102 :zh (zh "Step 步法"))
        (list 32 134 :mono "REST + UP") (list 132 134 :zh (zh "Hoho 閃步（停一下再上滑）")) (list 32 166 :mono "DRAG") (list 132 166 :zh (zh "移動"))
        (list 32 198 :mono "DOWN, HIT") (list 132 198 :zh (zh "被打時下滑 = 爆氣")) (list 32 250 :red (zh "RV · AWK"))
        (list 132 250 :zh (zh "角落的兩顆圓鈕：爆氣、覺醒")) (list 32 290 :zh (zh "在出招中，手指停 40 ms 就算按下；在中立時，放開才出招。"))))

(defparameter *lm-sel-who* (vector (vector "P1 · YOU" "CPU") (vector "P1 · YOU" "DUMMY") (vector "P1" "P2") (vector "CPU 1" "CPU 2"))
  "SELECT's slot captions by mode (V6).")
(defun lm-sel-title (ph mode)
  "SELECT's heading for phase PH and mode MODE (menu.js renderSelect)."
  (case ph
    (0 (if (= mode 3) "CHOOSE THE FIRST CPU" "CHOOSE YOUR FIGHTER"))
    (1 (case mode (2 "PLAYER 2, CHOOSE") (1 "CHOOSE THE DUMMY") (3 "CHOOSE THE SECOND CPU") (t "CHOOSE THE CPU")))
    (t "READY")))
