//! The match: every piece of sim state the Lisp keeps in specials (`*p1*`, `*timer*`, `*flow*`, the ECS world, …), in one
//! value. `Clone` is the snapshot (MCTS rollouts, `snapshot_restores_hash`).
use crate::components::{Character, Fighter, Flow, Gauges, Hazard, Ics, Motion, Pilot, Transform};
use std::collections::VecDeque;
use crate::ecs::{Entities, Entity, Store};
use crate::knobs::Knobs;
use crate::rng::SimRng;
use crate::time::Time;
use duel_data::Data;

pub use crate::cine::Cine;

/// `*mode*`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mode {
    VsCpu,
    Practice,
    VsPlayer,
    CpuCpu,
}

/// `*winner*`: 0, 1 or :draw.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Winner {
    Side(i64),
    Draw,
}

#[derive(Clone)]
pub struct Match {
    pub ents: Entities,
    pub transform: Store<Transform>,
    pub motion: Store<Motion>,
    pub fighter: Store<Fighter>,
    pub gauges: Store<Gauges>,
    pub pilot: Store<Pilot>,
    pub hazard: Store<Hazard>,
    pub ics: Store<Ics>,
    pub p1: Entity,
    pub p2: Entity,
    pub rng: SimRng,
    pub time: Time,
    /// `*match-tick*`: fixed steps since the battle began.
    pub match_tick: i64,
    pub flow: Flow,
    /// Match frames left.
    pub timer: i64,
    pub winner: Option<Winner>,
    /// Slow motion: sim frames owed (main.lisp `*slow-acc*`, a bare `0.0`: single).
    pub slow_acc: f32,
    pub cine: Option<Cine>,
    /// CINE-SAVE: A's and V's places before the cinematic moved them, [6] a flag.
    pub cine_placed: [f32; 7],
    /// `*combat-log*`.
    pub log_on: bool,
    /// The combat log lines (CLOG) since the caller last drained it.
    pub log: Vec<String>,
    pub skip_cines: bool,
    pub turbo: bool,
    /// CINE-SAVE's actors (`*cine-placed-e*`).
    pub cine_placed_e: Option<(Entity, Entity)>,
    /// Bumped by each START-CINE: CINE-STEP's `(eq c *cine*)` (a script that ended or replaced its own cinematic).
    pub cine_serial: u64,
    /// The platform's frame counter (tools/simgate/stubs.c `sg_frame`): the virtual clock RDT is derived from.
    pub frame_n: i64,
    /// `*ft*`: real seconds on the current screen.
    pub ft: f32,
    pub paused: bool,
    pub mode: Mode,
    /// `*picks*`: P1's and P2's characters.
    pub picks: [Character; 2],
    pub match_seed: i64,
    /// The engine's debug queue (stubs.c `sg_cmds`): taken at the start of the next frame.
    pub cmds: VecDeque<i64>,
    /// `*gate*`: (seed, pair) matches still to run.
    pub gate: VecDeque<(i64, [Character; 2])>,
    /// `*gate-results*`: (pair, K.O.) per finished gate match (the summary's log line is not ported).
    pub gate_results: Vec<([Character; 2], bool)>,
    pub gate_busy: bool,
    pub gate_seed0: i64,
    pub gate_seeds: i64,
    /// Per-match mutable copy of the tuning (Task 3 ruling).
    pub knobs: Knobs,
    pub data: &'static Data,
    /// `*pending*`: hits collected this step, applied together (combat.rs).
    pub pending: crate::combat::Queue<crate::combat::Pending, { crate::combat::PENDING_MAX }>,
    /// `*kikons*`: (attacker victim move) of every Kikon confirmed this step, in the order queued.
    pub kikons: crate::combat::Queue<crate::combat::KikonQ, { crate::combat::SOULS_MAX }>,
    /// `*soul-breaks*`: (attacker, victim) of every Reishi that reached 0 this step, in the order queued.
    pub soul_breaks: crate::combat::Queue<(Entity, Entity), { crate::combat::SOULS_MAX }>,
    /// While HIT-APPLY applies the step's hits: a hazard destroyed then is kept in `hz_dead` (the Lisp's PENDING holds the HAZARD
    /// struct itself, which outlives DESTROY-ENTITY: a clone ICHIGO-VANISH removes still deals its collected hit).
    pub hz_keep: bool,
    /// The hazards destroyed during this HIT-APPLY, by full handle (`hazard_of`); emptied at its end.
    pub hz_dead: Vec<(Entity, Hazard)>,
    /// ken-look.lisp `*ke-kk*`: a Kenpachi Kikon cinematic's line (KE-KK-LINE: the victim's x z, the unit toward the attacker).
    pub ke_kk: [f32; 4],
    /// The first unported path the sim took (`unported!`), if any.
    pub unported: Option<&'static str>,
    /// Not a Lisp special: the systems a replay runs as guarded stubs (flow.rs, docs/bevy/M1_NOTES.md §3); empty = off.
    pub stubs: Vec<String>,
}

impl Match {
    pub fn new(data: &'static Data) -> Match {
        // port: every kit's :hooks resolved at load (an unresolved Kenpachi / Ichigo symbol fails here, outside tests too)
        for forms in data.kits.kits.values() {
            for kit in forms.values() {
                if let Err(e) = crate::kit::hooks_of(kit) {
                    panic!("{e}");
                }
            }
        }
        Match {
            ents: Entities::default(),
            transform: Store::default(),
            motion: Store::default(),
            fighter: Store::default(),
            gauges: Store::default(),
            pilot: Store::default(),
            hazard: Store::default(),
            ics: Store::default(),
            p1: Entity::NIL,
            p2: Entity::NIL,
            rng: SimRng::default(),
            time: Time::default(),
            match_tick: 0,
            flow: Flow::Title,
            timer: 0,
            winner: None,
            slow_acc: 0.0,
            cine: None,
            cine_placed: [0.0; 7],
            log_on: false,
            log: Vec::new(),
            skip_cines: false,
            turbo: false,
            cine_placed_e: None,
            cine_serial: 0,
            frame_n: 0,
            ft: 0.0,
            paused: false,
            mode: Mode::VsCpu,
            picks: [Character::Ichigo, Character::Kenpachi],
            match_seed: 1,
            cmds: VecDeque::new(),
            gate: VecDeque::new(),
            gate_results: Vec::new(),
            gate_busy: false,
            gate_seed0: 0,
            gate_seeds: 20,
            knobs: Knobs::from(data).expect("knobs"),
            data,
            pending: Default::default(),
            kikons: Default::default(),
            soul_breaks: Default::default(),
            hz_keep: false,
            hz_dead: Vec::new(),
            ke_kk: [0.0; 4],
            unported: None,
            stubs: Vec::new(),
        }
    }

    /// port: do-entities — F on each live entity HAS accepts, in slot order: `top` read once at the start, `used` and the
    /// component re-checked at each slot (a spawn into a freed slot ahead is visited, one at or above the old `top` is not; an
    /// entity destroyed ahead is skipped). Never collect-then-mutate: every system iterates through this.
    pub fn do_entities(&mut self, has: impl Fn(&Match, Entity) -> bool, mut f: impl FnMut(&mut Match, Entity)) {
        let top = self.ents.top;
        for s in 0..top {
            if let Some(e) = self.ents.at(s)
                && has(self, e)
            {
                f(self, e);
            }
        }
    }

    /// port: spawn-entity (attach components through the stores).
    pub fn spawn(&mut self) -> Entity {
        self.ents.spawn()
    }

    /// port: destroy-entity: every store cleared, the handle stops matching.
    pub fn destroy(&mut self, e: Entity) {
        if self.ents.kill(e) {
            self.transform.remove(e);
            self.motion.remove(e);
            self.fighter.remove(e);
            self.gauges.remove(e);
            self.pilot.remove(e);
            if let Some(h) = self.hazard.take(e)
                && self.hz_keep
            {
                self.hz_dead.push((e, h));
            }
            self.ics.remove(e);
        }
    }

    /// The HAZARD struct of handle H as a pending hit holds it: the live one, else (during HIT-APPLY) the one destroyed since it was
    /// collected.
    pub fn hazard_of(&self, h: Entity) -> Option<&Hazard> {
        self.hazard.get(h).or_else(|| self.hz_dead.iter().find(|(e, _)| *e == h).map(|(_, z)| z))
    }
    pub fn hazard_of_mut(&mut self, h: Entity) -> Option<&mut Hazard> {
        if self.hazard.has(h) {
            return self.hazard.get_mut(h);
        }
        self.hz_dead.iter_mut().find(|(e, _)| *e == h).map(|(_, z)| z)
    }

    /// port: clear-entities.
    pub fn clear_entities(&mut self) {
        for s in 0..self.ents.top {
            if let Some(e) = self.ents.at(s) {
                self.destroy(e);
            }
        }
    }

    /// FNV-1a 64 over the bytes of `bits_line` (the trace's exact B text, leading `B` included).
    pub fn hash64(&self) -> u64 {
        crate::hashline::bits_line(self)
            .bytes()
            .fold(0xCBF2_9CE4_8422_2325u64, |h, b| {
                (h ^ b as u64).wrapping_mul(0x0100_0000_01B3)
            })
    }
}

#[cfg(test)]
mod tests {
    /// DO-ENTITIES' visibility: a spawn into a freed slot ahead is visited, one at the old `top` is not, a destroyed one is skipped.
    #[test]
    fn do_entities_sees_late_spawns_in_freed_slots_only() {
        let mut m = crate::hashline::tests::new_match();
        let [a, b, c] = [m.spawn(), m.spawn(), m.spawn()];
        for e in [a, b, c] {
            m.motion.insert(e, Default::default());
        }
        m.destroy(b);
        let mut seen = Vec::new();
        m.do_entities(|m, e| m.motion.has(e), |m, e| {
            seen.push(e.slot());
            if e == a {
                for _ in 0..2 {
                    let n = m.spawn(); // slot 1 (ahead: visited), then slot 3 (the old top: not)
                    m.motion.insert(n, Default::default());
                }
                m.destroy(c);
            }
        });
        assert_eq!(seen, [0, 1]);
    }
}
