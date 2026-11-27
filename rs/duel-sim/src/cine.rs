//! port: engine/lisp/cine.lisp (the director) and duel/lisp/cinema.lisp (its hooks, the staging helpers, the generic
//! cinematics' step-mode AT events). Shots, clips, captions, lenses, impact frames and sounds are looks (M3): only what
//! touches sim state is here. Kenpachi's scripts are in ken/cine.rs, Ichigo's in ichigo/cine.rs.
use crate::look::{CineLook, LookEvent};
use crate::components::State;
use crate::ecs::Entity;
use crate::math::{dir_yaw, hypot};
use crate::state::Match;

/// A cinematic script (DEFCINE name) and its length (`:len`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CineName {
    Intro,
    Ko,
    SoulBreak,
    Time,
    Ken(crate::ken::cine::KenCine),
    Ichigo(crate::ichigo::cine::IcCine),
}

impl CineName {
    pub fn frames(self) -> i64 {
        match self {
            CineName::Intro => 300,
            CineName::Ko => 150,
            CineName::SoulBreak => 96,
            CineName::Time => 120,
            CineName::Ken(c) => c.frames(),
            CineName::Ichigo(c) => c.frames(),
        }
    }
    /// `:hold` (CINE-HOLD-FRAME: the debug freeze START-CINE takes while `*cine-hold*`).
    pub fn hold_frame(self) -> i64 {
        match self {
            CineName::Intro => 200,
            CineName::Ko => 40,
            CineName::SoulBreak => 44,
            CineName::Time => 60,
            CineName::Ken(c) => c.hold_frame(),
            CineName::Ichigo(c) => c.hold_frame(),
        }
    }
    /// The Lisp symbol (CINE-BEGIN's log line).
    pub fn lisp(self) -> &'static str {
        match self {
            CineName::Intro => "INTRO-CINE",
            CineName::Ko => "KO-CINE",
            CineName::SoulBreak => "SOUL-BREAK-CINE",
            CineName::Time => "TIME-CINE",
            CineName::Ken(c) => c.lisp(),
            CineName::Ichigo(c) => c.lisp(),
        }
    }
    /// The cinematic of symbol S, if ported (the generic Soul Break's, a kit's).
    pub fn from_lisp(s: &str) -> Option<CineName> {
        match s {
            "SOUL-BREAK-CINE" => Some(CineName::SoulBreak),
            _ => crate::ken::cine::KenCine::from_lisp(s)
                .map(CineName::Ken)
                .or_else(|| crate::ichigo::cine::IcCine::from_lisp(s).map(CineName::Ichigo)),
        }
    }
}

/// START-CINE's :after continuations the sim uses (no closures in `Match`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum After {
    BeginBattle,
    GoResults,
    /// SETTLE-SOULS' with no K.O.: RESET-ROUND of A V.
    ResetRound(Entity, Entity),
    /// SETTLE-SOULS' K.O.: MATCH-OVER of the winner (None: a draw).
    MatchOver(Option<Entity>),
    /// AWAKEN! / BANKAI!'s: both fighters idle.
    IdleBoth(Entity, Entity),
}

/// The running cinematic (`*cine*`, CINE): HOLD is the debug freeze (CINE-HOLD: the still commands set it, `Match.cine_hold`).
#[derive(Clone, Debug, PartialEq)]
pub struct Cine {
    pub name: CineName,
    /// The cinematic's frame (CINE-CF; the B line's `cine-cf`).
    pub cf: i64,
    pub len: i64,
    pub a: Entity,
    pub v: Entity,
    pub after: Option<After>,
    pub skip: bool,
    /// The frame it stops at (a debug still: FORCE-CINE / CINE-AT), or None.
    pub hold: Option<i64>,
    /// A kit cinematic's scratch line (ken-look.lisp `*ke-kk*`: KE-KK-LINE's victim x z and unit toward the attacker), set by the
    /// script at its frame 0 and read only inside the same cinematic: zeroed by START-CINE (the Lisp global is never read stale).
    pub line: [f32; 4],
}

/// port: START-CINE. Frame 0's look forms are queued after its sim forms (`LookEvent::CineAt`): no sink is reachable here.
pub fn start_cine(m: &mut Match, name: CineName, a: Entity, v: Entity, after: Option<After>) {
    m.time.reset();
    m.look(LookEvent::CineStart { name, a, v }); // look: (setf *grade-split* 0.0 … *cine-cam* nil)
    let hold = m.cine_hold.then(|| name.hold_frame());
    m.cine = Some(Cine { name, cf: 0, len: name.frames(), a, v, after, skip: false, hold, line: [0.0; 4] });
    m.cine_serial += 1;
    cine_begin(m, name, a, v);
    if m.skip_cines && !m.cine_hold {
        end_cine(m);
    } else {
        script(name, 0, a, v, m);
        m.look(LookEvent::CineAt { name, cf: 0, a, v }); // look: the script's look forms at frame 0
    }
}

/// port: END-CINE.
pub fn end_cine(m: &mut Match) {
    let c = m.cine.take();
    m.look(LookEvent::CineStop); // look: (setf *cine-cam* nil *grade-desat* 0.0 *grade-split* 0.0)
    cine_end(m, c.as_ref());
    if let Some(after) = c.and_then(|c| c.after) {
        run_after(m, after);
    }
}

fn run_after(m: &mut Match, after: After) {
    match after {
        After::BeginBattle => crate::flow::begin_battle(m),
        After::GoResults => crate::flow::go_results(m),
        After::ResetRound(a, v) => crate::round::reset_round(m, a, v),
        After::MatchOver(w) => crate::flow::match_over(m, w),
        After::IdleBoth(e, o) => {
            crate::fighter::to_idle(m, e, 0.0);
            crate::fighter::to_idle(m, o, 0.0);
        }
    }
}

/// port: ABORT-CINE.
pub fn abort_cine(m: &mut Match) {
    if let Some(c) = m.cine.as_mut() {
        c.after = None;
        end_cine(m);
    }
}

/// port: SKIP-CINE.
pub fn skip_cine(m: &mut Match) {
    if let Some(c) = m.cine.as_mut() {
        c.skip = true;
    }
}

/// port: CINE-STEP: a held cinematic (at or past its debug HOLD frame) stands still: no frame, no script, no actor step, no end. The
/// script's look forms run through LOOK right after its sim forms (ruling R9).
pub fn cine_step(m: &mut Match, look: &mut dyn CineLook) {
    let Some(c) = m.cine.as_mut() else { return };
    if c.skip {
        end_cine(m);
        return;
    }
    if c.hold.is_some_and(|h| c.cf >= h) {
        return;
    }
    c.cf += 1;
    let (name, cf, a, v, len, serial) = (c.name, c.cf, c.a, c.v, c.len, m.cine_serial);
    script(name, cf, a, v, m);
    look.forms(m, name, cf, a, v, true);
    if m.cine.is_some() && m.cine_serial == serial {
        for e in [a, v] {
            if m.ents.alive(e) {
                m.look(LookEvent::CineActorStep { e }); // look: *cine-actor-hook* (CINE-ACTOR-STEP: the actor's clip advances)
            }
        }
        if cf >= len {
            end_cine(m);
        }
    }
}

/// The step-mode AT events of script NAME at frame CF that touch sim state (its look forms: `CineLook::forms`, after these).
pub fn script(name: CineName, cf: i64, a: Entity, v: Entity, m: &mut Match) {
    match name {
        // look: clips, shots, captions, intro weapons, the negative cut, FIGHT!'s sound (`CineLook::forms`)
        CineName::Intro => {
            if cf == 0 {
                face_each_other(m, a, v, None);
            }
        }
        // look: clips, hold-pose, the two-tone frame, shots, the stamp, the rain (`CineLook::forms`)
        CineName::Ko => {
            if cf == 0 {
                face_each_other(m, a, v, None);
            }
        }
        // look: clips, hold-both, impact frames, shots, the stamp, silence, cine-shatter (vfx), shake (`CineLook::forms`)
        CineName::SoulBreak => {
            if cf == 0 {
                face_each_other(m, a, v, None);
            }
        }
        // look: the caption, the negative frame, the shot (`CineLook::forms`)
        CineName::Time => {}
        CineName::Ken(c) => crate::ken::cine::script(c, cf, a, v, m),
        CineName::Ichigo(c) => crate::ichigo::cine::script(c, cf, a, v, m),
    }
}

/// port: CINE-DRAW — per rendered frame (DRAW-SCENE, after the frame's steps; never in turbo): the running script's draw mode, its
/// DURING forms at the cine frame now: those writing sim state here (Kenpachi's: `ken::cine::draw`), then the looks through LOOK.
pub fn cine_draw(m: &mut Match, look: &mut dyn CineLook) {
    let Some(c) = m.cine.as_ref() else { return };
    let (name, cf, a, v) = (c.name, c.cf, c.a, c.v);
    if let CineName::Ken(k) = name {
        crate::ken::cine::draw(k, cf, a, v, m);
    }
    look.forms(m, name, cf, a, v, false);
}

/// port: CINE-BEGIN (*cine-begin-hook*).
fn cine_begin(m: &mut Match, name: CineName, a: Entity, v: Entity) {
    m.look(LookEvent::CineBegin { name, a, v }); // look: caption, lens, close-up flags
    for e in [a, v] {
        if let Some(f) = m.fighter.get_mut(e) {
            f.state = State::Cine;
            f.sf = 0;
            if let Some(mo) = m.motion.get_mut(e) {
                mo.kb_left = 0;
            }
            crate::fighter::halt(m, e);
        }
    }
    crate::clog!(m, "cine {}", name.lisp());
}

/// port: CINE-END (*cine-end-hook*): C is None when none ran.
fn cine_end(m: &mut Match, c: Option<&Cine>) {
    m.look(LookEvent::CineEndLook); // look: caption, card, grade, dutch, fov, aura, draw scale, time scale, camera up, silhouette, flash, screen fx, stage env
    if let Some((a, v)) = m.cine_placed_e
        && m.cine_placed[6] > 0.0
    {
        let s = m.cine_placed;
        for (e, i) in [(a, 0), (v, 3)] {
            if let Some(t) = m.transform.get_mut(e) {
                t.pos = [s[i], s[i + 1], s[i + 2]];
            }
        }
        m.cine_placed[6] = 0.0;
    }
    m.cine_placed_e = None;
    if let Some(c) = c {
        for e in [c.a, c.v] {
            if m.fighter.has(e) {
                let kit = crate::look::KitRef(crate::fighter::kit_of(m, e));
                m.look(LookEvent::RefreshLook { e, kit }); // look: refresh-look
                if let Some(p) = m.pilot.get_mut(e) {
                    p.vpad.flush();
                }
            }
        }
    }
}

fn pos(m: &Match, e: Entity) -> [f32; 3] {
    m.transform.get(e).map_or([0.0; 3], |t| t.pos)
}

/// port: FACE-EACH-OTHER: A and V turned to face each other; with GAP, A first put GAP metres in front of V.
pub fn face_each_other(m: &mut Match, a: Entity, v: Entity, gap: Option<f32>) {
    let (mut p, q) = (pos(m, a), pos(m, v));
    if let Some(gap) = gap {
        let (dx, dz) = (p[0] - q[0], p[2] - q[2]);
        let d = f32::max(0.01, hypot(dx, dz));
        p = [q[0] + gap * (dx / d), 0.0, q[2] + gap * (dz / d)];
        m.transform.get_mut(a).unwrap().pos = p;
    }
    m.transform.get_mut(a).unwrap().yaw = dir_yaw(q[0] - p[0], q[2] - p[2]);
    let tv = m.transform.get_mut(v).unwrap();
    tv.yaw = dir_yaw(p[0] - q[0], p[2] - q[2]);
    tv.pos[1] = 0.0;
}

/// port: CINE-SAVE: the first save of a cinematic holds.
pub fn cine_save(m: &mut Match, a: Entity, v: Entity) {
    if m.cine_placed[6] > 0.0 {
        return;
    }
    for (e, i) in [(a, 0), (v, 3)] {
        let p = pos(m, e);
        m.cine_placed[i..i + 3].copy_from_slice(&p);
    }
    m.cine_placed[6] = 1.0;
    m.cine_placed_e = Some((a, v));
}

/// port: CINE-STAGE: both set down about the arena's centre on their line, facing.
pub fn cine_stage(m: &mut Match, a: Entity, v: Entity) {
    cine_save(m, a, v);
    let (p, q) = (pos(m, a), pos(m, v));
    // (* 0.5 (+ …)) of singles: single
    let (mx, mz) = (0.5 * (p[0] + q[0]), 0.5 * (p[2] + q[2]));
    m.transform.get_mut(a).unwrap().pos = [p[0] - mx, 0.0, p[2] - mz];
    m.transform.get_mut(v).unwrap().pos = [q[0] - mx, 0.0, q[2] - mz];
    face_each_other(m, a, v, None);
    m.look(LookEvent::CamCut); // look: (setf *cam-cut* t)
}

/// port: CINE-PLACE.
pub fn cine_place(m: &mut Match, a: Entity, v: Entity, gap: f32) {
    cine_save(m, a, v);
    face_each_other(m, a, v, Some(gap));
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::components::{Character, Flow};

    /// A fresh KI match at its intro's frame 0 (the AFTER: BEGIN-BATTLE, so it shows as flow BATTLE).
    fn intro() -> Match {
        let mut m = crate::hashline::tests::new_match();
        crate::flow::go_title(&mut m);
        m.picks = [Character::Kenpachi, Character::Ichigo];
        m.mode = crate::state::Mode::CpuCpu;
        crate::flow::start_match(&mut m, &mut crate::cpu::Search::new());
        m
    }

    /// tests/cine-test.lisp's director checks on the INTRO script (lines 37, 40, 45, 48, 49, 65, 67, 71, 74).
    #[test]
    fn cine_test_lisp() {
        let mut m = intro();
        assert_eq!(m.cine.as_ref().map(|c| c.cf), Some(0)); // frame 0 ran at the start
        assert!([m.p1, m.p2].iter().all(|&e| m.fighter.get(e).unwrap().state == State::Cine)); // the begin hook
        let mut cfs = Vec::new();
        while let Some(c) = m.cine.as_ref() {
            cfs.push(c.cf);
            cine_step(&mut m, &mut crate::look::NoLook);
        }
        assert_eq!((cfs.len(), cfs.last()), (300, Some(&299))); // one step per frame, the end after frame LEN
        assert_eq!(m.flow, Flow::Battle); // the end hook, then AFTER

        let mut m = intro();
        skip_cine(&mut m);
        assert!(m.cine.is_some()); // still running until the next fixed step
        cine_step(&mut m, &mut crate::look::NoLook);
        assert_eq!((m.cine.is_none(), m.flow), (true, Flow::Battle));

        let mut m = intro();
        abort_cine(&mut m);
        assert_eq!((m.cine.is_none(), m.flow), (true, Flow::Intro)); // AFTER dropped

        let mut m = crate::hashline::tests::new_match();
        crate::flow::go_title(&mut m);
        m.skip_cines = true;
        m.mode = crate::state::Mode::CpuCpu;
        crate::flow::start_match(&mut m, &mut crate::cpu::Search::new());
        assert_eq!((m.cine.is_none(), m.flow), (true, Flow::Battle)); // *skip-cines*: ended at once, AFTER ran
    }

    /// Debug 2209 (debug.lisp's own range, narrower than FORCE-CINE's 2200-2299): a K.O., P1 the winner, KO-CINE played (not held),
    /// not FORCE-CINE's k 9 (KEN-BANKAI-CINE).
    #[test]
    fn debug_2209_plays_the_ko() {
        let mut m = crate::hashline::tests::new_match();
        crate::flow::go_title(&mut m);
        crate::debug::debug_command(&mut m, &mut crate::cpu::Search::new(), 2209);
        let c = m.cine.as_ref().expect("a cinematic");
        assert_eq!((c.name, c.hold, c.a, m.flow, m.unported), (CineName::Ko, None, m.p1, Flow::Finish, None));
    }

    /// tests/cine-test.lisp's checks deferred from M1 (the debug hold and the actor hook), on the INTRO script: 76 (CINE-HOLD-FRAME is
    /// the script's `:hold`), 56 (with `*cine-hold*` it stops at that frame), 59 (released, it runs to its end), 47 (the actor hook: two
    /// actor steps a cinematic step, none while held). (43 / 44 DURING, 50 the shot's eye: duel-look `cine::tests`.)
    #[test]
    fn cine_test_lisp_hold() {
        let mut m = crate::hashline::tests::new_match();
        crate::flow::go_title(&mut m);
        (m.picks, m.mode, m.cine_hold) = ([Character::Kenpachi, Character::Ichigo], crate::state::Mode::CpuCpu, true);
        crate::flow::start_match(&mut m, &mut crate::cpu::Search::new());
        assert_eq!(m.cine.as_ref().and_then(|c| c.hold), Some(200)); // 76: (cine-hold-frame 'intro-cine), started under *cine-hold*
        m.looks.clear();
        let actor = |m: &Match| m.looks.v.iter().filter(|e| matches!(e, LookEvent::CineActorStep { .. })).count();
        for _ in 0..260 {
            cine_step(&mut m, &mut crate::look::NoLook);
        }
        assert_eq!((m.cine.as_ref().map(|c| c.cf), actor(&m)), (Some(200), 400)); // 56: stopped at its hold frame; 47
        (m.cine.as_mut().unwrap().hold, m.cine_hold) = (None, false);
        while m.cine.is_some() {
            cine_step(&mut m, &mut crate::look::NoLook);
        }
        assert_eq!((m.flow, actor(&m)), (Flow::Battle, 2 * 300)); // 59: it ran on to its end; 47: 2 actors x 300 steps
    }
}
