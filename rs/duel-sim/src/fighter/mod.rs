//! port: duel/lisp/fighter.lisp — FIGHTER-SYSTEM: creation, the small helpers, commands, the system section. The neutral
//! state changes and per-state steps are in `states`, starting a move and the `:move` step in `moves`, the reactions in `react`,
//! physics in `physics`. Animation is a sink (docs/bevy/M1_NOTES.md §1): every clip the Lisp plays is a `// look:` line. PILOT-SYSTEM
//! stays in flow.rs (it was ported there with the step, Task 6), re-exported here.
mod moves;
mod physics;
mod react;
mod states;

pub use crate::flow::pilot_system;
use crate::gauges::{awaken, burst, burst_ok_p};
pub use moves::*;
pub use physics::{fighter_physics, separate_fighters, set_slide};
pub use react::*;
pub use states::*;

use crate::components::{Burst, Button, Character, Contact, Fighter, Form, Gauges, KitId, MoveId, Motion, Phase, Pilot, State, Str, Transform};
use crate::ecs::Entity;
use crate::state::Match;
use crate::vpad::{Mod, Vpad};
use duel_data::{Kit, Move};

/// A command of control.lisp's `*commands*`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cmd {
    Awaken,
    Hoho,
    Burst,
    Step,
    Sp,
    Q,
}

impl Cmd {
    /// The keyword's name as `~a` prints it.
    pub fn name(self) -> &'static str {
        match self {
            Cmd::Awaken => "AWAKEN",
            Cmd::Hoho => "HOHO",
            Cmd::Burst => "BURST",
            Cmd::Step => "STEP",
            Cmd::Sp => "SP",
            Cmd::Q => "Q",
        }
    }
}

/// port: control.lisp `*commands*`, highest priority first: (command, vpad button, mod). A test pins it to tables.json.
pub const COMMANDS: [(Cmd, Button, Mod); 6] = [
    (Cmd::Awaken, Button::Awaken, Mod::Yes),
    (Cmd::Hoho, Button::Step, Mod::Yes),
    (Cmd::Burst, Button::Awaken, Mod::No),
    (Cmd::Step, Button::Step, Mod::No),
    (Cmd::Sp, Button::Quick, Mod::Yes),
    (Cmd::Q, Button::Quick, Mod::No),
];

/// port: `*neutral-commands*` (:awaken :hoho :burst :step :sp :q).
pub const NEUTRAL_COMMANDS: [Cmd; 6] = [Cmd::Awaken, Cmd::Hoho, Cmd::Burst, Cmd::Step, Cmd::Sp, Cmd::Q];
/// port: `*run-commands*`.
pub const RUN_COMMANDS: [Cmd; 5] = [Cmd::Hoho, Cmd::Burst, Cmd::Step, Cmd::Sp, Cmd::Q];
/// port: `*run-commands-p*` (`(cons :awaken *run-commands*)`).
pub const RUN_COMMANDS_P: [Cmd; 6] = [Cmd::Awaken, Cmd::Hoho, Cmd::Burst, Cmd::Step, Cmd::Sp, Cmd::Q];
/// NEUTRAL-STEP's list while guarding or just out of a guard (no attack).
pub const GUARD_COMMANDS: [Cmd; 4] = [Cmd::Awaken, Cmd::Burst, Cmd::Hoho, Cmd::Step];

/// port: kit.lisp `*kit-commands*` (:q :f :sig :sp1 :sp2 :breaker :kikon): of `*commands*` only :q is one, at index 0 (its
/// FIGHTER-CD slot).
fn kit_command_index(c: Cmd) -> Option<usize> {
    (c == Cmd::Q).then_some(0)
}

// ---------------------------------------------------------------- small helpers (components.lisp / ecs.lisp readers)

/// port: components.lisp OPP-OF.
pub fn opp_of(m: &Match, e: Entity) -> Entity {
    m.fighter.get(e).map_or(Entity::NIL, |f| f.opp)
}
/// port: components.lisp SIDE-NAME.
pub fn side_name(m: &Match, e: Entity) -> &'static str {
    if m.fighter.get(e).is_some_and(|f| f.side == 0) { "P1" } else { "P2" }
}
/// port: ecs.lisp POS-OF.
pub fn pos_of(m: &Match, e: Entity) -> [f32; 3] {
    m.transform.get(e).map_or([0.0; 3], |t| t.pos)
}
/// port: ecs.lisp YAW-OF.
pub fn yaw_of(m: &Match, e: Entity) -> f32 {
    m.transform.get(e).map_or(0.0, |t| t.yaw)
}
/// port: components.lisp STATE-OF.
pub fn state_of(m: &Match, e: Entity) -> Option<State> {
    m.fighter.get(e).map(|f| f.state)
}
/// port: components.lisp KIT-OF: the kit data of E's form.
pub fn kit_of(m: &Match, e: Entity) -> &'static Kit {
    let k = m.fighter.get(e).and_then(|f| f.kit).expect("a fighter has a kit");
    m.kits.get(k.character, k.form).0
}
const NC: usize = Character::ALL.len();
const NF: usize = Form::ALL.len();
/// Every kit of the data by (character, form), with its body's hurt radius: built once per match, since `kit_of` / `hurt_r` run many
/// times a step (two map lookups by name each, before).
#[derive(Clone, Copy)]
pub struct KitTable([[Option<(&'static Kit, f32)>; NF]; NC]);
impl KitTable {
    pub fn new(data: &'static duel_data::Data) -> KitTable {
        let mut t = [[None; NF]; NC];
        for (ci, &c) in Character::ALL.iter().enumerate() {
            for (fi, &f) in Form::ALL.iter().enumerate() {
                let kit = data.kits.kits.get(&c.name().to_lowercase()).and_then(|fs| fs.get(&f.name().to_lowercase()));
                t[ci][fi] = kit.map(|k| (k, data.bodies.get(&k.body).unwrap_or_else(|| panic!("kit {c} {f}: unknown body {}", k.body)).hurt_r));
            }
        }
        KitTable(t)
    }
    /// (the kit, its body's hurt_r); panics on a kit the data lacks, as `find_kit`.
    pub fn get(&self, c: Character, f: Form) -> (&'static Kit, f32) {
        self.0[c as usize][f as usize].unwrap_or_else(|| panic!("unknown kit {c} {f}"))
    }
}
pub fn mv(m: &Match, id: MoveId) -> &'static Move {
    &m.data.moves[id.0 as usize]
}
/// The MoveId of a move of the data (kit.rs readers return `&Move`). ponytail: a scan over 549 moves per move start; index if hot.
pub fn id_of(m: &Match, x: &Move) -> MoveId {
    MoveId(m.data.moves.iter().position(|y| std::ptr::eq(x, y)).expect("a move of the data") as u16)
}
/// port: CURRENT-MOVE: F's move while his state is :move.
pub fn current_move(f: &Fighter) -> Option<MoveId> {
    if f.state == State::Move { f.mv } else { None }
}
/// `(body-hurt-r (model-body (model e)))`: the current kit's body (every body of a character has the same hurt_r / hurt_h,
/// docs/bevy/M1_NOTES.md §1).
pub fn hurt_r(m: &Match, e: Entity) -> f32 {
    let k = m.fighter.get(e).and_then(|f| f.kit).expect("a fighter has a kit");
    m.kits.get(k.character, k.form).1
}
pub(crate) fn fighter(m: &Match, e: Entity) -> &Fighter {
    m.fighter.get(e).expect("a fighter")
}
pub(crate) fn fighter_mut(m: &mut Match, e: Entity) -> &mut Fighter {
    m.fighter.get_mut(e).expect("a fighter")
}
pub(crate) fn vpad(m: &mut Match, e: Entity) -> &mut Vpad {
    &mut m.pilot.get_mut(e).expect("a pilot").vpad
}

/// port: HALT!: E's velocity zeroed.
pub fn halt(m: &mut Match, e: Entity) {
    if let Some(mo) = m.motion.get_mut(e) {
        mo.vel = [0.0; 3];
    }
}

/// port: ACT-START: the tick F's current action began (a move's CLS-T, a guard's or Hoho's STATE-T), else -1.
pub fn act_start(f: &Fighter) -> i64 {
    match f.state {
        State::Move if f.mv.is_some() => f.cls_t,
        State::Guard | State::Hoho => f.state_t,
        _ => -1,
    }
}

/// port: CALLOUT.
pub fn callout(m: &mut Match, e: Entity, text: &'static str) {
    let t = m.knobs.callout_frames;
    let f = fighter_mut(m, e);
    (f.callout, f.callout_t) = (Some(Str(text)), t);
}

/// port: components.lisp PASSIVE-P: does E's current form have passive P (`projectile-cut`, `parry-block`)?
pub fn passive_p(m: &Match, e: Entity, p: &str) -> bool {
    kit_of(m, e).passives.iter().any(|x| x == p)
}

/// port: GAUGES-RED-P: is G's Reishi in the red (RED-P)?
pub fn gauges_red_p(k: &crate::knobs::Knobs, g: &Gauges) -> bool {
    crate::rules::red_p(k, g.reishi, g.reishi_max)
}

/// port: combat.lisp RESPECT: E's form's :respect-callout, if any.
pub fn respect(m: &mut Match, e: Entity) {
    if let Some(c) = &kit_of(m, e).respect_callout {
        callout(m, e, c);
    }
}

/// port: SPEND-FS.
pub fn spend_fs(m: &mut Match, e: Entity, amount: f32) {
    let g = m.gauges.get_mut(e).expect("gauges");
    g.fs = crate::cl::max_f32(0.0, g.fs - amount);
    g.fs_idle = 0;
}

/// port: REFUND-FS: give back AMOUNT of flash-step an SP segment paid (SP-REFUND: exactly that, capped at *FS-MAX*).
pub fn refund_fs(m: &mut Match, e: Entity, amount: f32) {
    let fs = crate::sp::sp_refund(&m.knobs, m.gauges.get(e).expect("gauges").fs, amount);
    m.gauges.get_mut(e).unwrap().fs = fs;
}

/// port: HOHO-READY-P.
pub fn hoho_ready_p(m: &Match, e: Entity) -> bool {
    let (f, g) = (fighter(m, e), m.gauges.get(e).expect("gauges"));
    crate::core::core_hoho_open_p(f.xch, f.xch_done) && crate::rules::hoho_allowed_p(false, g.fs, f.hoho_lock, g.burst, m.knobs.fs_hoho)
}

// ---------------------------------------------------------------- creation

/// port: SPAWN-FIGHTER: SIDE's fighter playing CHARACTER's :base kit at (X 0 Z) facing YAW; CPU seats get a brain of `*difficulty*`
/// (SPAWN-PAIR's) and no device reader (`cam_relative` false).
pub fn spawn_fighter(m: &mut Match, side: i64, character: Character, x: f32, z: f32, yaw: f32, cpu: bool) -> Entity {
    let kit = m.kits.get(character, Form::Base).0;
    let e = m.spawn();
    m.transform.insert(e, Transform { pos: [x, 0.0, z], yaw });
    m.motion.insert(e, Motion::default());
    // look: model (body, mirror tint / rim), blade
    m.fighter.insert(
        e,
        Fighter {
            side,
            character: Some(character),
            kit: Some(KitId { character, form: Form::Base }),
            brain: cpu.then(|| crate::cpu::Brain::new(m.difficulty, m.knobs.ai_delay.get(m.difficulty.name(), 14))),
            ..Fighter::default()
        },
    );
    let reishi = kit.reishi as i64;
    m.gauges.insert(e, Gauges { reishi: crate::cl::Num::I(reishi), reishi_max: reishi, konpaku: m.knobs.konpaku_max, ..Gauges::new(&m.knobs) });
    let vpad = Vpad::duel(m.data, &m.knobs).unwrap_or_else(|err| panic!("vpad: {err}"));
    m.pilot.insert(e, Pilot { vpad, cam_relative: !cpu });
    // look: refresh-look, the stance clip
    e
}

// ---------------------------------------------------------------- the view humans steer by

/// port: STICK-RELATIVE: E's stick as (toward, strafe) relative to his opponent. A CPU pilot writes (strafe, toward) directly;
/// a human's (`cam_relative`) is read through VIEW-STEP's view, M2.
pub fn stick_relative(m: &mut Match, e: Entity) -> (f32, f32) {
    let p = m.pilot.get(e).expect("a pilot");
    if p.cam_relative {
        crate::unported!(m, "view-step", (0.0, 0.0)) // (*view-x* / *behind-yaw*: a human's stick, M2)
    }
    (p.vpad.sy, p.vpad.sx)
}

/// port: WORLD-DIR: the world XZ direction of stick TO / ST relative to E's opponent (F's OX OZ).
pub fn world_dir(m: &Match, e: Entity, to: f32, st: f32) -> (f32, f32) {
    let (p, f) = (pos_of(m, e), fighter(m, e));
    crate::rules::toward_strafe_dir(to, st, p[0], p[2], f.ox, f.oz)
}

// ---------------------------------------------------------------- commands

/// port: TRY-COMMAND: start CMD (pressed with BUTTON) if the rules allow it now. T when something started. (WITH, a chained L
/// after a K link, comes only from MOVE-COMMANDS' :sig clause, unreachable: :sig is not in `*commands*`.)
pub fn try_command(m: &mut Match, e: Entity, cmd: Cmd, button: Option<Button>) -> bool {
    match cmd {
        Cmd::Step => {
            start_step(m, e);
            true
        }
        Cmd::Hoho => {
            let f = fighter(m, e);
            if !crate::core::core_hoho_open_p(f.xch, f.xch_done) {
                if let Some(b) = button {
                    vpad(m, e).consume(b as usize);
                }
                // look: emit :refused
                crate::clog!(m, "{} refused hoho: exchange", side_name(m, e));
                false
            } else if hoho_ready_p(m, e) {
                start_hoho(m, e);
                true
            } else {
                false
            }
        }
        // :awaken is only the form's :p hook (no live kit has one; `:no-awaken` cannot be in the data: duel_data's Core denies
        // unknown keys); the awakening itself is AWAKEN-PRESS!'s
        Cmd::Awaken => {
            if let Some(h) = kit_of(m, e).hooks.get("p") {
                crate::unported!(m, h.as_str(), false) // (a form's :p hook: Hisagi's bind throw, M4)
            }
            false
        }
        Cmd::Burst => match burst_ok_p(m, e) {
            Some(md) => {
                fighter_mut(m, e).burst = Some(md); // applied after both stepped
                true
            }
            None => false,
        },
        Cmd::Sp => crate::core_sim::core_sp_start(m, e),
        Cmd::Q => {
            if let Some(h) = kit_hook_sym(m, e, "command") {
                crate::unported!(m, h, false) // (KIT-COMMAND-MOVE with E: the :command hook, Hisagi's, M4)
            }
            let kit = kit_of(m, e);
            let Some(mvd) = crate::kit::kit_command_move(m.data, kit, "q") else { return false };
            if !kit_command_ok_p(m, e, "q", None) {
                return false;
            }
            if mvd.cooldown > 0 {
                fighter_mut(m, e).cd[0] = mvd.cooldown as i64; // ((position :q *kit-commands*))
            }
            // ((eq cmd :kikon): KIKON-N fixed now; :kikon is not in *commands*)
            let id = id_of(m, mvd);
            start_move(m, e, id, button);
            true
        }
    }
}

/// port: kit.lisp `*kit-commands*`: a kit command's FIGHTER-CD slot.
fn kit_cd_index(cmd: &str) -> Option<usize> {
    ["q", "f", "sig", "sp1", "sp2", "breaker", "kikon"].iter().position(|c| *c == cmd)
}

/// port: the form's :ok hook on kit command CMD (COMBO: a chained follow-up; ICHIGO-OK ignores it).
fn kit_ok_hook(m: &mut Match, e: Entity, cmd: &str) -> bool {
    match kit_hook_sym(m, e, "ok") {
        None => true,
        Some(h) => match ichigo_hook(h) {
            Some(crate::ichigo::Hook::Ok) => crate::ichigo::hooks::ok(m, e, cmd),
            _ => crate::unported!(m, h, false),
        },
    }
}

/// port: KIT-COMMAND-OK-P: may E start kit command CMD (`q`, `sig`, …) now: not cooling down, and the form's :ok hook (COMBO: a
/// chained follow-up)?
pub fn kit_command_ok_p(m: &mut Match, e: Entity, cmd: &str, _combo: Option<MoveId>) -> bool {
    if kit_cd_index(cmd).is_some_and(|i| fighter(m, e).cd[i] != 0) {
        return false;
    }
    kit_ok_hook(m, e, cmd)
}

/// port: REFUSED-CUE: a kit command cooling down, or one its kit's :ok hook refuses: the press eaten with a cue. Always NIL.
pub fn refused_cue(m: &mut Match, e: Entity, cmd: Cmd, button: Button) -> bool {
    if let Some(i) = kit_command_index(cmd) {
        let cd = fighter(m, e).cd[i];
        if cd > 0 {
            vpad(m, e).consume(button as usize);
            // look: emit :refused
            crate::clog!(m, "{} refused {}: cooling {}", side_name(m, e), cmd.name(), cd);
        } else if kit_hook_sym(m, e, "ok").is_some()
            && crate::kit::kit_command_move(m.data, kit_of(m, e), "q").is_some()
            && !kit_ok_hook(m, e, "q")
        {
            vpad(m, e).consume(button as usize);
            // look: emit :refused
            crate::clog!(m, "{} refused {}: kit", side_name(m, e), cmd.name());
        }
    }
    false
}

/// port: COMMAND!: the highest-priority buffered command among ALLOWED that can start now; its press consumed. No attack out of
/// a guard cancel's lockout (FIGHTER-GC-LEFT).
pub fn command(m: &mut Match, e: Entity, allowed: &[Cmd]) -> bool {
    for (cmd, button, md) in COMMANDS {
        if allowed.contains(&cmd)
            && vpad(m, e).command_pressed_p(button as usize, md)
            && !(fighter(m, e).gc_left > 0 && kit_command_index(cmd).is_some())
            && (try_command(m, e, cmd, Some(button)) || refused_cue(m, e, cmd, button))
        {
            vpad(m, e).consume(button as usize);
            return true;
        }
    }
    false
}

/// port: AWAKEN-STATE-P.
pub fn awaken_state_p(m: &Match, e: Entity) -> bool {
    let f = fighter(m, e);
    crate::rules::awaken_state_ok_p(f.state, f.lock > 0, m.cine.is_some())
}

/// port: AWAKEN-READY-P (no :core holds :no-awaken).
pub fn awaken_ready_p(m: &Match, e: Entity) -> bool {
    let g = m.gauges.get(e).expect("gauges");
    crate::rules::awaken_allowed_p(&m.knobs, awaken_state_p(m, e), g.awaken, g.awakened)
}

/// port: AWAKEN-PRESS!: Mod + P from any state that allows it, before the state's own step. T when he awakened.
pub fn awaken_press(m: &mut Match, e: Entity) -> bool {
    let (_, button, md) = COMMANDS[0]; // (assoc :awaken *commands*)
    if vpad(m, e).command_pressed_p(button as usize, md) && awaken_ready_p(m, e) {
        vpad(m, e).consume(button as usize);
        crate::clog!(m, "{} AWAKEN from {}", side_name(m, e), fighter(m, e).state);
        awaken(m, e);
        return true;
    }
    false
}

/// port: KIKON-LOCK-HOLDS-P.
pub fn kikon_lock_holds_p(m: &Match, f: &Fighter) -> bool {
    let o = f.opp;
    let Some(fo) = m.ents.alive(o).then(|| m.fighter.get(o)).flatten() else { return false };
    current_move(fo).is_some_and(|id| {
        let mv = mv(m, id);
        crate::rules::kikon_lock_p(fo.state, fo.follow, fo.phase, fo.contact, fo.sf, mv.s as i64, mv.a as i64)
    })
}

/// port: CHAIN-MORE-P: can O's move ID still go on into a follow-up (the guard lock's MORE): a next J / K link, an L link L may start,
/// the on-hit cancels, or ORANGE?
pub fn chain_more_p(m: &mut Match, o: Entity, id: MoveId) -> bool {
    let (kit, name) = (kit_of(m, o), mv(m, id).name.as_str());
    if crate::kit::string_link_p(m.data, kit, name) {
        return true;
    }
    if let Some(l) = crate::kit::kit_l_link(m.data, kit, name) {
        let l = id_of(m, l);
        if kit_command_ok_p(m, o, "sig", Some(l)) {
            return true;
        }
    }
    let f = fighter(m, o);
    (f.contact == Some(Contact::Hit) && matches!(mv(m, id).kind.as_str(), "quick" | "flash")) || burst_ok_p(m, o) == Some(Burst::Orange)
}

/// port: GUARD-LOCK-OF.
pub fn guard_lock_of(m: &mut Match, e: Entity) -> bool {
    let f = fighter(m, e);
    let (fstate, fglock, o) = (f.state, f.glock, f.opp);
    let Some(fo) = m.ents.alive(o).then(|| m.fighter.get(o)).flatten() else { return false };
    let (chain, ostate, ophase, osf) = (fo.chain, fo.state, fo.phase, fo.sf);
    let cur = current_move(fo);
    let mvd = cur.map(|id| mv(m, id));
    let (s, a, r) = mvd.map_or((0, 0, 0), |x| (x.s as i64, x.a as i64, x.r as i64));
    let touched = mvd.is_some() && (fo.contact.is_some() || fo.chained);
    let more = fstate == State::GuardHit && cur.is_some_and(|id| chain_more_p(m, o, id));
    crate::rules::guard_locked_p(fstate, fglock, chain, ostate, ophase, osf, s, a, r, touched, more)
}

// ---------------------------------------------------------------- the system

/// port: FIGHTER-STEP: one fixed step of fighter E.
pub fn fighter_step(m: &mut Match, e: Entity) {
    {
        let f = fighter_mut(m, e);
        if f.freeze > 0 {
            f.freeze -= 1;
            return;
        }
        if f.lock > 0 {
            f.lock -= 1;
        }
        if f.hoho_lock > 0 {
            f.hoho_lock -= 1;
        }
        if f.hoho_left > 0 && f.state != State::Hoho {
            f.hoho_left -= 1;
            if f.hoho_left == 0 {
                f.hoho_from = None; // the resume window closed (DUEL_CORE §8)
            }
        }
        if f.gc_left > 0 {
            f.gc_left -= 1;
        }
        if f.guard_exit > 0 {
            f.guard_exit -= 1;
        }
    }
    if fighter(m, e).kikon_lock > 0 && !kikon_lock_holds_p(m, fighter(m, e)) {
        fighter_mut(m, e).kikon_lock = 0;
    }
    {
        let f = fighter_mut(m, e);
        if f.invuln > 0 {
            f.invuln -= 1;
        }
        if f.callout_t > 0 {
            f.callout_t -= 1;
        }
        for c in f.cd.iter_mut() {
            if *c > 0 {
                *c -= 1;
            }
        }
    }
    if !awaken_press(m, e) {
        match fighter(m, e).state {
            State::Idle | State::Guard => neutral_step(m, e),
            State::Move => move_step(m, e),
            State::Stun | State::GuardHit => stun_step(m, e),
            State::Step => step_step(m, e),
            State::Run => run_step(m, e),
            State::Hoho => hoho_step(m, e),
            State::Air | State::Down | State::Wakeup => air_step(m, e),
            State::Cine | State::Intro | State::Win | State::Lose => {}
        }
    }
    let f = fighter_mut(m, e);
    if f.chain > 0 {
        f.chain -= 1;
    }
    fighter_physics(m, e);
    // look: anim-advance (docs/bevy/M1_NOTES.md §1)
}

/// port: FIGHTER-SYSTEM: the opponents' positions snapshot first (a symmetric sim), each fighter steps, then the freezes /
/// locks one put on the other, the bursts pressed this step, the guard lock, the separation.
pub fn fighter_system(m: &mut Match) {
    let (mut a, mut b) = (None, None);
    m.do_entities(|m, e| m.fighter.has(e), |m, e| {
        let o = fighter(m, e).opp;
        if m.ents.alive(o) {
            let (p, q) = (pos_of(m, e), pos_of(m, o));
            let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
            let d = libm::sqrtf(dx * dx + dz * dz); // (%sqrt: no clamp)
            let f = fighter_mut(m, e);
            (f.ox, f.oz, f.dist) = (q[0], q[2], d);
        }
        if a.is_some() {
            b = Some(e);
        } else {
            a = Some(e);
        }
    });
    if a.is_some() && b.is_some() && m.pilot.iter().any(|(_, p)| p.cam_relative) {
        crate::unported!(m, "view-step") // (VIEW-STEP: only a human's stick reads it, docs/bevy/M1_NOTES.md §2; M2)
    }
    m.do_entities(|m, e| m.fighter.has(e), |m, e| {
        if fighter(m, e).state != State::Cine {
            fighter_step(m, e);
        }
    });
    // freezes / locks one fighter put on the other take effect now that both have stepped
    m.do_entities(|m, e| m.fighter.has(e), |m, e| {
        let f = fighter_mut(m, e);
        f.freeze = f.freeze.max(f.freeze_next);
        f.lock = f.lock.max(f.lock_next);
        (f.freeze_next, f.lock_next) = (0, 0);
    });
    // a burst pressed this step applies now, unless a cinematic began
    m.do_entities(|m, e| m.fighter.has(e), |m, e| {
        if let Some(md) = fighter(m, e).burst {
            fighter_mut(m, e).burst = None;
            if m.cine.is_none() {
                burst(m, e, md);
            }
        }
    });
    // ponytail: BIND-STEP! :release — no binder: BIND-OF needs a form with a :bind hook, and none in the data has one (Hisagi, M4)
    m.do_entities(|m, e| m.fighter.has(e), |m, e| {
        let g = guard_lock_of(m, e);
        fighter_mut(m, e).glock = g;
    });
    if let (Some(a), Some(b)) = (a, b) {
        separate_fighters(m, a, b);
    }
}

/// port: TO-IDLE: back to neutral, the combo over (the stance clip is a look).
pub fn to_idle(m: &mut Match, e: Entity) {
    if let Some(f) = m.fighter.get_mut(e) {
        f.state = State::Idle;
        f.sf = 0;
        f.phase = None;
        f.mv = None;
        f.crush = false;
        f.dmg_bonus = 0;
        f.combo_hits = 0;
        f.combo_launches = 0;
        f.combo_air = 0;
        f.combo_from = 0;
        f.cls = None;
        f.presses = 0;
        f.as_done = false;
        f.charge_mult = 1.0;
        f.tmp = 0;
        f.csa = None;
    }
    halt(m, e);
    // look: play-clip of the stance
}

#[cfg(test)]
mod tests {
    use super::*;

    /// COMMANDS is control.lisp's `*commands*` (tables.json), and Button's order is `*vpad-actions*`'.
    #[test]
    fn commands_match_the_data() {
        let d = crate::hashline::tests::new_match().data;
        let acts: Vec<&str> = d.tables["vpad_actions"].as_array().unwrap().iter().map(|a| a.as_str().unwrap()).collect();
        assert_eq!(acts, Button::ALL.iter().map(|b| b.name().to_lowercase()).collect::<Vec<_>>());
        let rows = d.tables["commands"].as_array().unwrap();
        assert_eq!(rows.len(), COMMANDS.len());
        for (row, (c, b, md)) in rows.iter().zip(COMMANDS) {
            let r = row.as_array().unwrap();
            assert_eq!(r[0].as_str().unwrap().to_uppercase(), c.name());
            assert_eq!(r[1].as_str().unwrap().to_uppercase(), b.name());
            assert_eq!(r[2].as_bool().unwrap_or(false), md == Mod::Yes);
        }
    }
}
