//! port: duel/lisp/hazards.lisp — every hit that isn't a fighter's melee is one HAZARD entity: spawning (SPAWN-HAZARD, SPAWN-LOOK,
//! SPAWN-GROUND-LINE: a look-only hazard is still an entity, in B and in H's `haz` count), the per-step move / age
//! (HAZARD-SYSTEM), the volumes (HAZARD-TOUCHES-P), the hits handed to combat.rs (COLLECT-HAZARD-HITS, HAZARD-CONNECTED) and perfect
//! Hoho's test (HAZARD-THREAT-P). HAZARD-DRAW is a look (M3). A hazard's `:hook` symbol resolves by name (`HzHook`); one not ported
//! yet is `unported!` with its name.
use crate::cl::expt2;
use crate::combat::{HwRef, Pending};
use crate::components::{Cls, Hazard, HazardKind, HitWin, HzData, MoveId, Sym};
use crate::ecs::Entity;
use crate::fighter::{defender_state, kit_of, pos_of, yaw_of};
use crate::kit::sp_move_p;
use crate::math::{fwd_x, fwd_z};
use crate::state::Match;
use crate::time::STEP;

/// A hazard's `:hook` function, resolved from its symbol (as `kit::resolve` does a kit's hooks). The kit tasks add their hazards'
/// hooks.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum HzHook {
    DelayHit,
    /// Ichigo's clones (ICHIGO-CLONE-HZ), their strikes (ICHIGO-STRIKE-HZ), 残像's afterimages (ICHIGO-ECHO-HZ).
    IcClone,
    IcStrike,
    IcEcho,
}

impl HzHook {
    pub fn resolve(name: &str) -> Option<HzHook> {
        match name {
            "DELAY-HIT-HOOK" => Some(HzHook::DelayHit),
            "ICHIGO-CLONE-HZ" => Some(HzHook::IcClone),
            "ICHIGO-STRIKE-HZ" => Some(HzHook::IcStrike),
            "ICHIGO-ECHO-HZ" => Some(HzHook::IcEcho),
            _ => None,
        }
    }
}

/// HZ's hook, if it has one; an unresolved symbol records `unported!(its name)` and gives None (the caller then checks `m.unported`).
fn hook_of(m: &mut Match, hz: Entity) -> Option<HzHook> {
    let name = m.hazard.get(hz)?.hook?.0;
    match HzHook::resolve(name) {
        Some(k) => Some(k),
        None => crate::unported!(m, name, None),
    }
}

/// SPAWN-HAZARD's keys. The `Option` ones default from the owner's move now (the Lisp's computed defaults); `x` … `size` are f32 already.
#[derive(Clone, Debug)]
pub struct HzArgs {
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub yaw: f32,
    pub speed: f32,
    pub size: f32,
    pub life: i64,
    pub delay: i64,
    pub hits: i64,
    pub hw: Option<HitWin>,
    pub look: Option<Sym>,
    pub src: bool,
    pub hook: Option<Sym>,
    pub data: HzData,
    pub sp: Option<bool>,
    pub sp_mv: Option<Option<MoveId>>,
    pub cls: Option<Option<Cls>>,
    pub sp_paid: Option<f32>,
    pub sp_scale: Option<f32>,
    pub sp_src: Option<i64>,
}

impl Default for HzArgs {
    fn default() -> Self {
        HzArgs {
            x: 0.0,
            y: 0.0,
            z: 0.0,
            yaw: 0.0,
            speed: 0.0,
            size: 0.5,
            life: 60,
            delay: 0,
            hits: 1,
            hw: None,
            look: None,
            src: false,
            hook: None,
            data: HzData::Nil,
            sp: None,
            sp_mv: None,
            cls: None,
            sp_paid: None,
            sp_scale: None,
            sp_src: None,
        }
    }
}

/// port: SPAWN-HAZARD: a new hazard of KIND for fighter OWNER. Defaults (DUEL_SP §6, S5): SP — spawned while the owner's move is an SP;
/// SP-MV — a hit hazard fired by a Kikon-holding segment with :kikon-strike; CLS — a hit hazard's class, the owner's move's while in
/// :move; SP-PAID (0 once refunded), SP-SCALE (frozen now) and SP-SRC (the segment's start tick) of that classed move.
pub fn spawn_hazard(m: &mut Match, kind: HazardKind, owner: Entity, a: HzArgs) -> Entity {
    let f = m.fighter.get(owner);
    let sp = a.sp.unwrap_or_else(|| f.and_then(|f| f.mv).is_some_and(|id| sp_move_p(m.data, kit_of(m, owner), crate::fighter::mv(m, id))));
    let fh = f.filter(|_| a.hw.is_some()); // (and hw owner (fighter owner))
    let sp_mv = a.sp_mv.unwrap_or_else(|| {
        fh.and_then(|f| f.mv).filter(|&id| {
            let mvd = crate::fighter::mv(m, id);
            crate::core_sim::core_kikon_p(m, owner, Some(mvd)) && mvd.params.kikon_strike.is_some()
        })
    });
    let cls = a.cls.unwrap_or_else(|| fh.filter(|f| f.state == crate::components::State::Move).and_then(|f| f.cls));
    let fc = f.filter(|_| cls.is_some()); // (and cls (fighter owner))
    let sp_paid = a.sp_paid.unwrap_or_else(|| fc.filter(|f| !f.sp_back).map_or(0.0, |f| f.sp_paid));
    let sp_scale = a.sp_scale.unwrap_or_else(|| fc.map_or(1.0, |f| crate::sp::sp_scale(f.sp_paid, f.sp_cost)));
    let sp_src = a.sp_src.unwrap_or_else(|| fc.map_or(-1, |f| f.cls_t));
    let hits_left = if a.hw.is_some() { a.hits } else { 0 };
    let e = m.spawn();
    m.hazard.insert(
        e,
        Hazard {
            kind: Some(kind),
            owner,
            x: a.x,
            y: a.y,
            z: a.z,
            px: a.x,
            pz: a.z,
            yaw: a.yaw,
            speed: a.speed,
            size: a.size,
            age: 0,
            life: a.life,
            delay: a.delay,
            hits_left,
            rehit: 0,
            hw: a.hw,
            src: a.src,
            hook: a.hook,
            data: a.data,
            sp,
            sp_mv,
            cls,
            sp_paid,
            sp_scale,
            sp_src,
            look: a.look,
        },
    );
    e
}

/// port: SPAWN-LOOK: a look-only :fx hazard of fighter E at X Z (default: E's feet) drawn by LOOK: no hit, but an entity.
#[allow(clippy::too_many_arguments)]
pub fn spawn_look(m: &mut Match, e: Entity, look: Sym, x: Option<f32>, z: Option<f32>, yaw: f32, size: f32, life: i64, delay: i64, data: HzData) -> Entity {
    let p = pos_of(m, e);
    let (x, z) = (x.unwrap_or(p[0]), z.unwrap_or(p[2]));
    spawn_hazard(m, HazardKind::Fx, e, HzArgs { x, z, yaw, size, life, delay, look: Some(look), data, ..HzArgs::default() })
}

/// port: SPAWN-GROUND-LINE: a look-only :line hazard of fighter E from his feet along his facing, SIZE m long, LIFE frames.
pub fn spawn_ground_line(m: &mut Match, e: Entity, size: f32, life: i64, look: Sym) -> Entity {
    let p = pos_of(m, e);
    let yaw = yaw_of(m, e);
    spawn_hazard(m, HazardKind::Line, e, HzArgs { x: p[0], z: p[2], yaw, size, life, look: Some(look), ..HzArgs::default() })
}

/// port: CLEAR-HAZARDS.
pub fn clear_hazards(m: &mut Match) {
    m.do_entities(|m, h| m.hazard.has(h), |m, h| m.destroy(h));
}

/// port: HAZARD-TARGET: the fighter a hazard of HZ's owner can hit (his opponent), or None.
pub fn hazard_target(m: &Match, hz: &Hazard) -> Option<Entity> {
    m.ents.alive(hz.owner).then(|| m.fighter.get(hz.owner).map(|f| f.opp)).flatten()
}

// ---------------------------------------------------------------- per step

/// port: HAZARD-STEP: its hook's :step first (T skips the generic step), the delay, then age / move / expire.
pub fn hazard_step(m: &mut Match, h: Entity) {
    if m.hazard.get(h).unwrap().hook.is_some() {
        let k = hook_of(m, h);
        let skip = match k {
            Some(HzHook::DelayHit) => crate::combat::delay_hit_hook(m, h),
            Some(HzHook::IcClone) => {
                crate::ichigo::clones::clone_hz_step(m, h);
                true
            }
            Some(HzHook::IcEcho) => {
                crate::ichigo::clones::echo_hz_step(m, h);
                true
            }
            Some(HzHook::IcStrike) => false, // (it answers :touches only)
            None => return, // (unported)
        };
        if skip || m.unported.is_some() || !m.ents.alive(h) {
            return;
        }
    }
    let arena = m.knobs.arena_radius;
    let Some(hz) = m.hazard.get_mut(h) else { return };
    if hz.delay > 0 {
        hz.delay -= 1;
        return;
    }
    hz.age += 1;
    if hz.rehit > 0 {
        hz.rehit -= 1;
    }
    (hz.px, hz.pz) = (hz.x, hz.z);
    if hz.kind == Some(HazardKind::Wave) {
        let d = hz.speed * STEP;
        hz.x += d * fwd_x(hz.yaw);
        hz.z += d * fwd_z(hz.yaw);
        if expt2(hz.x) + expt2(hz.z) > expt2(arena + 2.0) { // (EXPT 2: musl's powf, M2_NOTES §3)
            hz.age = hz.life;
        }
    }
    if hz.age >= hz.life {
        m.destroy(h);
    }
}

/// port: HAZARD-SYSTEM: move / age every hazard one fixed step.
pub fn hazard_system(m: &mut Match) {
    m.do_entities(|m, h| m.hazard.has(h) && m.unported.is_none(), hazard_step);
}

// ---------------------------------------------------------------- volumes

/// port: HAZARD-ACTIVE-P.
pub fn hazard_active_p(hz: &Hazard) -> bool {
    hz.hw.is_some() && hz.hits_left > 0 && hz.rehit <= 0 && hz.delay <= 0
}

/// port: HAZARD-TOUCHES-P: does HZ's world volume touch the hurt cylinder at (TX TY TZ), radius TR, height TH? A wave's box; any
/// other kind asks its hook (:touches); none: no.
pub fn hazard_touches_p(m: &mut Match, h: Entity, tx: f32, ty: f32, tz: f32, tr: f32, th: f32) -> bool {
    let hz = m.hazard.get(h).unwrap();
    if hz.kind == Some(HazardKind::Wave) {
        let (wb0, wb1) = (m.knobs.wave_box.0, m.knobs.wave_box.1);
        return crate::hitvol::obox_cyl_hit_p(hz.x, 1.0, hz.z, hz.yaw, hz.size, wb0, wb1, tx, ty, tz, tr, th);
    }
    if hz.hook.is_none() {
        return false;
    }
    match hook_of(m, h) {
        Some(HzHook::IcStrike) => crate::ichigo::clones::strike_touches(m, h, tx, ty, tz, tr, th),
        Some(HzHook::DelayHit | HzHook::IcClone | HzHook::IcEcho) => false, // (they answer only :step)
        None => false,                    // (unported)
    }
}

/// port: COLLECT-HAZARD-HITS: every active hazard's contact with its target, onto the step's pending hits.
pub fn collect_hazard_hits(m: &mut Match) {
    m.do_entities(|m, h| m.hazard.has(h) && m.unported.is_none(), |m, h| {
        let hz = m.hazard.get(h).unwrap();
        if !hazard_active_p(hz) {
            return;
        }
        let Some(tg) = hazard_target(m, hz).filter(|&t| m.ents.alive(t)) else { return };
        let q = pos_of(m, tg);
        let (tr, th) = body_of(m, tg);
        if !hazard_touches_p(m, h, q[0], q[1], q[2], tr, th) {
            return;
        }
        let hz = m.hazard.get(h).unwrap();
        let owner = hz.owner;
        let (sx, sz) = if hz.src { (pos_of(m, owner)[0], pos_of(m, owner)[2]) } else { (hz.x, hz.z) };
        let state = defender_state(m, tg);
        if m.unported.is_some() {
            return;
        }
        crate::combat::push_pending(m, Pending { att: owner, def: tg, hw: HwRef::Hazard(h), sx, sz, hazard: Some(h), state, ..Pending::new(state) });
    });
}

/// `(body-hurt-r b)`, `(body-hurt-h b)` of E's model body (the current kit's body: docs/bevy/M1_NOTES.md §1).
pub fn body_of(m: &Match, e: Entity) -> (f32, f32) {
    let b = &m.data.bodies[&kit_of(m, e).body];
    (b.hurt_r, b.hurt_h)
}

/// port: HAZARD-CONNECTED: HZ's hit took effect: one hit fewer (a wave is spent: gone at the next step), a multi-hit one waits.
pub fn hazard_connected(m: &mut Match, h: Entity) {
    let rehit = m.knobs.hazard_rehit;
    let Some(hz) = m.hazard_of_mut(h) else { return }; // (a hazard destroyed earlier this HIT-APPLY: its struct, as the Lisp's)
    hz.hits_left -= 1;
    hz.rehit = rehit;
    if hz.hits_left <= 0 && hz.kind == Some(HazardKind::Wave) {
        hz.life = hz.age;
    }
}

/// port: HAZARD-THREAT-P: one of OWNER's hazards is active (or becomes so within *PERFECT-LEAD* frames) and touches VICTIM's hurt
/// cylinder grown by *PERFECT-INFLATE*.
pub fn hazard_threat_p(m: &mut Match, owner: Entity, victim: Entity) -> bool {
    let q = pos_of(m, victim);
    let (tr, th) = body_of(m, victim);
    let (lead, inf) = (m.knobs.perfect_lead, m.knobs.perfect_inflate);
    let mut found = false;
    m.do_entities(|m, h| m.hazard.has(h), |m, h| {
        let hz = m.hazard.get(h).unwrap();
        if !found
            && m.unported.is_none()
            && hz.owner == owner
            && hz.hw.is_some()
            && hz.hits_left > 0
            && hz.delay <= lead
            && hazard_touches_p(m, h, q[0], q[1], q[2], tr + inf, th + inf)
        {
            found = true;
        }
    });
    found
}
