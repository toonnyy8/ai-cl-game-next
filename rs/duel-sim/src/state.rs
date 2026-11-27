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
    /// Per-match mutable copy of the tuning (Task 3 ruling), shared: a snapshot and its restore copy the pointer (no allocation), and
    /// a writer goes through `Arc::make_mut`, which gives this match its own copy first, so a knob written after a snapshot is undone
    /// by the restore like any other field (M2 final review minor 3: the old `clone_from` skipped it on a stated invariant).
    pub knobs: std::sync::Arc<Knobs>,
    pub data: &'static Data,
    /// `data`'s kits by (character, form) (not a Lisp special: an index of the data for `kit_of` / `hurt_r`).
    pub kits: crate::fighter::KitTable,
    /// body.lisp `*mirror-rim*` (`Data::mirror_rim`), read and checked once at load: a mirror match P2's model rim (PARRY-WATCH).
    pub mirror_rim: [f32; 3],
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
    /// Ichigo's clone structs (ICC), shared by a clone hazard and its strikes (`HzData::Icc(index)`); emptied with the entities.
    /// ponytail: never freed inside a match (a few hundred per match at most).
    pub iccs: Vec<crate::ichigo::clones::Icc>,
    /// `*pacing-log*`: T once START-CVC ran (never reset): Ichigo's pacing log writes its ICS slots (IC-ACC-WATCH).
    pub pacing_log: bool,
    /// The first unported path the sim took (`unported!`), if any.
    pub unported: Option<&'static str>,
    /// `*mc-plan*` (cpu-mcts.lisp; a snapshot root, sim-state.lisp): per side 5 slots (state, best / second action, their values x 1000).
    pub mc_plan: [i64; 10],
    /// `*mc-next*` (a root): per side, the tick before which a deferred search does not run again.
    pub mc_next: [i64; 2],
    /// `*difficulty*`: the CPUs' difficulty at SPAWN-PAIR.
    pub difficulty: crate::components::Difficulty,
    /// `*gate-difficulty*` (debug 81020+i: 0 EASY, 1 NORMAL, 2 HARD): START-CVC's difficulty.
    pub gate_difficulty: crate::components::Difficulty,
    /// Not a Lisp special: the systems a replay runs as guarded stubs (flow.rs, docs/bevy/M1_NOTES.md §3); empty = off.
    pub stubs: Vec<String>,
    /// rollout.lisp `*in-rollout*` (WITH-ROLLOUT's binding: only a rollout's scratch match holds T; the live one is never touched by
    /// a rollout, so the binding's undo is free).
    pub in_rollout: bool,
    /// MC-FULL-ROLLOUT's `(*cai-styles* nil)`: no matchup style by `*cai-styles*` in this rollout (SIM-ROLLOUT keeps them).
    pub styles_off: bool,
    /// fighter.lisp `*view-x*` / `*view-z*` (roots, sim-state.lisp): the pair view's unit direction from the fighters' midpoint (VIEW-STEP).
    pub view_x: f32,
    pub view_z: f32,
    /// `*view-side*` (a root): +1 P1 on the left of the view, -1 on the right.
    pub view_side: f32,
    /// `*behind-yaw*` (a root): the behind camera's yaw, P1 toward P2, rate-limited.
    pub behind_yaw: f32,
    /// `*view-behind*` (configuration, SET-CAM-BEHIND at START-MATCH): humans steer by the behind view, else the pair view.
    pub view_behind: bool,
    /// Not a Lisp special: FQ-MATCH-END's Match half, done by GO-RESULTS (each learning brain's record taken, BRAIN-FQL set NIL, its
    /// health balance and result then). GO-RESULTS runs deep in the sim (a K.O. cinematic's end), which has no `Search`; the Search
    /// half (`cpu::fq::fq_match_end_apply`: the TD update, the save) is applied at `sim_step`'s end, at `flow::frame`'s end (a
    /// GO-RESULTS outside a step) and at `start_match`'s top (before FQ-ATTACH!). Nothing reads the tables or the page in between
    /// (docs/bevy/M2_NOTES.md §8).
    pub fq_end: Vec<crate::cpu::fq::FqEnd>,
}

/// `Match.iccs`' reserve: Ichigo's clones in one match (never freed inside it; a few hundred at most), so neither the live match nor
/// a snapshot slot grows it in a battle step.
pub const ICC_RESERVE: usize = 1024;

/// Match's fields for its `Clone`: every field is restored by `clone_from` (a rollout's restore, field-wise: each keeps its heap,
/// so a restore into a used slot allocates nothing while the capacities hold; `knobs` is an `Arc`, a pointer copy). The
/// destructuring has no `..`: a new field must be listed here.
macro_rules! match_clone {
    ($($f:ident),* $(,)?) => {
        impl Clone for Match {
            fn clone(&self) -> Match {
                let Match { $($f),* } = self;
                let mut c = Match { $($f: $f.clone()),* };
                // (Vec::clone is tight: keep the reserves, so a restore into this copy does not grow them)
                c.iccs.reserve_exact(self.iccs.capacity() - c.iccs.len());
                c.hz_dead.reserve_exact(self.hz_dead.capacity() - c.hz_dead.len());
                c
            }
            fn clone_from(&mut self, src: &Match) {
                let Match { $($f),* } = src;
                $(self.$f.clone_from($f);)*
            }
        }
    };
}

match_clone!(
    ents, transform, motion, fighter, gauges, pilot, hazard, ics, p1, p2, rng, time, match_tick, flow, timer, winner, slow_acc, cine,
    cine_placed, log_on, log, skip_cines, turbo, cine_placed_e, cine_serial, frame_n, ft, paused, mode, picks, match_seed, cmds, gate,
    gate_results, gate_busy, gate_seed0, gate_seeds, knobs, data, kits, mirror_rim, pending, kikons, soul_breaks, hz_keep, hz_dead, iccs,
    pacing_log, unported, mc_plan, mc_next, difficulty, gate_difficulty, stubs, in_rollout, styles_off, view_x, view_z, view_side, behind_yaw,
    view_behind, fq_end,
);

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
            knobs: std::sync::Arc::new(Knobs::from(data).expect("knobs")),
            data,
            kits: crate::fighter::KitTable::new(data),
            mirror_rim: data.mirror_rim(),
            pending: Default::default(),
            kikons: Default::default(),
            soul_breaks: Default::default(),
            hz_keep: false,
            hz_dead: Vec::with_capacity(crate::consts::MAX_ENTITIES),
            iccs: Vec::with_capacity(ICC_RESERVE),
            pacing_log: false,
            unported: None,
            stubs: Vec::new(),
            mc_plan: [0; 10],
            mc_next: [0; 2],
            difficulty: crate::components::Difficulty::Normal,
            gate_difficulty: crate::components::Difficulty::Normal,
            in_rollout: false,
            styles_off: false,
            view_x: 0.0,
            view_z: 1.0,
            view_side: 1.0,
            behind_yaw: 0.0,
            view_behind: false,
            fq_end: Vec::new(),
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
        self.iccs.clear();
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

    /// A knob written after a snapshot is undone by the restore (`clone_from`), as every other field is (M2 final review minor 3).
    #[test]
    fn clone_from_restores_a_written_knob() {
        let live = crate::hashline::tests::new_match();
        let mut slot = live.clone();
        let old = live.knobs.ken_lv_max;
        std::sync::Arc::make_mut(&mut slot.knobs).ken_lv_max = old + 7;
        assert_eq!(slot.knobs.ken_lv_max, old + 7);
        assert_eq!(live.knobs.ken_lv_max, old, "make_mut copies a shared table, the live one is untouched");
        slot.clone_from(&live);
        assert_eq!(slot.knobs.ken_lv_max, old);
    }
}
