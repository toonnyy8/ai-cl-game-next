// menu.js — SOUL DUEL's HTML menus (docs/duel/DUEL_WEBUI.md; the look from the design draft 「SOUL DUEL Menus」, 2026-10-28).
// It only draws: Lisp (duel/lisp/webui.lisp) publishes the state through gamePage.set(30000 + k, v) and owns every decision and
// every key and pad press. A pointer or touch on a row queues a command, read by Lisp through gamePage.get(30001):
// screen * 100000 + cmd * 1000 + arg (1 cursor, 2 confirm, 3 back, 4 left, 5 right, 6 pick, 7 a setting's option, 8 a controls
// column). Two layers: #ui-back under the canvas (SELECT's card fills and kanji), #ui over it.
(function () {
  "use strict";
  var V = [], queue = [], dirty = true, built = false, shown = 0, input = "keys";
  var reduced = !!(window.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches);
  for (var i = 0; i < 100; i++) V.push(-1);

  /* ---------------------------------------------------------------- the game's own data */
  var MODES = [
    { en: "VS CPU", zh: "對戰電腦", k: "対戦", seal: "戦", text: "選一位角色，和電腦一對一。三種難度，電腦依你的指針與距離出招。", meta: ["1 PLAYER", "EASY · NORMAL · HARD"] },
    { en: "Practice", zh: "練習", k: "稽古", seal: "稽", text: "和假人練習：暫停選單裡可以讓假人反擊、無限量表。練 NS 的節奏和毀魂技的按住時機。", meta: ["1 PLAYER", "DUMMY"] },
    { en: "VS Player", zh: "雙人對戰", k: "決闘", seal: "闘", text: "兩個人在同一台電腦上對戰：一人用鍵盤，一人用手把，或兩支手把。", meta: ["2 PLAYERS", "KEYBOARD / PAD"] },
    { en: "CPU vs CPU", zh: "觀戰", k: "観戦", seal: "観", text: "看兩個電腦對打，觀察三角相剋：哪一招會被抵銷，哪一招能吃掉對方。", meta: ["SPECTATE"] },
    { en: "Settings", zh: "設定", k: "設定", seal: "設", text: "單手模式、慣用手、滑動靈敏度、鏡頭與 Hoho 提示。", meta: ["5 OPTIONS"] },
    { en: "Controls", zh: "操作", k: "操作", seal: "操", text: "鍵盤與手把的按鍵，可以重新綁定；手機上是單手手勢的說明。", meta: ["KEYBOARD", "PAD", "TOUCH"] },
    { en: "Manual", zh: "說明書", k: "指南", seal: "書", text: "完整的遊戲說明（在這個視窗打開，說明書的返回連結會回到這裡）。", meta: ["MANUAL"] }
  ];
  var FIGHTERS = {   // roster index (kit.lisp *ROSTER*) -> card
    1: { en: "Kenpachi", jp: "更木剣八", emb: "剣", tag: "吃招換招、越打越強的血戰狂人。靈壓是黃色的，所有型態都一樣。",
         ptr: [["Heavy", "AS1 搶走對手的瞬步"], ["Launch", "AS2 把人擊飛"], ["Finisher", "AS3 高傷害"]] },
    3: { en: "Ichigo", jp: "黒崎一護", emb: "月", tag: "雙刀近身猛攻。三個指針各一個主題，卍解後換成血鎖、黑色月牙和分身。",
         ptr: [["The cleaver", "大刀之重 · 落牙"], ["Getsuga", "月牙蓄力 · 十字衝"], ["The rush", "亂月 → 月落"]] },
    7: { en: "Hisagi", jp: "檜佐木修兵", emb: "風", tag: "鎖鏈連著兩把鐮刀的中距離全能型；卍解後垂鏈遠距抽打，鎖住對手就換成近身捆綁戰。",
         ptr: [["Heavy", "AS1 搶走對手的瞬步"], ["Launch", "AS2 把人擊飛"], ["Finisher", "AS3 高傷害"]] }
  };
  var CARDS = [1, 3, 7], DIFFS = ["Easy", "Normal", "Hard"];
  var SETTINGS = [   // control.lisp *SETTINGS* as shown (flow.lisp SETTINGS-SHOWN), then BACK
    { en: "One-hand", opts: ["Auto", "On", "Off"], help: "AUTO：用觸控手機直拿時自動切成單手模式。" },
    { en: "Hand", opts: ["Right", "Left"], help: "拇指操作區在哪一側。手機上的選單也會換到那一側。" },
    { en: "Sensitivity", opts: ["1", "2", "3", "4", "5"], drops: true, help: "越高，越短的滑動就算 Step。預設 3（28 CSS px）。" },
    { en: "Camera", opts: ["Behind", "Side"], help: "VS CPU 與練習、雙手操作時的鏡頭。" },
    { en: "Perfect hint", opts: ["Off", "On"], help: "現在 Hoho 會是完美閃避時，頭上出現 HOHO!。" }
  ];
  var BINDS = [["Move up", "移動"], ["Move down", "移動"], ["Move left", "移動"], ["Move right", "移動"],
               ["Attack", "加 Shift 是 SP"], ["Step", "加 Shift 是 Hoho"], ["Function", "功能鍵"], ["Burst", "加 Shift 是覺醒"]];
  var KEYS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".split("").concat(["SPACE", "ENTER", "TAB", "BACKSPACE", "-", "=", "[", "]", ";", "'", "`",
    ",", ".", "/", "\\", "CAPSLOCK", "INSERT", "HOME", "PAGEUP", "DELETE", "END", "PAGEDOWN", "UP", "DOWN", "LEFT", "RIGHT",
    "KP0", "KP1", "KP2", "KP3", "KP4", "KP5", "KP6", "KP7", "KP8", "KP9", "KP /", "KP *", "KP -", "KP +", "KP ENTER", "KP .",
    "SHIFT", "RSHIFT", "CTRL", "RCTRL", "ALT", "RALT", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"]);
  var PADS = ["A", "B", "X", "Y", "LB", "RB", "LT", "RT", "LS", "RS", "BACK", "D-UP", "D-DOWN", "D-LEFT", "D-RIGHT"];
  var COLS = ["P1 · Keys", "P1 · Pad", "P2 · Keys", "P2 · Pad"];
  var RMENU = [{ en: "Rematch", zh: "再戰", seal: "再" }, { en: "Character select", zh: "換角色", seal: "選" }, { en: "Title", zh: "回到標題", seal: "題" }];
  var SCREENS = { 1: ["title", "魂", "Title"], 2: ["mode", "道", "Mode"], 3: ["settings", "設", "Settings"], 4: ["controls", "操", "Controls"],
                  5: ["select", "選", "Select"], 6: ["results", "勝", "Results"] };
  var BRUSH = '<span class="brush" aria-hidden="true"><svg><use href="#brush"/></svg></span>';

  /* ---------------------------------------------------------------- the bridge (pwa.js routes 30000+ here) */
  function send(cmd, arg) { if (V[0] > 0) queue.push(V[0] * 100000 + cmd * 1000 + (arg | 0)); }
  var spot = [0, 0];
  globalThis.gameUI = {
    get: function (k) {
      if (k === 0) return 1;
      if (k === 1) return queue.length ? queue.shift() : 0;
      if (k === 2 || k === 3) return spot[k - 2];
      return 0;
    },
    set: function (k, v) { if (V[k] !== v) { V[k] = v; dirty = true; if (k === 0) queue.length = 0; } }
  };
  function focusGame() { var c = document.getElementById("canvas"); if (c && document.activeElement !== c) c.focus({ preventScroll: true }); }

  /* ---------------------------------------------------------------- building */
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };
  function rowHTML(o, i) {
    return '<div class="row" data-i="' + i + '">' + BRUSH + '<span class="lbl"><span class="en">' + o.en + '</span><span class="zh">' + o.zh +
      '</span></span><span class="seal" aria-hidden="true">' + o.seal + '</span></div>';
  }
  function cardHTML(r) {
    var f = FIGHTERS[r];
    return '<div class="fighter" data-c="' + r + '" data-i="' + r + '"><span class="emb" aria-hidden="true">' + f.emb + '</span>' +
      '<span class="stand"></span><span class="body"><span class="jp">' + f.jp + '</span><span class="name">' + f.en + '</span>' +
      '<span class="more"><span class="tagline">' + f.tag + '</span><span class="ptrs">' +
      f.ptr.map(function (p, j) { return '<span class="ptr"><span class="n">0' + (j + 1) + '</span><span class="th">' + p[0] + '</span><span class="zh">' + p[1] + '</span></span>'; }).join("") +
      '</span></span></span><span class="pick" aria-hidden="true">' + f.emb + '</span></div>';
  }
  var SVG_DEFS = '<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>' +
    '<filter id="torn" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency=".035 .06" numOctaves="3" seed="4" result="n"/>' +
    '<feDisplacementMap in="SourceGraphic" in2="n" scale="7" xChannelSelector="R" yChannelSelector="G"/></filter>' +
    '<filter id="dry" x="-3%" y="-20%" width="106%" height="140%"><feTurbulence type="fractalNoise" baseFrequency=".012 .22" numOctaves="2" seed="9" result="n"/>' +
    '<feDisplacementMap in="SourceGraphic" in2="n" scale="5" xChannelSelector="R" yChannelSelector="G"/></filter>' +
    '<linearGradient id="tail" x1="0" x2="1" y1="0" y2="0"><stop offset="0" stop-color="#eeeeea"/><stop offset=".86" stop-color="#eeeeea"/><stop offset="1" stop-color="#eeeeea" stop-opacity="0"/></linearGradient>' +
    '<symbol id="brush" viewBox="0 0 600 60" preserveAspectRatio="none"><g filter="url(#dry)">' +
    '<path fill="url(#tail)" d="M10,30 C14,13 60,8 150,8 C290,7 430,9 560,13 C580,14 596,20 598,29 C597,38 584,44 560,46 C430,52 290,53 150,52 C64,52 16,48 10,30 Z"/>' +
    '<path fill="#eeeeea" opacity=".55" d="M520,10 C560,9 590,11 600,14 L600,17 C584,15 556,14 520,14 Z"/>' +
    '<path fill="#eeeeea" opacity=".45" d="M500,48 C548,49 584,48 600,45 L600,48 C584,52 548,53 500,52 Z"/></g></symbol></defs></svg>';

  function selectHTML() {
    return '<section class="screen" id="s-select"><div class="sel-head"><div><div class="eyebrow">FIGHTERS · 3 PLAYABLE</div><h2 id="sel-title">Choose your fighter</h2></div>' +
      '<div class="slots"><div class="slot" id="slot-a"><span class="eyebrow">P1 · YOU</span><b>—</b></div><div class="slot" id="slot-b"><span class="eyebrow">CPU</span><b>—</b></div></div></div>' +
      '<div class="fighters">' + CARDS.map(cardHTML).join("") + '</div>' +
      '<div class="sel-foot"><div class="diff" id="diff"><span class="eyebrow">DIFFICULTY</span>' +
      DIFFS.map(function (d, i) { return '<span class="opt" data-d="' + i + '">' + d + '</span>'; }).join("") + '</div>' +
      '<div class="diff" id="camopt"><span class="eyebrow">CAMERA</span><span class="opt" data-cam="1">Behind</span><span class="opt" data-cam="0">Side</span></div>' +
      '<span class="press go" id="sel-go"><span class="dot"></span><span>START</span></span></div></section>';
  }

  function build() {
    if (built || !document.body) return;
    built = true;
    document.body.insertAdjacentHTML("beforeend", SVG_DEFS +
      '<div id="ui-back" aria-hidden="true"><div class="world"></div>' + selectHTML() + '</div>' +
      '<div id="ui"><div class="wash"></div><canvas id="ash" aria-hidden="true"></canvas>' +
      '<header class="rail top"><div class="mark"><i></i>SOUL DUEL</div><div class="crumb"><span id="crumb-en"></span><b id="crumb-k"></b></div></header>' +
      '<main>' +
      '<section class="screen" id="s-title"><div class="t-left"><h1 class="wordmark" aria-label="SOUL DUEL"><span>SOUL</span><span>DUEL</span><i class="slash x" aria-hidden="true"></i></h1>' +
      '<div class="t-sub"><span>攻擊與 SP 的三角相剋</span><span>按住 SP 接毀魂技</span></div>' +
      '<span class="press" id="press"><span class="dot"></span><span id="press-txt">PRESS J</span></span></div>' +
      '<div class="t-kanji" aria-hidden="true"><p class="big-kanji">魂</p><span class="t-vert">一対一・死神の決闘</span></div></section>' +
      '<section class="screen" id="s-mode"><div class="m-hero"><p class="m-kanji" id="m-kanji" aria-hidden="true"></p><div class="m-desc paper">' +
      '<div class="eyebrow" id="m-eyebrow"></div><h2 id="m-title"></h2><p id="m-text"></p><div class="meta" id="m-meta"></div></div></div>' +
      '<nav class="list" id="mode-list">' + MODES.map(rowHTML).join("") + '</nav></section>' +
      '<section class="screen" id="s-settings"><div class="side-title"><span class="k">設定</span><h1>Settings</h1><p>改動立刻生效，並存在這台裝置上。左右鍵或點選項切換；在手機上切換 HAND，選單會換邊。</p></div>' +
      '<div class="setlist" id="setlist">' + SETTINGS.map(function (s, i) {
        return '<div class="set" data-i="' + i + '"><span class="lab">' + s.en + '</span><span class="choices"><span class="arrow" data-d="-1">◀</span>' +
          (s.drops ? '<span class="drops">' + s.opts.map(function (o, j) { return '<i data-j="' + j + '" style="height:' + (10 + j * 4) + 'px"></i>'; }).join("") + '</span>'
                   : s.opts.map(function (o, j) { return '<span class="opt" data-j="' + j + '">' + o + '</span>'; }).join("")) +
          '<span class="arrow" data-d="1">▶</span></span><span class="help">' + s.help + '</span></div>';
      }).join("") + '<div class="set back" data-i="5"><span class="lab">Back</span><span class="choices"></span></div></div></section>' +
      '<section class="screen" id="s-controls"><div class="side-title"><span class="k">操作</span><h1>Controls</h1><p id="ctl-p">兩顆戰鬥鍵：攻擊 J，加上功能鍵 Shift 就是 SP。沒有防禦；深度在出手和換招的時機。選一列再按新的鍵即可改綁定。</p></div>' +
      '<div class="ctl-body"><div id="ctl-keys"><div class="tabs" id="ctl-tabs">' + COLS.map(function (c, i) { return '<span class="opt" data-col="' + i + '">' + c + '</span>'; }).join("") + '</div>' +
      '<svg class="kbd" viewBox="0 0 640 196" id="kbd" aria-label="Keyboard map"></svg>' +
      '<div class="combos"><span><span class="key">⇧</span>+<span class="key">J</span> SP</span><span><span class="key">⇧</span>+<span class="key">␣</span> Hoho 閃步</span><span><span class="key">⇧</span>+<span class="key">P</span> 覺醒</span></div>' +
      '<div class="binds" id="binds" style="margin-top:14px"></div></div>' +
      '<div id="ctl-touch" hidden>' + PHONE_SVG + '</div></div></section>' +
      '<section class="screen" id="s-results"><div class="r-win"><span class="who" id="r-who"></span><p class="nm" id="r-name"></p>' +
      '<p class="r-over" id="r-over"></p><div class="hanko" aria-hidden="true">勝</div><div class="souls" id="souls"></div>' +
      '<div class="stats" id="stats"></div><nav class="r-menu" id="r-menu" style="margin-top:22px">' + RMENU.map(rowHTML).join("") + '</nav></div><div></div></section>' +
      '</main>' +
      '<div id="cut" aria-hidden="true"><div class="ink"></div><svg viewBox="0 0 100 100" preserveAspectRatio="none"><line x1="104" y1="-4" x2="-4" y2="104" pathLength="1" vector-effect="non-scaling-stroke"/></svg></div>' +
      '<footer class="rail bottom"><div class="hints" id="hints"></div><div class="proto"></div></footer></div>');
    $("#ui main").insertAdjacentHTML("beforeend", selectHTML());   // the front copy: same layout, the text
    bindPointer();
    startAsh();
  }
  var PHONE_SVG = '<svg class="phone" viewBox="0 0 560 330" aria-label="One-thumb pad"><rect x="1" y="1" width="558" height="328" rx="28" fill="#0e1016" stroke="#3a3f4e"/>' +
    '<rect x="300" y="34" width="232" height="128" rx="6" class="zone-hi"/><rect x="300" y="166" width="232" height="128" rx="6" class="zone-lo"/>' +
    '<text x="318" y="64" class="big">SP</text><text x="318" y="86" class="zh">上半：點擊 = SP</text><text x="318" y="140" class="zh">出招中按住 = 毀魂技</text>' +
    '<text x="318" y="196" class="big">ATTACK</text><text x="318" y="218" class="zh">下半：點擊 = 攻擊</text>' +
    '<g class="thumb"><circle cx="460" cy="250" r="22" fill="rgba(238,238,234,.18)" stroke="#eeeeea"/><path d="M460,232 l0,-26 m-7,8 l7,-8 l7,8" stroke="#eeeeea" stroke-width="2" fill="none"/></g>' +
    '<text x="32" y="64" class="big">GESTURES</text><text x="32" y="102">FLICK</text><text x="132" y="102" class="zh">Step 步法</text>' +
    '<text x="32" y="134">REST + UP</text><text x="132" y="134" class="zh">Hoho 閃步（停一下再上滑）</text><text x="32" y="166">DRAG</text><text x="132" y="166" class="zh">移動</text>' +
    '<text x="32" y="198">DOWN, HIT</text><text x="132" y="198" class="zh">被打時下滑 = 爆氣</text><text x="32" y="250" fill="#e81e3a">RV · AWK</text>' +
    '<text x="132" y="250" class="zh">角落的兩顆圓鈕：爆氣、覺醒</text><text x="32" y="290" class="zh">在出招中，手指停 40 ms 就算按下；在中立時，放開才出招。</text></svg>';

  /* ---------------------------------------------------------------- pointer and touch -> commands */
  function bindPointer() {
    var ui = $("#ui");
    ui.addEventListener("pointerdown", function (e) { input = e.pointerType === "touch" ? "touch" : "keys"; e.preventDefault(); focusGame(); });
    ui.addEventListener("pointerover", function (e) {
      if (e.pointerType !== "mouse") return;
      var r = e.target.closest("#mode-list .row, #r-menu .row, .set, .bind");
      if (r && !r.contains(e.relatedTarget) && +r.dataset.i !== V[1]) send(1, +r.dataset.i);
    });
    ui.addEventListener("click", function (e) {
      var t = e.target, el;
      if (V[11] !== 1 && (V[0] === 1 || V[0] === 6)) return;                       // Lisp's own timer: not yet
      if (V[0] === 1) { send(2); return; }
      if ((el = t.closest("#mode-list .row, #r-menu .row"))) { send(1, +el.dataset.i); send(2); return; }
      if ((el = t.closest(".set"))) {
        var i = +el.dataset.i, a = t.closest(".arrow"), o = t.closest("[data-j]");
        if (i === 5) { send(1, 5); send(2); }
        else if (a) { send(1, i); send(+a.dataset.d < 0 ? 4 : 5); }
        else if (o) send(7, i * 10 + (+o.dataset.j));
        else send(1, i);
        return;
      }
      if ((el = t.closest("#ctl-tabs .opt"))) { send(8, +el.dataset.col); return; }
      if ((el = t.closest(".bind"))) { send(1, +el.dataset.i); send(2); return; }
      if (V[0] === 4 && V[10] === 1) { send(2); return; }                           // the phone's gestures page: any tap returns
      if ((el = t.closest(".fighter"))) {
        var r = +el.dataset.c;
        if (V[2] < 2) { if (r !== curPick()) send(6, r); if (r === curPick() || input !== "touch") send(2); }
        return;
      }
      if ((el = t.closest("#diff .opt"))) { stepTo(0, +el.dataset.d, V[5]); return; }
      if ((el = t.closest("#camopt .opt"))) { if (+el.dataset.cam !== V[7]) { send(1, rowOf(2)); send(5); } return; }
      if (t.closest("#sel-go")) { send(2); return; }
    });
    addEventListener("keydown", function () { if (input !== "keys") { input = "keys"; dirty = true; } }, { passive: true });
    setInterval(function () {                                                        // a pad in use: its hints
      var pads = navigator.getGamepads ? navigator.getGamepads() : [];
      for (var i = 0; i < pads.length; i++) { var p = pads[i]; if (p && p.buttons.some(function (b) { return b.pressed; })) { if (input !== "pad") { input = "pad"; dirty = true; } } }
    }, 400);
  }
  function curPick() { return V[2] === 1 ? V[4] : V[3]; }
  function rowsOf() { var r = []; if (V[8] & 1) r.push(1); if (V[8] & 2) r.push(2); return r; }   // SELECT's last page: 1 difficulty, 2 camera
  function rowOf(kind) { return Math.max(0, rowsOf().indexOf(kind)); }
  function stepTo(kind, want, cur) {                                                // the difficulty: left / right presses
    send(1, rowOf(1)); var d = want - cur; while (d > 0) { send(5); d--; } while (d < 0) { send(4); d++; }
  }

  /* ---------------------------------------------------------------- drawing */
  function setFocus(list, i) { list.forEach(function (el, j) { el.classList.toggle("focus", j === i); }); }
  function renderTitle() {
    $("#press-txt").textContent = input === "touch" ? "TAP TO BEGIN" : input === "pad" ? "PRESS A" : "PRESS J";
  }
  function renderMode() {
    setFocus($$("#mode-list .row"), V[1]);
    var m = MODES[V[1]] || MODES[0], k = $("#m-kanji");
    if (k.textContent !== m.k) { k.textContent = m.k; k.classList.remove("swap"); void k.offsetWidth; k.classList.add("swap"); }
    $("#m-eyebrow").textContent = "MODE 0" + (V[1] + 1) + " / 0" + MODES.length;
    $("#m-title").textContent = m.en; $("#m-text").textContent = m.text;
    $("#m-meta").innerHTML = m.meta.map(function (t) { return '<span class="tag">' + t + '</span>'; }).join("");
  }
  function renderSettings() {
    var sets = $$(".set"); setFocus(sets, V[1]);
    sets.forEach(function (el, i) {
      if (i >= 5) return;
      var v = V[40 + i];
      $$(".opt", el).forEach(function (o, j) { o.classList.toggle("cur", j === v); });
      $$(".drops i", el).forEach(function (d, j) { d.classList.toggle("on", j <= v); d.classList.toggle("cur", j === v); });
    });
    $("#ui").classList.toggle("left", V[41] === 1);
  }
  function bindName(code, pad) { var l = pad ? PADS : KEYS; return code > 0 && code <= l.length ? l[code - 1] : "—"; }
  function renderControls() {
    var phone = V[10] === 1, col = V[9] % 10, cap = V[9] >= 10, pad = col % 2 === 1;
    $("#ctl-keys").hidden = phone; $("#ctl-touch").hidden = !phone;
    $("#ctl-p").textContent = phone ? "手機是單手觸控：一隻拇指負責移動、步法、攻擊與 SP。點一下回到選單。" :
      "兩顆戰鬥鍵：攻擊 J，加上功能鍵 Shift 就是 SP。沒有防禦；深度在出手和換招的時機。選一列再按新的鍵（或手把按鈕）即可改綁定。";
    if (phone) return;
    $$("#ctl-tabs .opt").forEach(function (o, i) { o.classList.toggle("cur", i === col); });
    var names = BINDS.map(function (b, i) { return bindName(V[50 + i], pad); });
    $("#binds").innerHTML = BINDS.map(function (b, i) {
      return '<div class="bind' + (i === V[1] ? " focus" : "") + (cap && i === V[1] ? " capturing" : "") + '" data-i="' + i + '"><span class="a">' + b[0] +
        '<small>' + b[1] + '</small></span><span class="key">' + (cap && i === V[1] ? "PRESS" : names[i]) + '</span></div>';
    }).join("") + '<div class="bind extra' + (V[1] === 8 ? " focus" : "") + '" data-i="8"><span class="a">Reset defaults<small>這一欄回到預設</small></span><span class="key">↺</span></div>' +
      '<div class="bind extra' + (V[1] === 9 ? " focus" : "") + '" data-i="9"><span class="a">Back<small>回到模式選單</small></span><span class="key">K</span></div>';
    buildKbd(pad ? [] : names, names);
  }
  function buildKbd(hotNames, names) {
    var W = 40, G = 6, rows = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["SHIFT", "Z", "X", "C", "V", "B", "N", "M"]];
    var hot = {}; hotNames.forEach(function (n) { hot[n] = 1; });
    var out = "", y = 8;
    rows.forEach(function (r, ri) {
      var x = 8 + ri * 18;
      r.forEach(function (k) {
        var w = k === "SHIFT" ? 70 : W;
        out += '<g class="cap' + (hot[k] ? " hot" : "") + (k === "SHIFT" ? " mod" : "") + '"><rect x="' + x + '" y="' + y + '" width="' + w + '" height="' + W + '" rx="4"/><text x="' + (x + w / 2) + '" y="' + (y + 25) + '" text-anchor="middle">' + k + '</text></g>';
        x += w + G;
      });
      y += W + G;
    });
    out += '<g class="cap' + (hot.SPACE ? " hot" : "") + '"><rect x="150" y="' + y + '" width="250" height="34" rx="4"/><text x="275" y="' + (y + 22) + '" text-anchor="middle">SPACE</text></g>';
    out += '<text class="lbl" x="482" y="25">' + names[7] + ' · BURST</text><text class="lbl" x="482" y="41">⇧ + ' + names[7] + ' · AWAKEN</text>' +
      '<text class="lbl" x="482" y="71">' + names[4] + ' · ATTACK</text><text class="lbl" x="482" y="87">⇧ + ' + names[4] + ' · SP</text>' +
      '<text class="lbl" x="482" y="125">' + names[6] + ' · FUNCTION</text><text class="lbl" x="482" y="160">' + names[5] + ' · STEP</text><text class="lbl" x="482" y="176">⇧ + ' + names[5] + ' · HOHO</text>';
    $("#kbd").innerHTML = out;
  }
  function renderSelect() {
    var ph = V[2], mode = V[6];
    var who = [["P1 · YOU", "CPU"], ["P1 · YOU", "DUMMY"], ["P1", "P2"], ["CPU 1", "CPU 2"]][mode] || ["P1", "CPU"];
    $$("#s-select").forEach(function (root) {
      $$(".fighter", root).forEach(function (c) {
        var r = +c.dataset.c, foc = ph >= 2 ? r === V[4] : r === curPick();
        c.classList.toggle("focus", foc);
        c.classList.toggle("picked", (ph >= 1 && r === V[3]) || (ph >= 2 && r === V[4]));
        c.classList.toggle("p1", ph >= 1 && r === V[3]);
      });
      $("#sel-title", root).textContent = ph === 0 ? "Choose " + (mode === 3 ? "the first CPU" : "your fighter") :
        ph === 1 ? (mode === 2 ? "Player 2, choose" : mode === 1 ? "Choose the dummy" : mode === 3 ? "Choose the second CPU" : "Choose the CPU") : "Ready";
      var a = $("#slot-a", root), b = $("#slot-b", root);
      $(".eyebrow", a).textContent = who[0]; $(".eyebrow", b).textContent = who[1];
      $("b", a).textContent = FIGHTERS[V[3]] ? FIGHTERS[V[3]].en : "—";
      $("b", b).textContent = ph >= 1 && FIGHTERS[V[4]] ? FIGHTERS[V[4]].en : "—";
      a.classList.toggle("active", ph === 0); b.classList.toggle("active", ph === 1);
      a.classList.toggle("done", ph >= 1); b.classList.toggle("done", ph >= 2);
      var rows = rowsOf(), last = ph >= 2;
      $("#diff", root).hidden = !last || !(V[8] & 1); $("#camopt", root).hidden = !last || !(V[8] & 2);
      $("#diff", root).classList.toggle("live", last && rows[V[1]] === 1);
      $("#camopt", root).classList.toggle("live", last && rows[V[1]] === 2);
      $$("#diff .opt", root).forEach(function (o, i) { o.classList.toggle("cur", i === V[5]); });
      $$("#camopt .opt", root).forEach(function (o) { o.classList.toggle("cur", +o.dataset.cam === V[7]); });
      $("#sel-go", root).hidden = !last;
    });
    measureSpot();
  }
  function measureSpot() {
    var c = $("#ui #s-select .fighter.focus");
    if (!c) return;
    var r = c.getBoundingClientRect(), text = $(".jp", c).getBoundingClientRect();   // (.body fills the card: its first line)
    var cx = r.left + r.width / 2, cy = r.top + (text.top - r.top) * 0.52;          // the empty part above the text
    if (innerWidth < 761) { cx = r.left + r.width * 0.74; cy = r.top + r.height * 0.5; }   // a phone: the cards stack, beside the text
    spot[0] = Math.round(1000 * cx / innerWidth); spot[1] = Math.round(1000 * cy / innerHeight);
  }
  function renderResults() {
    var w = V[20], win = w === 1 ? V[4] : V[3], lose = w === 1 ? V[3] : V[4], f = FIGHTERS[win];
    $("#r-who").textContent = w === 2 ? "DRAW · TIME UP" : "WINNER · " + (w === 1 ? "P2" : "P1") + " · K.O.";
    $("#r-name").textContent = w === 2 ? "Draw" : f ? f.en : "—";
    $("#r-over").innerHTML = w === 2 ? "" : "defeated <b>" + (FIGHTERS[lose] ? FIGHTERS[lose].en.toUpperCase() : "—") + "</b>";
    $(".hanko").hidden = w === 2;
    var o = w === 1 ? 27 : 22, kon = V[o + 4];
    var s = '<span class="eyebrow">KONPAKU 魂魄</span>';
    for (var i = 0; i < 9; i++) s += '<span class="soul' + (i >= kon ? " lost" : "") + '"></span>';
    $("#souls").innerHTML = s;
    var t = V[21];
    $("#stats").innerHTML = [["TIME", Math.floor(t / 60) + ":" + ("0" + (t % 60)).slice(-2), "/ 5:00"], ["BEST COMBO", V[o + 3], "HITS"],
      ["KIKON 毀魂技", V[o + 1], ""], ["PERFECT HOHO", V[o + 2], ""]].map(function (x) {
        return '<div class="stat"><span class="eyebrow">' + x[0] + '</span><b>' + x[1] + '<small>' + x[2] + '</small></b></div>';
      }).join("");
    setFocus($$("#r-menu .row"), V[1]);
  }
  function renderHints() {
    var k = input, scr = V[0], parts = [];
    var ok = k === "pad" ? "A" : k === "touch" ? "TAP" : "J", no = k === "pad" ? "B" : k === "touch" ? "BACK" : "K";
    if (scr !== 1) parts.push('<span class="h-move"><span class="key">' + (k === "pad" ? "✚" : "W S") + '</span>MOVE</span>');
    if (scr === 3 || scr === 5) parts.push('<span><span class="key">' + (k === "pad" ? "◀▶" : "A D") + '</span>CHANGE</span>');
    parts.push('<span><span class="key">' + ok + '</span>' + (scr === 1 ? "START" : "CONFIRM") + '</span>');
    if (scr !== 1) parts.push('<span class="h-back"><span class="key">' + no + '</span>BACK</span>');
    $("#hints").innerHTML = parts.join("");
  }

  /* ---------------------------------------------------------------- screens and the cut */
  function show(scr) {
    var ui = $("#ui"), back = $("#ui-back"), on = scr > 0;
    ui.classList.toggle("on", on); back.classList.toggle("on", on && scr === 5); ui.classList.toggle("sel", scr === 5);
    if (!on) { shown = 0; return; }
    var name = SCREENS[scr][0];
    $$("#ui .screen, #ui-back .screen").forEach(function (s) { s.classList.toggle("on", s.id === "s-" + name); });
    $("#crumb-k").textContent = SCREENS[scr][1]; $("#crumb-en").textContent = SCREENS[scr][2];
    if (shown > 0 && shown !== scr && !reduced) cut();
    shown = scr;
  }
  function cut() {
    var c = $("#cut"), ink = $(".ink", c), line = $("line", c);
    c.classList.add("go");
    line.animate([{ strokeDashoffset: 1, opacity: 1 }, { strokeDashoffset: 0, opacity: 1 }, { opacity: 0 }], { duration: 300, easing: "cubic-bezier(.7,0,.2,1)", fill: "forwards" });
    var a = ink.animate([
      { clipPath: "polygon(0% 0%, 100% 0%, 100% 100%, 0% 100%)" },
      { clipPath: "polygon(100% 0%, 100% 0%, 100% 100%, 0% 100%)", offset: .55 },
      { clipPath: "polygon(100% 100%, 100% 100%, 100% 100%, 100% 100%)" }], { duration: 380, easing: "cubic-bezier(.16,1,.3,1)", fill: "forwards" });
    a.onfinish = function () { c.classList.remove("go"); };
  }
  function frame() {
    if (!built) build();
    if (built && dirty) {
      dirty = false;
      var scr = V[0];
      if (scr !== shown) show(scr);
      if (scr > 0) {
        $("#ui").classList.toggle("ready", V[11] === 1);
        ({ 1: renderTitle, 2: renderMode, 3: renderSettings, 4: renderControls, 5: renderSelect, 6: renderResults })[scr]();
        renderHints();
      }
    } else if (built && V[0] === 5) measureSpot();
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);

  /* ---------------------------------------------------------------- ash over the title */
  function startAsh() {
    var c = $("#ash"), g = c.getContext("2d"), W = 0, H = 0, dpr = 1, parts = [], last = 0;
    function size() { dpr = Math.min(2, devicePixelRatio || 1); W = innerWidth; H = innerHeight; c.width = W * dpr; c.height = H * dpr; c.style.width = W + "px"; c.style.height = H + "px"; }
    size(); addEventListener("resize", function () { size(); dirty = true; });
    for (var i = 0; i < (innerWidth < 760 ? 30 : 60); i++) parts.push({ x: Math.random(), y: Math.random(), r: .4 + Math.random() * 1.8, v: .00012 + Math.random() * .0004, s: Math.random() * 6.28, red: Math.random() < .06 });
    function tick(t) {
      var dt = Math.min(50, t - last); last = t;
      if (V[0] === 1 && !reduced) {
        g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, W, H);
        parts.forEach(function (p) {
          p.y -= p.v * dt; p.s += dt * .0011; p.x += Math.sin(p.s) * .00025 * dt;
          if (p.y < -.02) { p.y = 1.02; p.x = Math.random(); }
          g.globalAlpha = p.red ? .7 : .35; g.fillStyle = p.red ? "#e81e3a" : "#bcc1cc";
          g.beginPath(); g.ellipse(p.x * W, p.y * H, p.r, p.r * .6, p.s, 0, 6.29); g.fill();
        });
        requestAnimationFrame(tick);
      } else { g.clearRect(0, 0, W * dpr, H * dpr); setTimeout(function () { requestAnimationFrame(tick); }, 300); }
    }
    requestAnimationFrame(tick);
  }
})();
