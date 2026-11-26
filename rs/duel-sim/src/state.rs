//! The match: every piece of sim state the Lisp keeps in specials (`*p1*`, `*timer*`, `*flow*`, the ECS world, …), in one
//! value. `Clone` is the snapshot (MCTS rollouts, `snapshot_restores_hash`).
use crate::components::{Fighter, Flow, Gauges, Hazard, Ics, Motion, Pilot, Transform};
use crate::ecs::{Entities, Entity, Store};
use crate::knobs::Knobs;
use crate::rng::SimRng;
use crate::time::Time;
use duel_data::Data;

/// The running cinematic (cinema.lisp `*cine*`). Task 6 ports the director and grows it.
#[derive(Clone, Debug, PartialEq)]
pub struct Cine {
    /// The cinematic's frame (CINE-CF; the B line's `cine-cf`).
    pub cf: i64,
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
    /// Per-match mutable copy of the tuning (Task 3 ruling).
    pub knobs: Knobs,
    pub data: &'static Data,
    /// The first unported path the sim took (`unported!`), if any.
    pub unported: Option<&'static str>,
}

impl Match {
    pub fn new(data: &'static Data) -> Match {
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
            knobs: Knobs::from(data).expect("knobs"),
            data,
            unported: None,
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
            self.hazard.remove(e);
            self.ics.remove(e);
        }
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
