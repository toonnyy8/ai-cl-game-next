//! port: duel/lisp/cpu-perceive.lisp — what every CPU shares: its delayed sight of the opponent (a ring of SNAPs, BRAIN-DELAY steps
//! late), the readers over a SNAP, and its presses (the brain's held button, written to its vpad). Every random number is the sim
//! stream's (`m.rng`, SIM-RND01).
use super::Brain;
use crate::components::{Contact, MoveId, Phase, State, Sym};
use crate::ecs::Entity;
use crate::fighter::{act_start, hurt_r, mv, pos_of};
use crate::hashline::Enc;
use crate::knobs::Knobs;
use crate::rng::SimRng;
use crate::state::Match;
use crate::vpad::Vpad;
use duel_data::Data;

/// port: (DEFSTRUCT SNAP) — what the CPU sees of its opponent at one step. KIND and FLAGS are the move's (`kind`, `flags`): SNAP-TAKE!
/// sets and clears them with MOVE.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Snap {
    pub x: f32,
    pub z: f32,
    pub state: State,
    pub phase: Option<Phase>,
    pub sf: i64,
    pub s: i64,
    pub active_end: i64,
    /// Frames left of his move (99 = still charging / dashing) or stun.
    pub left: i64,
    /// The tick his move / guard / Hoho began (ACT-START), -1 none.
    pub start: i64,
    pub reach: f32,
    /// What his move touched so far (NIL: nothing yet).
    pub contact: Option<Contact>,
    pub mv: Option<MoveId>,
}

impl Default for Snap {
    /// port: (MAKE-SNAP).
    fn default() -> Snap {
        Snap { x: 0.0, z: 0.0, state: State::Idle, phase: None, sf: 0, s: 0, active_end: 0, left: 0, start: 0, reach: 0.0, contact: None, mv: None }
    }
}

impl Snap {
    /// SNAP-KIND: his move's kind (lower case, "quick"), or None.
    pub fn kind(&self, d: &'static Data) -> Option<&'static str> {
        self.mv.map(|id| d.moves[id.0 as usize].kind.as_str())
    }
    /// SNAP-FLAGS: his move's flags (lower case), or none.
    pub fn flags(&self, d: &'static Data) -> &'static [String] {
        self.mv.map_or(&[], |id| d.moves[id.0 as usize].flags.as_slice())
    }
    pub fn has_flag(&self, d: &'static Data, flag: &str) -> bool {
        self.flags(d).iter().any(|f| f == flag)
    }
}

/// trace.lisp TR-B-ENC of a SNAP: `#SNAP{x,z,state,kind,phase,sf,s,active-end,left,start,reach,flags,contact,move}`.
impl Enc for Snap {
    fn enc(&self, d: &Data, s: &mut String) {
        let kw = |x: &str, s: &mut String| {
            s.push(':');
            s.push_str(&x.to_uppercase());
        };
        let mvd = self.mv.map(|id| &d.moves[id.0 as usize]);
        s.push_str("#SNAP{");
        for (i, v) in [&self.x as &dyn Enc, &self.z, &self.state].into_iter().enumerate() {
            if i > 0 {
                s.push(',');
            }
            v.enc(d, s);
        }
        s.push(',');
        match mvd {
            Some(m) => kw(&m.kind, s),
            None => s.push_str("NIL"),
        }
        for v in [&self.phase as &dyn Enc, &self.sf, &self.s, &self.active_end, &self.left, &self.start, &self.reach] {
            s.push(',');
            v.enc(d, s);
        }
        s.push(',');
        match mvd.map(|m| m.flags.as_slice()).unwrap_or(&[]) {
            [] => s.push_str("NIL"),
            fl => {
                s.push('(');
                for (i, f) in fl.iter().enumerate() {
                    if i > 0 {
                        s.push(',');
                    }
                    kw(f, s);
                }
                s.push(')');
            }
        }
        for v in [&self.contact as &dyn Enc, &self.mv] {
            s.push(',');
            v.enc(d, s);
        }
        s.push('}');
    }
}

/// port: SNAP-TAKE! — the slot PREV refilled with fighter O as he is now. Out of a move, S and ACTIVE-END keep PREV's (the Lisp
/// leaves them in the reused struct).
pub fn snap_take(m: &Match, prev: Snap, o: Entity) -> Snap {
    let f = m.fighter.get(o).expect("a fighter");
    let p = pos_of(m, o);
    let mut s = Snap { x: p[0], z: p[2], state: f.state, sf: f.sf, start: act_start(f), ..prev };
    match f.mv {
        Some(id) if f.state == State::Move => {
            let mvd = mv(m, id);
            let total = crate::rules::move_end_frame(
                &m.knobs, mvd.s as i64, mvd.a as i64, mvd.r as i64, Some(mvd.whiff as i64), f.contact, mvd.hits.is_empty(), Some(&mvd.kind),
            );
            s.phase = f.phase;
            s.s = mvd.s as i64;
            s.contact = f.contact;
            s.active_end = (mvd.s + mvd.a) as i64;
            s.reach = mvd.reach;
            s.left = if f.phase == Some(Phase::Main) { 0.max(total - f.sf) } else { 99 };
            s.mv = Some(id);
        }
        _ => {
            (s.phase, s.reach, s.contact, s.mv) = (None, 0.0, None, None);
            s.left = if f.state == State::Stun { 0.max(f.stun - f.sf) } else { 0 };
        }
    }
    s
}

/// port: SNAP-LIVE-P — is his perceived move still to hit (before the end of its active frames)?
pub fn snap_live_p(s: &Snap) -> bool {
    s.sf < s.active_end
}
/// port: SNAP-RECOVERING-P — is he, as perceived, recovering from a move (its main phase past its active frames)?
pub fn snap_recovering_p(s: &Snap) -> bool {
    s.state == State::Move && s.phase == Some(Phase::Main) && s.sf >= s.active_end
}
/// port: SNAP-PUNISHABLE-P — recovering or reeling.
pub fn snap_punishable_p(s: &Snap) -> bool {
    snap_recovering_p(s) || s.state == State::Stun
}
/// port: SNAP-LEFT-SEEN — his frames left as perceived, less the brain's delay.
pub fn snap_left_seen(s: &Snap, b: &Brain) -> i64 {
    s.left - b.delay
}
/// port: SNAP-LEAD-SEEN — frames from his perceived frame to his move's first active frame, less the brain's delay.
pub fn snap_lead_seen(s: &Snap, b: &Brain) -> i64 {
    s.s - s.sf - b.delay
}
/// port: SNAP-SEG-GAP — E's feet to his perceived move's :seg-fn capsules, or None (no window has one: every Kenpachi / Ichigo move).
pub fn snap_seg_gap(m: &mut Match, s: &Snap, e: Entity) -> Option<f32> {
    let id = s.mv?;
    let p = pos_of(m, e);
    let o = crate::fighter::opp_of(m, e);
    crate::kit::seg_gap(m, mv(m, id), o, p[0], p[2])
}
/// port: SNAP-NEAR-P — is E, at the perceived distance D, in reach of his perceived move: D < its reach + MARGIN (a :seg-fn window:
/// E's feet within its capsule + E's hurt radius + MARGIN)?
pub fn snap_near_p(m: &mut Match, s: &Snap, e: Entity, d: f32, margin: f32) -> bool {
    match snap_seg_gap(m, s, e) {
        Some(g) => g < hurt_r(m, e) + margin,
        None => d < s.reach + margin,
    }
}

// ---------------------------------------------------------------- pressing buttons

/// port: AI-PRESS — hold BUTTON (with :MOD when MODDED) for FRAMES steps (at least 1), starting now; ACT is what the brain did (the
/// Lisp's default: BUTTON).
pub fn ai_press(b: &mut Brain, button: Sym, frames: i64, modded: bool, act: Sym) {
    (b.press, b.press_mod, b.press_left, b.act) = (Some(button), modded, frames.max(1), Some(act));
}

/// port: AI-PRESS-WRITE! — the held press onto VP: its button (and :MOD when modded) down while PRESS-LEFT lasts, every other up.
pub fn ai_press_write(b: &Brain, vp: &mut Vpad) {
    let on = b.press_left > 0;
    let held = |a: &str| b.press.is_some_and(|p| p.0[1..].eq_ignore_ascii_case(a));
    for i in 0..vp.actions.len() {
        let a = vp.actions[i].as_str();
        let down = (on && held(a)) || (a == "mod" && on && b.press_mod);
        vp.set(i, down);
    }
}

/// port: AI-DASH — hold Step (the hop, then the run) toward (DIR 1) or away from (-1) him until the distance passes TO.
pub fn ai_dash(k: &Knobs, b: &mut Brain, dir: f32, to: f32) {
    ai_press(b, Sym(":STEP"), k.ai_dash_frames, false, Sym(":DASH"));
    (b.dash, b.dash_to) = (dir, to);
}

/// port: AI-EVENT-ROLLS — one roll per opponent action (SNAP S starts a new one): the guard roll, then the Hoho roll.
pub fn ai_event_rolls(rng: &mut SimRng, b: &mut Brain, s: &Snap) {
    if s.start != b.roll_key {
        b.roll_key = s.start;
        b.guard_roll = rng.rnd01();
        b.hoho_roll = rng.rnd01();
    }
}

/// port: AI-STRAFE — the strafe's length (*AI-STRAFE-TIME*: from + floor (span x r)), then its side.
pub fn ai_strafe(rng: &mut SimRng, k: &Knobs, b: &mut Brain) {
    b.strafe_t = k.ai_strafe_time.0 + crate::cl::floor_f32(k.ai_strafe_time.1 as f32 * rng.rnd01());
    b.strafe = if rng.rnd01() < 0.5 { -1.0 } else { 1.0 };
}

/// port: AI-WALK — the stick toward the range LO..HI, strafing inside it.
pub fn ai_walk(b: &Brain, vp: &mut Vpad, d: f32, lo: f32, hi: f32) {
    let x = if lo <= d && d <= hi { b.strafe } else { 0.3 * b.strafe };
    vp.stick(x, if d > hi { 1.0 } else if d < lo { -1.0 } else { 0.0 });
}

// ---------------------------------------------------------------- perception

/// port: SNAP-DIST — E's distance to the perceived S (SQRT of two EXPT 2s: musl's powf, `cl::expt2`).
pub fn snap_dist(m: &Match, s: &Snap, e: Entity) -> f32 {
    let p = pos_of(m, e);
    libm::sqrtf(crate::cl::expt2(s.x - p[0]) + crate::cl::expt2(s.z - p[2]))
}

/// port: BRAIN-SNAP-AGO over a ring — its SNAP of K steps ago, after this step's perceive (the head already moved on); None if none yet.
pub fn snap_ago(ring: &[Option<Snap>], head: i64, k: i64) -> Option<Snap> {
    ring[crate::cl::modulo(head - 1 - k, ring.len() as i64) as usize]
}
pub fn brain_snap_ago(b: &Brain, k: i64) -> Option<Snap> {
    snap_ago(&b.ring, b.head, k)
}

/// BRAIN-PERCEIVE's ring part: the head slot refilled (TAKE of its old value; a fresh ring: every other slot too, each from its own
/// old value), the SNAP of DELAY steps ago read, the head moved on.
pub fn perceive_ring(ring: &mut [Option<Snap>], head: &mut i64, fresh: &mut bool, delay: i64, mut take: impl FnMut(Snap) -> Snap) -> Snap {
    let n = ring.len() as i64;
    let h = *head as usize;
    ring[h] = Some(take(ring[h].unwrap_or_default()));
    if *fresh {
        // (match start, round reset: every slot is this step's view, so the first DELAY steps see the round's start)
        *fresh = false;
        for i in (0..ring.len()).filter(|&i| i != h) {
            ring[i] = Some(take(ring[i].unwrap_or_default()));
        }
    }
    let s = ring[crate::cl::modulo(*head - delay, n) as usize].expect("a filled ring slot");
    *head = crate::cl::modulo(*head + 1, n);
    s
}

/// port: BRAIN-PERCEIVE — E's brain sees opponent O this step: his SNAP into the ring; the SNAP of BRAIN-DELAY steps ago (a copy) and
/// the distance to it. A J of his that begins is stamped in JSTARTS (newest first), which keeps only *AI-MASH-WINDOW*'s.
pub fn brain_perceive(m: &mut Match, e: Entity, o: Entity) -> (Snap, f32) {
    let mut b = m.fighter.get_mut(e).and_then(|f| f.brain.take()).expect("a brain");
    let delay = b.delay;
    let s = perceive_ring(&mut b.ring, &mut b.head, &mut b.fresh, delay, |prev| snap_take(m, prev, o));
    let d = snap_dist(m, &s, e);
    if s.state == State::Move && s.kind(m.data) == Some("quick") && s.start != b.jkey {
        b.jkey = s.start;
        b.jstarts.insert(0, m.match_tick);
    }
    if !b.jstarts.is_empty() {
        drop_old_jstarts(&mut b.jstarts, m.match_tick, m.knobs.ai_mash_window);
    }
    m.fighter.get_mut(e).unwrap().brain = Some(b);
    (s, d)
}

/// port: DROP-OLD-JSTARTS — the ticks of L within WINDOW of NOW, in order.
pub fn drop_old_jstarts(l: &mut Vec<i64>, now: i64, window: i64) {
    l.retain(|&t| now - t <= window);
}

/// port: AI-MASH-P — is he mashing J, as the brain saw him: *AI-MASH-STARTS* J starts within the window?
pub fn ai_mash_p(k: &Knobs, b: &Brain) -> bool {
    b.jstarts.len() as i64 >= k.ai_mash_starts
}
