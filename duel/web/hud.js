// hud.js — SOUL DUEL's battle screens in HTML (docs/duel/DUEL_WEBUI.md §6-§9; the look of the approved drafts v4 and v6). It only draws:
// Lisp (duel/lisp/webhud.lisp) publishes the battle through gamePage.set(30100 + k, v) / setStr(30100 + k, s) and owns every key,
// pad and touch press (the touch layers here let every touch through to the canvas: Lisp's recogniser). The pause rows alone take
// a pointer and queue commands, read by Lisp through gamePage.get(30101): 7 * 100000 + cmd * 1000 + arg (1 cursor, 2 confirm).
// Drawn in a rAF only when a value changed (or a timed fade ends).
(function () {
  "use strict";
  var V = [], S = [], queue = [], dirty = true, built = false, still = false;
  for (var i = 0; i < 200; i++) V.push(-1);
  for (i = 0; i < 64; i++) S.push("");
  var reduced = !!(window.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches);

  /* ---------------------------------------------------------------- the game's own data (kanji: the page's, DUEL_WEBUI §7) */
  var FIGHTERS = {   // roster index (kit.lisp *ROSTER*) -> name, kanji, the intro's column, the pointer seals (theme glyph, name)
    0: { en: "Yamamoto", kj: "山本", full: "山本元柳斎重國" },
    1: { en: "Kenpachi", kj: "更木", full: "更木剣八", ptr: [["一", "PTR 1"], ["二", "PTR 2"], ["三", "PTR 3"]] },
    2: { en: "Rukia", kj: "朽木", full: "朽木ルキア" },
    3: { en: "Ichigo", kj: "黒崎", full: "黒崎一護", ptr: [["重", "重 · CLEAVER"], ["月", "月 · GETSUGA"], ["亂", "亂 · RANGETSU"]],
         forms: { KESSA: [["鎖", "鎖 · CHAINS"], ["月", "月 · 漆黒"], ["影", "影 · 千影"]] } },
    4: { en: "Senjumaru", kj: "修多羅", full: "修多羅千手丸" },
    6: { en: "Lille", kj: "リジェ", full: "リジェ・バロ" },
    7: { en: "Hisagi", kj: "檜佐木", full: "檜佐木修兵", ptr: [["投", "投 · NAGI"], ["刈", "刈 · KARI"], ["雷", "縛雷 · SHIBARI"]],
         forms: { "FUSHI NO KOJO RANGED": [["散", "散 · SPREAD"], ["聚", "聚 · GATHER"]],   // the Bankai's two modes, two pointers each
                  "FUSHI NO KOJO BIND": [["鎌", "鎌 · KAMA"], ["絞", "絞 · SHIBORI"]] } }
  };
  var PTR0 = [["一", "PTR 1"], ["二", "PTR 2"], ["三", "PTR 3"]];
  var CRY = { "KARE, KAZESHINI": "刈れ", "ZANGETSU": "斬月" };
  var MOVES = {   // a callout's romaji -> its kanji (romaji alone when unknown)
    "TSUZURI RAIDEN": "綴雷電", "SHIBARI": "縛", "USHIRO-NAGI": "後薙", "TSUMUJI": "旋風", "SEN-GARI": "旋刈", "REN-GARI": "連刈",
    "TAN-GARI": "短刈", "KARI-AGE": "刈上", "KO-GARI": "交刈", "CHIKUDEN": "蓄電", "HODEN": "放電", "TAME": "蓄", "MATOI": "纏", "KIRI": "斬",
    "KUBIKAKE": "首掛", "KARE, KAZESHINI": "刈れ", "KUSARI-AME": "鎖雨", "KOJO": "絞縄", "KAIBAKU": "解縛", "KOSHU": "絞首",
    "GETSUGA TENSHO": "月牙天衝", "GETSUGA JUJISHO": "月牙十字衝", "SOGA": "双牙", "RANGETSU": "乱月", "TSUKI-OTOSHI": "月落", "MINEUCHI": "峰打ち",
    "RAKUGA": "落牙", "KUSARI-TATE": "鎖盾", "KUSARI-BIKI": "鎖引", "ZANZO": "残像", "KAGE-UCHI": "影討", "BUNSHIN": "分身",
    "BUTTAGIRU": "ぶった斬る", "ORE NI KIRENEE MON WA NEE": "俺に斬れねえもんはねえ", "NOMIHOSE": "飲み干せ", "KAMICHIGIRI": "噛み千切り",
    "TATE-GOTO": "盾ごと", "NAGURI-TOBASHI": "殴り飛ばし", "MAPPUTATSU": "真っ二つ"
  };
  var PAUSE = { "RESUME": "繼續", "RESTART": "重來", "RETIRE": "放棄", "CHARACTER SELECT": "換角色", "TITLE": "回到標題", "CAMERA": "鏡頭",
    "RESET POSITION": "回到起點", "DUMMY": "假人", "COUNTER": "假人反擊", "HP REFILL": "回血", "GAUGES": "量表", "P1 HP": "P1 靈子",
    "P1 KONPAKU": "P1 魂魄", "DUMMY HP": "假人靈子", "DUMMY KONPAKU": "假人魂魄" };
  var SOUL = '<svg viewBox="0 0 10 14"><path d="M5 .6C6.4 3 9.2 5.4 9.2 8.6A4.2 4.2 0 0 1 .8 8.6C.8 6.6 2.2 5.2 3 3.6 3.4 5 4 5.6 4.8 5.8 4.4 4 4.6 2.2 5 .6z"/></svg>';
  var RING = '<svg viewBox="0 0 36 36"><circle cx="18" cy="18" r="15.9" pathLength="100"></circle></svg>';
  // the 爆 seal (draft C, DUEL_WEBUI §11): its ring is your awakening; the flash-step gauge is the ink standing in it, marked at a
  // Hoho's 1/3 and a Burst's 2/3 (*FS-HOHO* / *FS-BURST* of *FS-MAX*: 100 / 200 of 300)
  var FS_BURST = 2 / 3, FS_HOHO = 1 / 3;
  var FACE = '<span class="face"><b>爆</b><small>RV</small><i class="tick t1"></i><i class="tick t2"></i></span>';
  var AWRING = '<svg class="awring" viewBox="0 0 40 40"><circle class="trk" cx="20" cy="20" r="18.4" pathLength="100"></circle>' +
    '<circle class="awg" cx="20" cy="20" r="18.4" pathLength="100"></circle><circle class="hold" cx="20" cy="20" r="15.6" pathLength="100"></circle></svg>';
  var INF = '<svg class="inf" viewBox="0 0 66 32"><path pathLength="100" d="M33 16 C26 5 9 3 6 14 C3 25 22 29 33 16 C44 3 63 6 60 17 C57 27 40 27 33 16"/></svg>';

  /* ---------------------------------------------------------------- the bridge (pwa.js routes 30100-30299 here) */
  function send(cmd, arg) { if (V[0] & 4) queue.push(7 * 100000 + cmd * 1000 + (arg | 0)); }
  globalThis.gameHUD = {
    get: function (k) { if (k === 0) return 1; if (k === 1) return queue.length ? queue.shift() : 0; return 0; },
    set: function (k, v) { if (k >= 0 && k < 200 && V[k] !== v) { V[k] = v; dirty = true; } },
    setStr: function (k, s) { var i = k - 120; if (i >= 0 && i < 64 && S[i] !== s) { S[i] = s; dirty = true; } },
    still: function (on) { still = !!on; if (els.fx) els.fx.innerHTML = ""; prev.ring = null; },   // (tests: the touch ink stays put for a still)
    dump: function () { return JSON.stringify({ v: V.slice(0, 43), s: S.slice(0, 12), cls: root && root.className }); }   // (tests)
  };
  function focusGame() { var c = document.getElementById("canvas"); if (c && document.activeElement !== c) c.focus({ preventScroll: true }); }

  /* ---------------------------------------------------------------- building */
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var root, els = {};
  function plateHTML(p) {
    var souls = ""; for (var i = 0; i < 9; i++) souls += '<span class="soul">' + SOUL + '</span>';
    return '<div class="plate ' + p + '"><div class="who"><span class="nm"></span><span class="kj"></span><span class="htag"></span></div>' +
      '<div class="rrow"><div class="reishi"><i class="ghost"></i><i class="fill"></i></div></div><div class="ggr"><i></i></div><div class="srow"><div class="souls">' + souls + '</div><div class="kit" hidden></div></div>' +
      '<div class="scount"><b class="sn">9</b><span>魂魄</span></div>' +
      '<div class="meters"><div class="aw"></div><span class="awk">EVOLUTION</span></div><div class="fsb"><span class="fl">FLASH STEP</span><div class="fs"><i></i><i></i><i></i></div></div>' +
      '<div class="hptr"><span class="seal"></span><span class="seal"></span><span class="seal"></span><span class="pn"></span></div></div>' +
      '<div class="callout ' + p + '"><span class="ck"></span><span class="cr"></span></div>' +
      '<div class="combo ' + p + '"><div class="crow"><span class="n"></span><span class="h">HITS</span></div><span class="d">DMG <b class="cd"></b> · SCALE <b class="cs"></b></span></div>';
  }
  function build() {
    if (built || !document.body) return;
    built = true;
    document.body.insertAdjacentHTML("beforeend", '<div id="hud" aria-hidden="true">' +
      '<div class="hudl">' + plateHTML("p1") + plateHTML("p2") +
      '<div class="clock"><span class="t"></span>' + INF + '<span class="r rd"></span><span class="r rp"><i></i><b>止</b>PAUSE</span></div>' +
      '<div class="prompt"><div class="ring"><svg viewBox="0 0 36 36"><circle class="bg" cx="18" cy="18" r="15.9" pathLength="100"></circle>' +
      '<circle class="fg" cx="18" cy="18" r="15.9" pathLength="100"></circle></svg><b>毀</b></div><span class="hkey"></span>' +
      '<span class="what"><span class="wt"></span><small></small></span></div></div>' +
      '<div class="deck" hidden><div class="zone sp"></div><div class="zone atk"></div><span class="zl sp">SP <em>技</em></span><span class="zl atk">ATK <em>斬</em></span>' +
      '</div>' +
      '<div class="rvc" hidden><div class="hptr">' + '<span class="seal" style="--a:304"></span><span class="seal" style="--a:270"></span><span class="seal" style="--a:236"></span>' +
      '<span class="pn"></span></div></div>' +
      '<div class="dbtn rv" hidden><span class="well"><span class="lvl">' + FACE + '</span></span>' + FACE + AWRING + '<span class="kak">覺</span></div>' +
      '<div class="fx"></div>' +
      '<div class="pause"><div class="big">止</div><div class="strip" role="menu"><div class="ey"></div><div class="rows"></div></div></div>' +
      '<div class="card"><div class="lb t"></div><div class="lb b"></div><div class="namecol"><div class="kv"></div><div class="side"><span class="rom"></span><i></i><span class="cry"></span></div></div>' +
      '<div class="vsbar"><span class="a"></span><span class="v">vs</span><span class="b"></span></div></div>' +
      '<div class="readyfx"><div class="slashline"></div><span class="r">Ready</span><span class="k">斬</span></div>' +
      '<div class="fin"><div class="splat"></div><div class="kk"></div><div class="ko"></div>' +
      '<div class="win"><span class="l"></span><span class="w"></span><span class="s"></span></div></div></div>');
    root = $("#hud");
    els.plate = [$(".plate.p1", root), $(".plate.p2", root)];
    els.call = [$(".callout.p1", root), $(".callout.p2", root)];
    els.combo = [$(".combo.p1", root), $(".combo.p2", root)];
    els.clock = $(".clock", root); els.prompt = $(".prompt", root);
    els.deck = $(".deck", root); els.rv = $(".dbtn.rv", root); els.rvc = $(".rvc", root); els.fx = $(".fx", root);
    els.rows = $(".pause .rows", root); els.card = $(".card", root); els.fin = $(".fin", root);
    var strip = $(".strip", root);
    strip.addEventListener("pointerdown", function (e) { e.preventDefault(); focusGame(); });
    strip.addEventListener("pointerover", function (e) {
      if (e.pointerType !== "mouse") return;
      var r = e.target.closest(".pr");
      if (r && +r.dataset.i !== V[17]) send(1, +r.dataset.i);
    });
    strip.addEventListener("click", function (e) { var r = e.target.closest(".pr"); if (r) { send(1, +r.dataset.i); send(2); } });
    addEventListener("resize", function () { dirty = true; });
  }

  /* ---------------------------------------------------------------- drawing */
  var prev = {}, timers = {};
  function later(key, ms) { clearTimeout(timers[key]); timers[key] = setTimeout(function () { dirty = true; }, ms); }
  // writes only on a change (a frame of the fight changes a few numbers: no style / layout work for the rest)
  function tx(el, v) { v = String(v); if (el._t !== v) { el._t = v; el.textContent = v; } }
  function st(el, k, v) { var c = el._s || (el._s = {}); if (c[k] !== v) { c[k] = v; el.style.setProperty(k, v); } }
  function restart(el, cls) { el.classList.remove(cls); void el.offsetWidth; el.classList.add(cls); }
  function fighter(s) { return FIGHTERS[V[50 + 30 * s] - 1] || null; }
  function label(s) { return S[4 * s] || ""; }
  function formOf(s) { var l = label(s).split(/\s{2,}/); return l.length > 1 ? l[1] : ""; }
  function nameOf(s) {
    var f = fighter(s); if (f) return f.en;
    var l = label(s).split(/\s{2,}/)[0]; return l ? l.charAt(0) + l.slice(1).toLowerCase() : "—";
  }
  function seals(s) {   // by the form, or the form + its tag (Hisagi's Bankai: one form name, the mode in the tag)
    var f = fighter(s), k = formOf(s); if (!f || !f.ptr) return PTR0;
    return (f.forms && (f.forms[k + " " + (S[4 * s + 1] || "")] || f.forms[k])) || f.ptr;
  }
  function tagHTML(s) {
    var t = S[4 * s + 1] || "", o = 50 + 30 * s, form = formOf(s), m;
    var out = t === "KAZESHINI IN" ? "風死 <b>·</b> in hand" : t === "KAZESHINI OUT" ? "風死 <b>·</b> thrown" : t === "KAZESHINI ..." ? "風死 <b>·</b> returning" :
      (m = /^BUNSHIN x(\d)/.exec(t)) ? "分身 <b>·</b> ×" + m[1] :
      t === "NOME" || t === "UDE" ? "" : t.toLowerCase();   // (NOME / UDE: the strip under the bar, DUEL_WEBUI §13)
    return (form ? form.toLowerCase() + (out ? " <b>·</b> " : "") : "") + out;
  }
  // Kenpachi's kit meters as a strip under the Reishi bar (DUEL_WEBUI §13): NOME is three sake cups on a bar (cup 2 at 40, cup 3 at the
  // full 100, floors 25 / 50 where it drops a cup back: tuning.lisp *NOME-UP-T2* / *NOME-DOWN-T2* / *NOME-DOWN-T3* of *NOME-MAX*), UDE
  // four claw pips of the Bankai's arm with the crack clock under the next one
  var CUP = '<svg viewBox="0 0 14 10"><path d="M1 1h12l-1.4 5.4C11.2 8.2 9.4 9.4 7 9.4S2.8 8.2 2.4 6.4z"/></svg>';
  var NOME_AT = [0, .4, 1], NOME_FLOOR = [0, .25, .5];
  function renderKit(el, s, o, p) {
    var t = S[4 * s + 1] || "", kind = t === "NOME" ? "nome" : t === "UDE" ? "ude" : "", k = $(".kit", el);
    if (p.kit !== kind) {
      p.kit = kind; k.hidden = !kind; k.className = "kit" + (kind ? " " + kind : "");
      k.innerHTML = kind === "nome" ? '<span class="kn">呑</span><div class="nb"><i class="cp" style="--x:0%;--m:0">' + CUP + '</i><i class="cp" style="--x:40%;--m:-.75">' + CUP +
          '</i><i class="cp" style="--x:100%;--m:-1.5">' + CUP + '</i><div class="nbar"><i class="bf"></i><i class="tk" style="--x:25%"></i><i class="tk up" style="--x:40%"></i>' +
          '<i class="tk" style="--x:50%"></i></div></div><b class="kv"></b>' :
        kind === "ude" ? '<span class="kn">腕</span><span class="pips"><span class="pp"><i></i><u></u></span><span class="pp"><i></i><u></u></span>' +
          '<span class="pp"><i></i><u></u></span><span class="pp"><i></i><u></u></span></span>' : "";
    }
    if (!kind) return;
    var v = Math.max(0, V[o + 15]), mx = Math.max(1, V[o + 16]), i;
    if (kind === "nome") {
      var f = Math.min(1, v / mx), rung = Math.max(0, Math.min(2, V[o + 20])), cps = k.querySelectorAll(".cp");
      st($(".bf", k), "--k", f.toFixed(3)); tx($(".kv", k), v);
      for (i = 0; i < 3; i++) cps[i].classList.toggle("on", i <= rung);
      $(".bf", k).classList.toggle("near", rung > 0 && f < NOME_FLOOR[rung] + .1);   // within a tenth of the drop: it pulses
    } else {
      var n = Math.round(v), pp = k.querySelectorAll(".pp");
      st(k, "--ck", (Math.max(0, V[o + 21]) / 1000).toFixed(3));
      for (i = 0; i < 4; i++) { pp[i].classList.toggle("lit", i < n); pp[i].classList.toggle("nx", i === n - 1); }
      k.classList.toggle("hurry", n > 0 && V[o + 21] < 200);
    }
  }
  function renderPlate(s) {
    var el = els.plate[s], o = 50 + 30 * s, f = fighter(s), p = prev["p" + s] || (prev["p" + s] = {});
    var mir = s === 1 || (s === 0 && root.classList.contains("hphone") && root.classList.contains("left-hand"));
    el.classList.toggle("mir", s === 0 && mir);
    els.call[0].classList.toggle("mir", s === 0 && mir); els.combo[0].classList.toggle("mir", s === 0 && mir);
    tx($(".nm", el), nameOf(s));
    tx($(".kj", el), f ? f.kj : "");
    var tg = tagHTML(s); if (p.tag !== tg) { $(".htag", el).innerHTML = tg; p.tag = tg; }
    renderKit(el, s, o, p);
    var r = Math.max(0, V[o + 1]) / 1000, ghost = $(".ghost", el);
    if (p.r !== r) st(ghost, "transition", p.r !== undefined && r < p.r ? "" : "none");   // a hit: the blood ghost drains after it; a refill snaps
    st($(".fill", el), "transform", "scaleX(" + r + ")"); st(ghost, "transform", "scaleX(" + r + ")"); p.r = r;
    el.classList.toggle("low", V[o + 2] === 1); el.classList.toggle("dead", r <= 0);
    var kon = Math.max(0, V[o + 3]), stake = Math.max(0, V[o + 4]), souls = $(".souls", el).children;
    for (var i = 0; i < 9; i++) {
      var sl = souls[i]; sl.classList.toggle("gone", i >= kon); sl.classList.toggle("stake", i < kon && i >= kon - stake);
      if (p.kon !== undefined && i >= kon && i < p.kon && !reduced) restart(sl, "shatter");
    }
    p.kon = kon; tx($(".sn", el), String(kon));
    var gg = $(".ggr", el); st(gg, "--k", (Math.max(0, V[o + 24]) / 1000).toFixed(3)); gg.classList.toggle("broken", V[o + 25] === 1);   // the guard gauge (ROS: under the Reishi bar)
    var fs = Math.max(0, V[o + 6]) / 1000 * 3, cells = $(".fs", el).children;
    for (i = 0; i < 3; i++) st(cells[i], "--k", Math.max(0, Math.min(1, fs - i)).toFixed(3));
    var aw = $(".aw", el); st(aw, "--k", (Math.max(0, V[o + 7]) / 1000).toFixed(3)); aw.classList.toggle("full", V[o + 8] >= 1); st(aw, "--s", (Math.max(0, V[o + 22]) / 1000).toFixed(3)); aw.dataset.m = V[o + 23];   // SUBLIMATION / SPIRIT DRIVE: the line under it
    if (s === 0) st(els.rv, "--aw", (Math.max(0, Math.min(1000, V[o + 7])) / 1000).toFixed(3));   // the seal's ring: your awakening
    var awk = $(".awk", el); awk.classList.toggle("on", V[o + 8] === 1);
    var ptr = $(".hptr", s === 0 && !els.rvc.hidden ? els.rvc : el), sv = seals(s), n = V[o + 9];   // (the phone: your stance around 爆)
    ptr.hidden = !(n > 0);
    if (n > 0) {
      var ss = ptr.querySelectorAll(".seal");
      for (i = 0; i < 3; i++) {
        ss[i].hidden = i >= sv.length;
        if (i < sv.length) { tx(ss[i], sv[i][0]); ss[i].classList.toggle("on", i + 1 === n); }
      }
      tx($(".pn", ptr), sv[Math.min(n, sv.length) - 1][1]);
    }
    // the combo this side deals, under its plate; each hit stamps it (no screen flash: the user, 2026-10-29: 「打中對手時不要讓螢幕閃爍白光」)
    var c = els.combo[s], practice = !!(V[0] & 16);
    if (V[o + 13] !== p.cser) {
      if (p.cser !== undefined && V[o + 13] > 0) {
        $(".n", c).textContent = V[o + 10]; $(".cd", c).textContent = V[o + 11]; $(".cs", c).textContent = Math.round(V[o + 12] / 10) + "%";
        c.classList.add("on"); if (!reduced) { restart(c, "stamp"); }
        p.ct = performance.now(); later("c" + s, 1250);
      }
      p.cser = V[o + 13];
    }
    if (c.classList.contains("on") && !practice && performance.now() - (p.ct || 0) > 1200) c.classList.remove("on");
    // the move's name under the attacker's plate
    var cl = els.call[s];
    if (V[o + 14] !== p.lser) {
      if (p.lser !== undefined && V[o + 14] > 0) {
        var rom = S[4 * s + 2] || "", kan = MOVES[rom.toUpperCase()] || "";
        $(".ck", cl).textContent = kan; $(".cr", cl).textContent = rom; cl.classList.toggle("rom", !kan);
        restart(cl, "on"); p.lt = performance.now(); later("l" + s, 1550);
      }
      p.lser = V[o + 14];
    }
    if (cl.classList.contains("on") && performance.now() - (p.lt || 0) > 1500) cl.classList.remove("on");
  }
  function renderPrompt() {
    var k = V[2], a = V[3], pr = els.prompt, phone = root.classList.contains("hphone");
    var what = "", sub = "";
    if (k === 1) { what = "Hold SP"; sub = "KIKON · 毀魂 " + a + "F"; }
    else if (k === 2) { var rom = S[9] || "", kan = MOVES[rom.toUpperCase()]; what = "SP · AS" + a; sub = "J HIT → " + (kan ? kan + " · " : "") + rom; }
    else if (k === 3) { what = a === 2 ? "Chain" : "Burst"; sub = a === 2 ? "ORANGE · 爆氣" : "BLUE · 爆氣"; }
    else if (k === 4) { what = "Awaken"; sub = (phone || !S[8] ? "HOLD 爆" : S[8]) + " · 覺醒 READY"; }
    if (k === 4 && phone && !root.classList.contains("nodeck")) k = 0;   // (the phone: the 爆 seal's 覺 tab says it, DUEL_WEBUI §9)
    pr.classList.toggle("on", k > 0);
    pr.classList.toggle("p-aw", k === 4); pr.classList.toggle("p-burst", k === 3);
    if (k > 0) { tx($(".wt", pr), what); tx($("small", pr), sub); tx($(".hkey", pr), k === 4 ? "" : (S[8] || "")); }
    if (k === 1 && prev.pk !== 1) { pr.style.setProperty("--hold", Math.max(1, a) / 60 + "s"); pr.classList.add("hold"); restart($(".ring .fg", pr), "x"); }
    if (k !== 1) pr.classList.remove("hold");
    prev.pk = k;
  }
  function pct(v) { return v / 10 + "%"; }
  function renderDeck() {
    var on = !!(V[0] & 8), left = V[42] === 1;
    els.deck.hidden = !on; els.rv.hidden = !on; els.rvc.hidden = !on;
    var pl = els.plate[0], ck = els.clock;
    if (!on) { ["left", "bottom", "width", "rotate", "transform-origin"].forEach(function (k) { st(pl, k, ""); }); st(ck, "left", ""); st(ck, "top", ""); return; }
    var d = els.deck, x0 = V[30], y0 = V[31], x1 = V[32], y1 = V[33];
    st(d, "left", pct(x0)); st(d, "top", pct(y0)); st(d, "width", pct(x1 - x0)); st(d, "height", pct(y1 - y0));
    st(root, "--deck", pct(1000 - y0));
    st(d, "--ext", Math.max(0, innerHeight * (y0 - V[43]) / 1000) + "px");   // the paper up to the pad's top (touches start there)
    var far = V[34] / 10, near = V[35] / 10, yl = left ? near : far, yr = left ? far : near;   // the line's heights at the left / right edge
    st($(".zone.sp", d), "clip-path", "polygon(0 0, 100% 0, 100% " + yr + "%, 0 " + yl + "%)");
    st($(".zone.atk", d), "clip-path", "polygon(0 " + yl + "%, 100% " + yr + "%, 100% 100%, 0 100%)");
    // draft C 界 (DUEL_WEBUI §11): your plate IS the line, the bar's middle on it from the far edge to the thumb's, its flames and name
    // on the SP side; what is left stays at the far end (the thumb covers the near one)
    var u = innerWidth * .0236, w = innerWidth * (x1 - x0) / 1000, h = innerHeight * (y1 - y0) / 1000;
    var rise = (near - far) / 100 * h, len = Math.hypot(w, rise), ang = Math.atan2(rise, w);
    var fy = innerHeight * y0 / 1000 + h * far / 100, fx = innerWidth * (left ? x1 : x0) / 1000;
    st(pl, "left", (left ? fx - len : fx) + "px"); st(pl, "width", len + "px");
    st(pl, "bottom", (innerHeight - fy - .65 * u) + "px");
    st(pl, "transform-origin", (left ? "100%" : "0") + " calc(100% - " + .65 * u + "px)"); st(pl, "rotate", (left ? -ang : ang) + "rad");
    seat(els.rv, V[36], V[37], V[38]);
    st(els.rvc, "left", innerWidth * V[36] / 1000 + "px"); st(els.rvc, "top", innerHeight * V[37] / 1000 + "px");
    // the clock tab is the pause: drawn on Lisp's pause chip (chip 6, its middle; the tab 10.4 x 8.4 U)
    st(ck, "left", (innerWidth * V[39] / 1000 - 5.2 * u) + "px"); st(ck, "top", (innerHeight * V[40] / 1000 - 4.2 * u) + "px");
    var b = V[4], pb = prev.rv | 0, rv = els.rv;
    rv.classList.toggle("ready", !!(b & 1)); rv.classList.toggle("pressed", !!(b & 4)); rv.classList.toggle("can", !!(b & 8));
    // 墨池: the flash step is the ink in the seal; at a Burst's 2/3 the seal arms, a running Burst drains it in its mode's colour
    var fs = Math.max(0, Math.min(1000, V[56])) / 1000, mode = b & 112, armed = !mode && fs >= FS_BURST - .0005;
    st(rv, "--lv", (fs * 100).toFixed(1) + "%");
    rv.classList.toggle("armed", armed); rv.classList.toggle("bursting", !!mode);
    if (mode) st(rv, "--bc", mode & 16 ? "#f2f5ff" : mode & 32 ? "#66a8ff" : "#ff942e");   // (the engine's WHITE / BLUE / ORANGE)
    if (!reduced && prev.fs !== undefined) {
      if (armed && !prev.armed) restart(rv, "arm");
      if (!mode && fs < prev.fs - FS_HOHO * .75) restart(rv, "slosh");                     // a Hoho: the ink drops a third, the seal dips
    }
    prev.fs = fs; prev.armed = armed;
    function press() { if (mode) return; if (fs >= FS_BURST - .0005) seal("BURST", "sp"); else { restart(rv, "deny"); seal("NO BURST", ""); } }
    if ((b & 2) && !(pb & 2)) restart(rv, "holding"); else if (!(b & 2)) rv.classList.remove("holding");
    if ((b & 4) && !(pb & 4) && !(b & 1)) press();                                          // not ready: the Burst on the press
    if ((pb & 2) && !(b & 2) && (b & 4)) seal("覺醒 AWAKEN", "aw");                          // held through: the awakening
    if ((pb & 2) && !(b & 2) && !(b & 4)) press();                                          // let go before it: the Burst
    prev.rv = b;
  }
  function seat(el, cx, cy, r) {
    var px = innerWidth * r / 1000;
    st(el, "width", 2 * px + "px"); st(el, "height", 2 * px + "px"); st(el, "--dd", 2 * px + "px");
    st(el, "left", (innerWidth * cx / 1000 - px) + "px"); st(el, "top", (innerHeight * cy / 1000 - px) + "px");
  }
  function drop(cls, x, y, ms) {
    var d = document.createElement("div"); d.className = cls; d.style.left = x + "px"; d.style.top = y + "px";
    if (still) { d.style.animation = "none"; d.style.opacity = ".85"; }          // (a test's still: held, not animated)
    els.fx.appendChild(d); if (!still) setTimeout(function () { d.remove(); }, ms || 900); return d;
  }
  function word(t, x, y, cls) { drop("gname" + (cls ? " " + cls : ""), x, y).textContent = t; }
  function seal(t, cls) { var r = els.rv.getBoundingClientRect(); word(t, r.left + r.width / 2, r.top, cls); }
  function renderTouch() {
    if (!(V[0] & 8)) return;
    if (V[5] !== prev.gser) {
      if (prev.gser !== undefined && V[5] > 0 && !reduced) {
        var k = V[6], x = innerWidth * V[7] / 1000, y = innerHeight * V[8] / 1000, dx = innerWidth * V[9] / 1000, dy = innerHeight * V[10] / 1000;
        if (k === 1 || k === 3) { drop("ink" + (k === 3 ? " sp" : ""), x, y); word(k === 3 ? "SP" : "ATK", x, y, k === 3 ? "sp" : ""); }
        else if (k === 2 || k === 4 || k === 6) {
          var len = Math.hypot(dx, dy) || 1, min = innerWidth * .2;                   // (the recognised stroke is short, ~28 px:
          if (len < min) { dx *= min / len; dy *= min / len; len = min; }            //  the brush shows a stroke of 20 % of the width)
          var tr = drop("trail", x - dx, y - dy, 600);
          tr.style.width = len + "px"; tr.style.transform = "rotate(" + Math.atan2(dy, dx) + "rad)";
          word(k === 4 ? "HOHO" : k === 6 ? "DASH" : dy > Math.abs(dx) ? "STEP · BACK" : "STEP · SIDE", x, y);
        } else if (k === 7) word("BURST", x, y, "sp");
      }
      prev.gser = V[5];
    }
    var ring = V[11] === 1;
    if (ring && !prev.ring) { prev.ring = drop("holdring", innerWidth * V[12] / 1000, innerHeight * V[13] / 1000, 60000); prev.ring.innerHTML = RING; }
    if (!ring && prev.ring) { prev.ring.remove(); prev.ring = null; }
  }
  function renderPause() {
    var on = !!(V[0] & 4);
    document.body.classList.toggle("hud-paused", on);
    if (!on) return;
    var ey = $(".pause .ey", root);
    ey.innerHTML = (V[0] & 64) ? "<b>Rotate to portrait · 請轉成直向</b>" : "Paused · 一時停止";
    var n = Math.max(0, V[18]);
    if (prev.pser !== V[19]) {
      var h = "";
      for (var i = 0; i < n; i++) {
        var t = S[10 + i] || "", parts = t.split(/\s{2,}/), en = parts[0], val = parts.slice(1).join(" ");
        h += '<div class="pr" role="menuitem" data-i="' + i + '"><span class="no">' + (i < 9 ? "0" : "") + (i + 1) + '</span><span class="en">' + en.toLowerCase() +
          '</span>' + (val ? '<span class="val">' + val + '</span>' : '<span class="zh">' + (PAUSE[en] || "") + '</span>') + '</div>';
      }
      els.rows.innerHTML = h; $(".strip", root).classList.toggle("long", n > 6); prev.pser = V[19];
    }
    var rows = els.rows.children;
    for (i = 0; i < rows.length; i++) rows[i].classList.toggle("cur", i === V[17]);
  }
  function renderCard() {
    var ph = V[14], card = els.card, side = ph === 2 ? 1 : 0, f = fighter(side), nc = $(".namecol", card);
    var intro = ph >= 1 && ph <= 3 && !!(V[0] & 32);
    card.classList.toggle("on", intro);
    if (intro && (ph === 1 || ph === 2) && prev.side !== ph) {
      $(".kv", nc).textContent = f ? f.full : nameOf(side);
      var rom = S[30] || "", cry = S[31] || "";
      $(".rom", nc).textContent = rom; $(".cry", nc).textContent = cry ? (CRY[cry] ? CRY[cry] + " · " : "") + cry : "";
      nc.classList.toggle("l", side === 1); restart(nc, "go");
      $(".vsbar .a", card).textContent = nameOf(0); $(".vsbar .b", card).textContent = nameOf(1);
    }
    if (ph >= 1 && ph <= 2) prev.side = ph;
    var r = $(".readyfx .r", root), k = $(".readyfx .k", root), sl = $(".readyfx .slashline", root), pp = prev.ph | 0;
    if (ph === 3 && pp !== 3 && !reduced) { restart(sl, "go"); restart(r, "go"); }
    if ((ph === 4 && pp !== 4) || (ph === 0 && pp >= 1 && pp <= 3)) {        // 斬: the FIGHT beat, or a skipped intro's start
      r.classList.remove("go"); if (!reduced) { restart(k, "go"); if (pp !== 3) restart(sl, "go"); }
    }
    if (ph === 0) prev.side = 0;
    prev.ph = ph;
    // the finish: 決着 + K.O. (or TIME / a draw), the winner with Konpaku / best combo / Kikons
    var fk = V[15], fin = els.fin;
    if (fk > 0 && prev.fk !== fk) {
      var w = V[16], wo = 50 + 30 * (w === 1 ? 1 : 0), lo = 50 + 30 * (w === 1 ? 0 : 1);
      $(".kk", fin).textContent = fk === 1 ? "決着" : "時間切れ";
      $(".ko", fin).textContent = fk === 1 ? "K.O." : fk === 2 ? "TIME" : "DRAW";
      $(".l", fin).textContent = w === 2 ? "Draw · 引き分け" : "Winner · 勝者";
      $(".w", fin).textContent = w === 2 ? "Draw" : nameOf(w);
      $(".s", fin).innerHTML = "魂魄 <b>" + V[wo + 3] + "–" + V[lo + 3] + "</b> · 最長連段 <b>" + V[wo + 17] + "</b> · 毀魂 <b>" + V[wo + 18] + "</b>";
    }
    fin.classList.toggle("on", fk > 0); prev.fk = fk;
  }
  function render() {
    var on = !!(V[0] & 1);
    root.classList.toggle("on", on);
    if (!on) { document.body.classList.remove("hud-paused"); prev.p0 = prev.p1 = null; prev.ph = 0; prev.fk = 0; return; }
    root.classList.toggle("hphone", innerHeight > innerWidth);
    root.classList.toggle("left-hand", V[42] === 1 && !!(V[0] & 8));
    root.classList.toggle("nodeck", !(V[0] & 8));
    root.classList.toggle("cine", !!(V[0] & 2)); root.classList.toggle("paused", !!(V[0] & 4));
    var t = V[1], clock = els.clock, prac = !!(V[0] & 16);
    clock.hidden = t < 0 && !prac;                                 // PRACTICE: no timer, ∞ (the user, 2026-10-29)
    clock.classList.toggle("inf", prac);
    tx($(".rd", clock), prac ? "PRACTICE · 練習" : "ROUND · 決闘");
    if (t >= 0 && !prac) { tx($(".t", clock), t < 10 ? "0" + t : String(t)); clock.classList.toggle("end", t <= 10); } else clock.classList.remove("end");
    renderDeck();                                                  // (first: the phone's plate sits on the deck's top)
    renderPlate(0); renderPlate(1);
    renderPrompt(); renderTouch(); renderPause(); renderCard();
  }
  function frame() {
    if (!built) build();
    if (built && dirty) { dirty = false; render(); }
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
})();
