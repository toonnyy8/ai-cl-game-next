# RAVEN EDGE

用 Common Lisp 寫的網頁 3D 動作遊戲，玩法參考《忍者外傳 4》（Ninja Gaiden 4），同時也是一份教材：它示範怎麼用 Lisp 做一個小型遊戲引擎，再用這個引擎做出一款完整的遊戲；之後又用同一個引擎做了第二款、類型完全不同的格鬥遊戲 SOUL DUEL（見根目錄的 [README.md](../../README.md)）。

Lisp 原始碼先由 ECL 編成 C，再由 Emscripten 編成 WebAssembly，在瀏覽器裡執行。畫面透過 SDL3 的 SDL_GPU（WebGPU 後端）繪製。所有模型都是程式產生的低面數幾何，音效和配樂在啟動時即時合成，整個專案沒有任何美術或音訊素材檔。

舞台是下著血色雨的近未來都市頂樓。你扮演最後一名忍者 REN，連砍三波「雨之軍團」，最後對上頭目 ENRA。

![REN 揮刀連斬，命中處噴出血霧，右側是連擊數](../../tests/shots/gpu-wave-2.png)

| 標題畫面 | 結算畫面 |
|---|---|
| ![標題畫面：霓虹招牌、雨中的頂樓](../../tests/shots/gpu-title.png) | ![MISSION COMPLETE 結算與 S 評價](../../tests/shots/e2-results.png) |

截圖都是無頭 Chrome（SwiftShader 軟體算圖）在 1280×720 下自動拍的，檔案在 `tests/shots/`。`gpu-*` 是現在的 SDL_GPU 版；`e2-*` 與 `webgl-*` 是改用 SDL_GPU 之前的 WebGL2 版，兩者畫面一致。

## 建置與執行

```sh
./build.sh                                   # 建出 dist/game/（裸的 ./build.sh 只建 RAVEN EDGE）
python3 -m http.server -d dist/game 8000     # 用 Chrome 開 http://localhost:8000/
```

`dist/game/` 只有 `index.html`、`index.js`、`index.wasm` 三個檔案。第一次點擊或按鍵之後才會有聲音（瀏覽器的自動播放限制）。

## 測試

```sh
node tools/run.mjs dist/game --secs 12 --shot out.png      # 無頭 Chrome 跑 12 秒並截圖
python3 tests/scripts/e2.py                                # 產生情境腳本 tests/scripts/e2-*.json
node tools/run.mjs dist/game --secs 30 --script tests/scripts/e2-grunt.json
tools/pkgcheck.sh game
$E --norc --load tests/rules-test.lisp                     # 規則（E 是 host ECL，見根目錄 README 的「需求」）
python3 tests/style-gates.py raven BASE dist/game          # G1：標題與一波 bot 對戰的畫面和改版前（BASE）比對
```

測試腳本由 `tests/scripts/` 的 `gen.py`（玩家招式）、`e2.py`（敵人與遊戲流程）、`p3.py`（各畫面與長時間浸泡測試）和 `gpu.py`（SDL_GPU 版的截圖組）產生。腳本透過 `Module._debug_cmd(n)` 跳到指定波次、強制敵人出某一招、開無敵，或讓自動遊玩的 bot 從頭打到尾。指令清單在 [GAMEPLAY.md](GAMEPLAY.md)。

## 遊戲內容

一輪流程是：標題 → 開場 → 第 1～3 波 → 頭目 → 勝利 → 結算，大約 5～10 分鐘。

- 第 1 波「THE RAIN LEGION」：4 名 RAINBLADE 劍兵。
- 第 2 波「NEEDLES IN THE DARK」：劍兵加上 NEEDLER（丟苦無的遠程兵），後面還有增援。
- 第 3 波「THE OX WALKS」：巨漢 OXHEAD 帶著劍兵和苦無兵，一樣有增援。
- 頭目「ENRA, THE CRIMSON GENERAL」：兩階段。血量掉到 50% 會怒吼、下起更濃的血雨，招式變快，還會多出跳砸和召喚。

每波清完回 25% 血並存檢查點；死掉可以選 RETRY WAVE 從這一波重來（評價上限變成 A）。標題選單另有 TRAINING，是放了三個假人的練習場。

主要系統：

- 連段。輕攻擊 L1～L5、重攻擊 H1～H3，中途插重攻擊會分出挑空技 Rising Crow、迴旋斬 Crescent Sweep、亂舞 Raven Rain；跑步中按輕攻擊是突刺 Gale Thrust。空中有三段空斬，另外有三種空中重攻擊，依狀況自動選一種：抓住浮空敵人往下摔的 Thunderfall、飛身斬 Kestrel Strike、下墜斬 Plunge。
- 防禦與格擋。按住 Q 擋住正面的一般攻擊，但防禦值會被削，歸零就破防。敵人攻擊命中前 8 幀內剛按下 Q 就是格擋，對方會踉蹌，接著可以反擊（Riposte）。
- Just Dodge。閃避前 10 幀內擦過敵人的判定，敵人會進入 0.3 倍慢動作 0.5 秒，這段時間按攻擊會瞬移過去反砍（Mirage Counter）。
- Raven 量表與 Raven 型態。打中敵人、格擋、Just Dodge、擊殺都會累積量表。到 40 以上按 E 發動 Raven Burst，進入 Raven 型態：刀身變成血色長刃，傷害 ×1.5、可以破防，重攻擊變成貫穿的 Crimson Lance。量表每秒掉 10。
- 紅色攻擊。敵人全身發紅、地上出現紅圈，表示這招擋不住也不能格擋。對策只有閃掉、趁蓄力時用 Raven 型態打斷（Raven Break），或是在 Raven 型態下花 15 量表硬擋（Raven Guard）。
- 打殘與 Obliterate。重攻擊把敵人打到 30% 血以下（OXHEAD 是 25%）會斷手，頭上跳出 `OBLITERATE [K]`。這時按重攻擊就是一刀兩斷的處決技：全程無敵，量表 +25，還會噴出光球（3 顆藍的共回 12 點血，2 顆金的補量表）。放著不管的話，殘兵會爬過來發動紅色的 Death Grip。頭目不會被打殘，血量歸零時跪地，只能用 Obliterate 收尾。

每一下命中都有停頓（hitstop）、血霧、鏡頭震動和音效。完整的數值和幀數表在 [docs/raven-edge/GAME_DESIGN.md](GAME_DESIGN.md)。

## 操作說明

以下按鍵對照 `game/lisp/player.lisp`、`game/lisp/game.lisp` 和遊戲內 CONTROLS 畫面（`game/lisp/hud.lisp`）確認過。

### 鍵盤＋滑鼠

| 動作 | 按鍵 | 備註 |
|---|---|---|
| 移動 | W A S D | 相對於鏡頭方向，鍵盤一律是跑步 |
| 轉鏡頭 | 滑鼠、方向鍵 | 滑鼠要先點一下畫面鎖定游標才有作用（這一下不算攻擊）；方向鍵 150°/s |
| 輕攻擊 | J／滑鼠左鍵 | |
| 重攻擊 | K／滑鼠右鍵 | 敵人被打殘時，這顆鍵就是 OBLITERATE |
| 跳躍 | Space | |
| 閃避 | Shift（左右皆可）／L | 沒有方向輸入時往後閃 |
| 防禦 | Q（按住） | 剛按下的那一瞬間算格擋（parry） |
| Raven Burst／解除 Raven 型態 | E | 量表 ≥ 40 才能發動 |
| 暫停 | Enter／Esc | 戰鬥中視窗失焦或游標鎖定被解除（例如按 Esc）會自動暫停 |
| 選單 | ↑↓ 或 W/S 移動，Enter／J／Space 確認 | CONTROLS 畫面按 Esc 或 Backspace 返回；GAME OVER 畫面前 0.6 秒不接受輸入 |
| 除錯 | F3 | 只在開發模式有效（呼叫過 `Module._debug_cmd` 之後）：顯示 FPS、每幀配置量、狀態、判定框 |
| 訓練場 | T | 切換假人會不會反擊（只在 TRAINING 有效） |

### 手把（SDL 標準配置）

| 動作 | 按鍵 |
|---|---|
| 移動／鏡頭 | 左搖桿／右搖桿 |
| 輕攻擊／重攻擊 | X（□）／Y（△） |
| 跳躍／閃避 | A（✕）／B（○） |
| 防禦 | RT（R2）按住，按下瞬間算格擋 |
| Raven Burst | LT（L2） |
| 暫停 | Start |
| 選單 | 十字鍵上下，A 確認，B 返回（暫停中 B／Start 繼續） |

設計文件裡的鎖定（Tab / F / R3）已經砍掉，目前只有自動軟鎖定，Tab 按了沒反應。
