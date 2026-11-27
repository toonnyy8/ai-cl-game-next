//! port: duel/lisp/mcts-lite.lisp — the in-game MCTS's light model and search (DUEL_AI_TEACHER §9): the neutral game to its first
//! contact on one axis (the distance in mm, per fighter a state and its frame), fixnum arithmetic only, its own Park-Miller stream.
//! Pure: a `Lite` holds the specials the Lisp keeps (`*mc-f*` `*mc-i*` `*mc-slots*` `*mc-vals*` `*mc-g*` `*mc-w*` `*mc-n*` …), made
//! afresh for each search (cpu-mcts.lisp MC-SETUP fills it; every slot is rewritten at a search's start, M2_NOTES §1), so nothing of it
//! is CPU state.
use crate::cl::{floor_div, modulo, round_f32};
use crate::core::{core_verdict, Verdict};
use crate::knobs::Knobs;
use crate::rules::move_end_frame;
use duel_data::{Kit, Move, MoveClass};

// a move record's fields
pub const R_S: usize = 0;
pub const R_END: usize = 1;
pub const R_FROM: usize = 2;
pub const R_TO: usize = 3;
pub const R_REACH: usize = 4;
pub const R_SLIDE: usize = 5;
pub const R_CLS: usize = 6;
pub const R_WAVE_V: usize = 7;
pub const R_WAVE_RANGE: usize = 8;
pub const R_CRUSH: usize = 9;
pub type Rec = [i64; 10];

// a fighter's fields
pub const F_KIND: usize = 0;
pub const F_T: usize = 1;
pub const F_LEN: usize = 2;
pub const F_DIR: usize = 3;
pub const F_SLOT: usize = 4;
pub const F_SPENT: usize = 5;
pub const F_HOHO: usize = 6;
pub const F_REACT: usize = 7;
pub const F_WAVE_X: usize = 8;
pub const F_WAVE_LEFT: usize = 9;
pub const F_START: usize = 10;
pub const F_HURT: usize = 11;
pub const F_WALK: usize = 12;
pub const F_PTR: usize = 13;
pub const F_WAVE_V: usize = 14;
pub const F_WAVE_O: usize = 15;
pub const F_CONT: usize = 16;
pub const F_TURN: usize = 17;
pub type Fv = [i64; 18];

// kinds
pub const K_FREE: i64 = 0;
pub const K_WAIT: i64 = 1;
pub const K_WALK: i64 = 2;
pub const K_GUARD: i64 = 3;
pub const K_MOVE: i64 = 4;
pub const K_STEP: i64 = 5;
pub const K_HOHO: i64 = 6;
pub const K_REEL: i64 = 7;
pub const K_LIE: i64 = 8;

// outcome slots (*mc-outcomes*' order)
pub const O_NA: usize = 0;
pub const O_NS1: usize = 1;
pub const O_TURN: usize = 4;
pub const O_COUNTER: usize = 5;
pub const O_BLOCK: usize = 6;

/// `*mc-cls-codes*` #(nil :na :ns :as :sa): a class's code (POSITION; NIL → 0) and back (tests/mcts.rs checks it against the knob).
pub fn cls_code(c: Option<MoveClass>) -> i64 {
    match c {
        None => 0,
        Some(MoveClass::Na) => 1,
        Some(MoveClass::Ns) => 2,
        Some(MoveClass::As) => 3,
        Some(MoveClass::Sa) => 4,
    }
}
fn code_cls(c: i64) -> Option<MoveClass> {
    [None, Some(MoveClass::Na), Some(MoveClass::Ns), Some(MoveClass::As), Some(MoveClass::Sa)][c as usize]
}

/// port: MC-MOVE-REC — MV's record in KIT: frames, the span of its hit windows, reach and lunge (mm), its class code, a wave (a hitless
/// move whose :params carry :speed and :range). ponytail: built per call, no cache (a pure function of the move; ~8 a search).
pub fn mc_move_rec(k: &Knobs, kit: &Kit, mv: &Move) -> Rec {
    let p = &mv.params;
    let wave = if mv.hits.is_empty() { p.speed.zip(p.range) } else { None };
    let mut r = [0; 10];
    r[R_S] = mv.s as i64;
    r[R_END] = move_end_frame(k, mv.s as i64, mv.a as i64, mv.r as i64, Some(mv.whiff as i64), None, mv.hits.is_empty(), Some(&mv.kind));
    r[R_FROM] = if wave.is_some() { 9999 } else { crate::kit::mv_first_hit(mv) };
    r[R_TO] = if wave.is_some() { 0 } else { crate::kit::move_active_end(mv) };
    r[R_REACH] = round_f32(1000.0 * mv.reach);
    r[R_SLIDE] = 0.max(round_f32(1000.0 * mv.slide));
    r[R_CLS] = cls_code(crate::kit::kit_class(kit, Some(mv)));
    if let Some((speed, range)) = wave {
        r[R_WAVE_V] = 1.max(round_f32(1000.0 * speed / 60.0)); // ((round x 60) of a single: the quotient rounded, ECL's round2)
        r[R_WAVE_RANGE] = round_f32(1000.0 * range);
    }
    r[R_CRUSH] = mv.hits.iter().any(|w| w.flags.iter().any(|f| f == "guard-crush" || f == "unguardable")) as i64;
    r
}

/// port: MC-INIT-FIGHTER — a fighter vector: state KIND at frame TT of LEN, hurt radius and walk, HOHO 1 when his Hoho is ready, PTR
/// his SP pointer - 1.
#[allow(clippy::too_many_arguments)]
pub fn mc_init_fighter(kind: i64, tt: i64, len: i64, hurt: i64, walk: i64, hoho: i64, ptr: i64) -> Fv {
    let mut v = [0; 18];
    (v[F_KIND], v[F_T], v[F_LEN], v[F_HURT], v[F_WALK], v[F_HOHO], v[F_PTR]) = (kind, tt, len, hurt, walk, hoho, ptr);
    (v[F_WAVE_X], v[F_START], v[F_SLOT]) = (-1, -1000, 2);
    v
}

/// The light model's state (mcts-lite.lisp's specials).
#[derive(Clone, Debug)]
pub struct Lite {
    /// `*mc-f*`: the two fighters in a rollout (side 0 the searcher).
    pub f: [Fv; 2],
    /// `*mc-i*`: … as the rollouts start.
    pub i: [Fv; 2],
    /// `*mc-slots*`: side x 8 + (0 J1, 1 the NS under his pointer, 2 the move he is in, 3 / 4 the NS's next segments, 5 his SA, 6 / 7
    /// the segments after the move he is in).
    pub slots: [Option<Rec>; 16],
    /// `*mc-vals*`: per side, the outcome row in milli-units.
    pub vals: [[i64; 7]; 2],
    /// `*mc-g*`: 0 the distance, 1 the react chance (per mille), 2 the stream's state, 3 the horizon, 4 his answer delay, 5 / 6 the
    /// chances an NS goes on / turns into the SA.
    pub g: [i64; 7],
    /// `*mc-w*`: `*mc-prior*`.
    pub w: [i64; 10],
    pub n: [i64; 10],
    pub sum: [i64; 10],
    pub legal: [i64; 10],
    pub n2: [i64; 100],
    pub sum2: [i64; 100],
    pub legal2: [i64; 10],
}

impl Default for Lite {
    fn default() -> Lite {
        Lite {
            f: [[0; 18]; 2],
            i: [[0; 18]; 2],
            slots: [None; 16],
            vals: [[0; 7]; 2],
            g: [0; 7],
            w: [0; 10],
            n: [0; 10],
            sum: [0; 10],
            legal: [0; 10],
            n2: [0; 100],
            sum2: [0; 100],
            legal2: [0; 10],
        }
    }
}

/// port: the MC-NEXT-SLOT macro — the slot of the NS segment after slot K's, or -1.
fn next_slot(k: i64) -> i64 {
    match k {
        1 => 3,
        3 => 4,
        2 => 6,
        6 => 7,
        _ => -1,
    }
}

/// port: MC-RAND — 0 .. N-1 off the search stream in G[2] (Park-Miller, m = 2^28 - 57, a = 16807, Schrage's q 15971 r 10802).
fn rand(g: &mut [i64; 7], n: i64) -> i64 {
    let x = g[2];
    let mut y = 16807 * modulo(x, 15971) - 10802 * floor_div(x, 15971);
    if y <= 0 {
        y += 268435399;
    }
    g[2] = y;
    modulo(y, n)
}

/// CL ISQRT of a non-negative integer.
pub fn isqrt(n: i64) -> i64 {
    let mut r = (n as f64).sqrt() as i64;
    while r * r > n {
        r -= 1;
    }
    while (r + 1) * (r + 1) <= n {
        r += 1;
    }
    r
}

/// One step's shared view inside MC-ROLLOUT: the distance and the tick (the Lisp's LET variables the macros close over).
struct Ro {
    dist: i64,
    react: i64,
    tick: i64,
    first2: i64,
    root: i64,
}

impl Lite {
    /// port: MC-SEED — seed the search stream with integer X.
    pub fn seed(&mut self, x: i64) {
        self.g[2] = 1 + modulo(x, 268435398);
    }

    fn rec(&self, side: usize, k: i64) -> Option<Rec> {
        self.slots[8 * side + k as usize]
    }
    /// CUR: the record of the move ME (side SIDE) is in.
    fn cur(&self, side: usize) -> Rec {
        self.rec(side, self.f[side][F_SLOT]).expect("a move's record")
    }
    fn signed(side: usize, v: i64) -> i64 {
        if side == 0 { v } else { -v }
    }
    fn legal_p(&self, side: usize, a: i64) -> bool {
        match a {
            6 => false,
            3.. => true,
            2 => self.f[side][F_HOHO] == 1,
            _ => self.rec(side, a).is_some(),
        }
    }
    fn hit_slot(&self, side: usize, r: &Rec) -> usize {
        match r[R_CLS] {
            2 => O_NS1 + self.f[side][F_PTR] as usize,
            3 | 4 => O_TURN,
            _ => O_NA,
        }
    }
    fn invuln(&self, op: usize) -> bool {
        let (k, tt) = (self.f[op][F_KIND], self.f[op][F_T]);
        k == K_LIE || (k == K_STEP && (3..=9).contains(&tt)) || (k == K_HOHO && (1..=14).contains(&tt))
    }
    /// THREAT: does OP's move or wave threaten ME within the perfect Hoho's lead (12 f, 1 m inflate)?
    fn threat(&self, ro: &Ro, op: usize, me: usize) -> bool {
        let (o, mf) = (&self.f[op], &self.f[me]);
        (o[F_KIND] == K_MOVE && o[F_SPENT] == 0 && {
            let (r, tt) = (self.cur(op), o[F_T]);
            tt < r[R_TO] && r[R_FROM] - tt <= 12 && ro.dist <= r[R_REACH] + mf[F_HURT] + 1000
        }) || (o[F_WAVE_X] >= 0 && ro.dist - o[F_WAVE_X] <= 12 * o[F_WAVE_V] + mf[F_HURT] + 1000)
    }
    /// ROLL-REACT: ME (side 1 only) rolls once whether he answers the threat just started with a perfect Hoho.
    fn roll_react(&mut self, ro: &Ro, me: usize) {
        self.f[me][F_REACT] = (self.f[me][F_HOHO] == 1 && rand(&mut self.g, 1000) < ro.react) as i64;
    }
    /// START-SLOT: ME starts the move in slot K: its rolls, his answer's.
    fn start_slot(&mut self, ro: &Ro, me: usize, k: i64) {
        let end = self.rec(me, k).expect("a slot's record")[R_END];
        let f = &mut self.f[me];
        (f[F_KIND], f[F_SLOT], f[F_SPENT], f[F_START], f[F_T], f[F_LEN]) = (K_MOVE, k, 0, ro.tick, 0, end);
        let c = (rand(&mut self.g, 1000) < self.g[5]) as i64;
        self.f[me][F_CONT] = c;
        let t = (rand(&mut self.g, 1000) < self.g[6]) as i64;
        self.f[me][F_TURN] = t;
        if me == 0 {
            self.roll_react(ro, 1);
        }
    }
    /// GAP: in an NS segment's gap: the SA against his NA coming, else the next segment.
    fn gap(&mut self, ro: &Ro, me: usize, op: usize) {
        let (r, tt) = (self.cur(me), self.f[me][F_T]);
        if !(r[R_CLS] == 2 && tt >= r[R_TO] && tt >= r[R_S]) {
            return;
        }
        let o = self.f[op];
        let sa = self.f[me][F_TURN] == 1
            && self.rec(me, 5).is_some()
            && o[F_KIND] == K_MOVE
            && o[F_SPENT] == 0
            && {
                let rop = self.cur(op);
                rop[R_CLS] == 1 && o[F_T] < rop[R_TO] && ro.dist <= rop[R_REACH] + self.f[me][F_HURT] + 500
            };
        let nx = next_slot(self.f[me][F_SLOT]);
        if sa {
            self.start_slot(ro, me, 5);
        } else if self.f[me][F_CONT] == 1 && nx >= 0 && self.rec(me, nx).is_some() {
            self.start_slot(ro, me, nx);
        }
    }
    /// START: ME starts action A (an illegal one: wait). Some(value) when it ends the rollout (a Hoho into a threat: the counter).
    fn start(&mut self, ro: &Ro, me: usize, op: usize, a: i64) -> Option<i64> {
        let a = if self.legal_p(me, a) { a } else { 7 };
        (self.f[me][F_T], self.f[me][F_DIR]) = (0, 0);
        match a {
            0 | 1 => self.start_slot(ro, me, a),
            2 => {
                if self.threat(ro, op, me) {
                    return Some(Self::signed(me, self.vals[me][O_COUNTER]));
                }
                let f = &mut self.f[me];
                (f[F_KIND], f[F_LEN], f[F_HOHO]) = (K_HOHO, 24, 0);
            }
            3..=5 => {
                let f = &mut self.f[me];
                (f[F_KIND], f[F_LEN], f[F_DIR]) = (K_STEP, 24, [1, -1, 0][(a - 3) as usize]);
            }
            6 => (self.f[me][F_KIND], self.f[me][F_LEN]) = (K_GUARD, 24),
            8 | 9 => {
                let f = &mut self.f[me];
                (f[F_KIND], f[F_LEN], f[F_DIR]) = (K_WALK, 20, if a == 8 { 1 } else { -1 });
            }
            _ => (self.f[me][F_KIND], self.f[me][F_LEN]) = (K_WAIT, 20),
        }
        None
    }
    /// PICK: the rollout policy, `*mc-prior*` over the legal actions.
    fn pick(&mut self, me: usize) -> i64 {
        let tot: i64 = (0..10).filter(|&a| self.legal_p(me, a)).map(|a| self.w[a as usize]).sum();
        let mut r = rand(&mut self.g, 1.max(tot));
        for a in 0..10 {
            if self.legal_p(me, a) {
                r -= self.w[a as usize];
                if r < 0 {
                    return a;
                }
            }
        }
        7
    }
    fn decide(&mut self, ro: &mut Ro, me: usize, op: usize) -> Option<i64> {
        let k = self.f[me][F_KIND];
        if me == 1 && self.f[me][F_REACT] == 1 && k <= K_WALK && self.threat(ro, op, me) {
            return Some(Self::signed(me, self.vals[me][O_COUNTER]));
        }
        if k == K_MOVE {
            self.gap(ro, me, op);
        }
        if k == K_FREE {
            let a = if me == 0 {
                if ro.tick == 0 { ro.root } else { self.pick(me) }
            } else if ro.first2 >= 0 {
                std::mem::replace(&mut ro.first2, -1)
            } else {
                self.pick(me)
            };
            return self.start(ro, me, op, a);
        }
        None
    }
    /// MOVE: this step's motion of ME (the distance) and of his wave.
    fn step_motion(&mut self, ro: &mut Ro, me: usize) {
        let f = self.f[me];
        let (k, tt, dir) = (f[F_KIND], f[F_T], f[F_DIR]);
        if k == K_WALK {
            ro.dist -= dir * f[F_WALK];
        } else if k == K_STEP {
            if dir != 0 && tt < 12 {
                ro.dist -= dir * (floor_div(2500 * (1 + tt), 12) - floor_div(2500 * tt, 12));
            } else if dir == 0 && tt == 6 {
                ro.dist = isqrt(ro.dist * ro.dist + 6250000);
            }
        } else if k == K_MOVE {
            let r = self.cur(me);
            let (s, sl) = (r[R_S], r[R_SLIDE]);
            if sl > 0 && tt < s && ro.dist > 950 {
                ro.dist = 950.max(ro.dist - (floor_div(sl * (1 + tt), s) - floor_div(sl * tt, s)));
            }
            if tt == s && r[R_WAVE_V] > 0 {
                let o = self.hit_slot(me, &r) as i64;
                let f = &mut self.f[me];
                (f[F_WAVE_X], f[F_WAVE_LEFT], f[F_WAVE_V], f[F_WAVE_O]) = (0, r[R_WAVE_RANGE], r[R_WAVE_V], o);
            }
        }
        let f = &mut self.f[me];
        if f[F_WAVE_X] >= 0 {
            f[F_WAVE_X] += f[F_WAVE_V];
            if f[F_WAVE_X] > f[F_WAVE_LEFT] {
                f[F_WAVE_X] = -1;
            }
        }
    }
    /// MELEE: does ME's hit window reach OP this step?
    fn melee(&self, ro: &Ro, me: usize, op: usize) -> bool {
        let f = &self.f[me];
        f[F_KIND] == K_MOVE
            && f[F_SPENT] == 0
            && {
                let (r, tt) = (self.cur(me), f[F_T]);
                r[R_FROM] <= tt && tt < r[R_TO] && ro.dist <= r[R_REACH] + self.f[op][F_HURT]
            }
            && !self.invuln(op)
    }
    fn wave(&self, ro: &Ro, me: usize, op: usize) -> bool {
        let x = self.f[me][F_WAVE_X];
        x >= 0 && x >= ro.dist - self.f[op][F_HURT] && !self.invuln(op)
    }
    /// OUTCOME: ME's contact (melee when M, else his wave): its value to side 0, or None (absorbed).
    fn outcome(&mut self, ro: &Ro, me: usize, op: usize, m: bool) -> Option<i64> {
        let crush = if m { self.cur(me)[R_CRUSH] } else { 0 };
        let o = if m { self.hit_slot(me, &self.cur(me)) } else { self.f[me][F_WAVE_O] as usize };
        let fo = self.f[op];
        if fo[F_KIND] == K_GUARD && (4..=19).contains(&fo[F_T]) && crush == 0 {
            return Some(Self::signed(me, self.vals[me][O_BLOCK]));
        }
        if m && fo[F_KIND] == K_MOVE && self.cur(me)[R_CLS] > 0 && self.cur(op)[R_CLS] > 0 && fo[F_T] < self.cur(op)[R_TO] {
            let simul = self.melee(ro, op, me);
            let v = core_verdict(
                code_cls(self.cur(me)[R_CLS]),
                code_cls(self.cur(op)[R_CLS]),
                simul,
                Some(self.f[me][F_START]),
                Some(fo[F_START]),
            );
            return match v {
                Verdict::Hit => Some(Self::signed(me, self.vals[me][o])),
                Verdict::Cancel => Some(0),
                Verdict::Absorb => {
                    self.f[me][F_SPENT] = 1;
                    None
                }
            };
        }
        Some(Self::signed(me, self.vals[me][o]))
    }
    fn advance(&mut self, ro: &mut Ro, me: usize, op: usize) {
        self.f[me][F_T] += 1;
        let (tt, k) = (self.f[me][F_T], self.f[me][F_KIND]);
        if k == K_HOHO && tt == 6 {
            // (he reappears 1.6 m behind: the move he was dodging has lost him)
            ro.dist = 1600;
            (self.f[op][F_SPENT], self.f[op][F_WAVE_X]) = (1, -1);
        }
        if k != K_FREE && tt >= self.f[me][F_LEN] {
            (self.f[me][F_KIND], self.f[me][F_SLOT]) = (K_FREE, 2);
        }
    }

    /// port: MC-ROLLOUT — one rollout from `i`: side 0 starts action ROOT, side 1's first pick is ROOT2 (-1: the policy's). Side 0's
    /// value (milli-units).
    pub fn rollout(&mut self, root: i64, root2: i64) -> i64 {
        self.f = self.i;
        let mut ro = Ro { dist: self.g[0], react: self.g[1], tick: 0, first2: root2, root };
        let horizon = self.g[3];
        if root2 >= 0 && self.f[1][F_KIND] == K_FREE {
            // (a free opponent answers after his delay, standing till then)
            let f = &mut self.f[1];
            (f[F_KIND], f[F_T], f[F_LEN]) = (K_WAIT, 0, 1.max(self.g[4]));
        }
        if self.f[1][F_KIND] == K_MOVE {
            // (the move he is in: its rolls, this rollout's)
            let c = (rand(&mut self.g, 1000) < self.g[5]) as i64;
            self.f[1][F_CONT] = c;
            let t = (rand(&mut self.g, 1000) < self.g[6]) as i64;
            self.f[1][F_TURN] = t;
        }
        while ro.tick < horizon {
            if let Some(v) = self.decide(&mut ro, 0, 1) {
                return v;
            }
            if let Some(v) = self.decide(&mut ro, 1, 0) {
                return v;
            }
            self.step_motion(&mut ro, 0);
            self.step_motion(&mut ro, 1);
            ro.dist = (self.f[0][F_HURT] + self.f[1][F_HURT]).max(20000.min(ro.dist));
            let (m0, m1) = (self.melee(&ro, 0, 1), self.melee(&ro, 1, 0));
            let w0 = !m0 && self.wave(&ro, 0, 1);
            let w1 = !m1 && self.wave(&ro, 1, 0);
            if m0 || m1 || w0 || w1 {
                if w0 {
                    self.f[0][F_WAVE_X] = -1;
                }
                if w1 {
                    self.f[1][F_WAVE_X] = -1;
                }
                let o0 = if m0 || w0 { self.outcome(&ro, 0, 1, m0) } else { None };
                let o1 = if m1 || w1 { self.outcome(&ro, 1, 0, m1) } else { None };
                if o0.is_some() || o1.is_some() {
                    return o0.unwrap_or(0) + o1.unwrap_or(0);
                }
            }
            self.advance(&mut ro, 0, 1);
            self.advance(&mut ro, 1, 0);
            ro.tick += 1;
        }
        0
    }

    /// port: MC-SEARCH — ITERS rollouts down a two-level tree (SELECT :tree) or two decoupled bandits (`duct`); UCB in milli-units and
    /// fixnums: mean + C x isqrt(N + 1) / (1 + n). UCB_C is `*mc-ucb-c*`, OPP `*mc-opp-search*`.
    ///
    /// The Lisp's UCB macro captures A: its BASE form `(* 10 a)` is evaluated inside the macro's own `(dotimes (a 10) …)`, so the tree's
    /// second level reads the statistics of index (+ (* 10 a) a) = 11 a for the reply a (and of the root action only in its row's
    /// diagonal), while the update after the rollout writes 10 A + B. Ported as the bug (DIVERGENCES §1): BASE is a function of the
    /// macro's loop variable.
    pub fn search(&mut self, iters: i64, duct: bool, ucb_c: f32, opp: bool) {
        let c = round_f32(1000.0 * ucb_c);
        (self.n, self.sum, self.n2, self.sum2) = ([0; 10], [0; 10], [0; 100], [0; 100]);
        let ucb = |n: &[i64], sum: &[i64], legal: &[i64; 10], sign: i64, base: fn(usize) -> usize, total: i64| -> i64 {
            let (mut best, mut bs) = (-1, i64::MIN); // (most-negative-fixnum: every score is above it)
            let root = isqrt(4095.min(1 + total));
            for a in 0..10 {
                if legal[a] == 1 {
                    let k = n[base(a) + a];
                    let s = if k == 0 { i64::MAX } else { sign * floor_div(sum[base(a) + a], k) + floor_div(c * root, 1 + k) };
                    if s > bs {
                        (bs, best) = (s, a as i64);
                    }
                }
            }
            best
        };
        let zero: fn(usize) -> usize = |_| 0;
        let captured: fn(usize) -> usize = |a| 10 * a; // ((* 10 a) of the macro's own A)
        for it in 0..iters {
            let a = ucb(&self.n, &self.sum, &self.legal, 1, zero, it);
            let b = if duct {
                if opp { ucb(&self.n2, &self.sum2, &self.legal2, -1, zero, it) } else { -1 }
            } else if opp && a >= 0 {
                ucb(&self.n2, &self.sum2, &self.legal2, -1, captured, self.n[a as usize])
            } else {
                -1
            };
            if a < 0 {
                return;
            }
            let v = self.rollout(a, b);
            self.sum[a as usize] += v;
            self.n[a as usize] += 1;
            if b >= 0 {
                let j = if duct { b } else { 10 * a + b } as usize;
                self.sum2[j] += v;
                self.n2[j] += 1;
            }
        }
    }

    /// port: MC-MEAN — root action A's mean value (value units), or None when it was never played.
    pub fn mean(&self, a: usize) -> Option<f32> {
        let k = self.n[a];
        (k > 0).then(|| self.sum[a] as f32 / (1000.0 * k as f32))
    }
}
