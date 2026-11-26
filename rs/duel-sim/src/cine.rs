//! port: engine/lisp/cine.lisp (the director) and duel/lisp/cinema.lisp (its hooks, the staging helpers, the generic
//! cinematics' step-mode AT events). Shots, clips, captions, lenses, impact frames and sounds are looks (M3): only what
//! touches sim state is here. A kit's script is `unported!` until Tasks 11-12.
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
}

impl CineName {
    pub fn len(self) -> i64 {
        match self {
            CineName::Intro => 300,
            CineName::Ko => 150,
            CineName::SoulBreak => 96,
            CineName::Time => 120,
        }
    }
    /// The Lisp symbol (CINE-BEGIN's log line).
    pub fn lisp(self) -> &'static str {
        match self {
            CineName::Intro => "INTRO-CINE",
            CineName::Ko => "KO-CINE",
            CineName::SoulBreak => "SOUL-BREAK-CINE",
            CineName::Time => "TIME-CINE",
        }
    }
}

/// START-CINE's :after continuations the sim uses (no closures in `Match`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum After {
    BeginBattle,
    GoResults,
}

/// The running cinematic (`*cine*`, CINE): HOLD is the debug freeze (`*cine-hold*`, never set by the ported commands).
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
}

/// port: START-CINE.
pub fn start_cine(m: &mut Match, name: CineName, a: Entity, v: Entity, after: Option<After>) {
    m.time.reset();
    // look: *grade-split*, *cine-cam*
    m.cine = Some(Cine { name, cf: 0, len: name.len(), a, v, after, skip: false });
    m.cine_serial += 1;
    cine_begin(m, name, a, v);
    if m.skip_cines {
        end_cine(m);
    } else {
        script(name, 0, a, v, m);
    }
}

/// port: END-CINE.
pub fn end_cine(m: &mut Match) {
    let c = m.cine.take();
    // look: *cine-cam*, the grade
    cine_end(m, c.as_ref());
    if let Some(after) = c.and_then(|c| c.after) {
        run_after(m, after);
    }
}

fn run_after(m: &mut Match, after: After) {
    match after {
        After::BeginBattle => crate::flow::begin_battle(m),
        After::GoResults => crate::flow::go_results(m),
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

/// port: CINE-STEP (the hold frame is the debug freeze: never set here).
pub fn cine_step(m: &mut Match) {
    let Some(c) = m.cine.as_mut() else { return };
    if c.skip {
        end_cine(m);
        return;
    }
    c.cf += 1;
    let (name, cf, a, v, len, serial) = (c.name, c.cf, c.a, c.v, c.len, m.cine_serial);
    script(name, cf, a, v, m);
    if m.cine.is_some() && m.cine_serial == serial {
        // look: *cine-actor-hook* (CINE-ACTOR-STEP: the actors' clips advance)
        if cf >= len {
            end_cine(m);
        }
    }
}

/// The step-mode AT events of script NAME at frame CF that touch sim state.
pub fn script(name: CineName, cf: i64, a: Entity, v: Entity, m: &mut Match) {
    match name {
        // look: clips, shots, captions, intro weapons, the negative cut, FIGHT!'s sound
        CineName::Intro => {
            if cf == 0 {
                face_each_other(m, a, v, None);
            }
        }
        // look: clips, hold-pose, the two-tone frame, shots, the stamp, the rain
        CineName::Ko => {
            if cf == 0 {
                face_each_other(m, a, v, None);
            }
        }
        // look: clips, hold-both, impact frames, shots, the stamp, silence, cine-shatter (vfx), shake
        CineName::SoulBreak => {
            if cf == 0 {
                face_each_other(m, a, v, None);
            }
        }
        // look: the caption, the negative frame, the shot
        CineName::Time => {}
    }
}

/// port: CINE-BEGIN (*cine-begin-hook*).
fn cine_begin(m: &mut Match, name: CineName, a: Entity, v: Entity) {
    // look: caption, lens, close-up flags
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
    // look: caption, card, grade, dutch, fov, aura, draw scale, time scale, camera up, silhouette, flash, screen fx, stage env
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
                // look: refresh-look
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
    // look: *cam-cut*
}

/// port: CINE-PLACE.
pub fn cine_place(m: &mut Match, a: Entity, v: Entity, gap: f32) {
    cine_save(m, a, v);
    face_each_other(m, a, v, Some(gap));
}
