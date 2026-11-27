//! The keyboard as the pilots' device (M3a Task 10): duel/lisp/control.lisp's default bindings (`*p1-default-bindings*`,
//! `*p2-default-bindings*`: their `:key` inputs) read by engine/lisp/input.lisp VPAD-READ!, and HASH-LOG's console line at the step's end.
//! The pad and touch inputs of the same bindings, and CONTROLS' rebinding, are M3b's.
//!
//! The page copies Bevy's key state in once per update (`set`); the sim reads it from inside its steps (PILOT-SYSTEM's reader), so
//! every step of one update sees the same keys, as every step of one frame does in the Lisp (SDL's state is pumped once a frame).
//! A rollout reads them again (`rollout_read`): the human's keys are still down while the CPU searches (DIVERGENCES §1's leak, kept).
use duel_sim::cpu::Search;
use duel_sim::flow::PilotInput;
use duel_sim::state::{Match, Mode};
use duel_sim::vpad::Vpad;

/// The keys the page reads, as bits of `Keyboard.held` / `pressed` (the engine's key keywords in the comments).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u8)]
pub enum Key {
    /// :w :s :a :d
    W,
    S,
    A,
    D,
    /// :j (P1 quick; also CONFIRM-P)
    J,
    /// :space
    Space,
    /// :lshift
    LShift,
    /// :p
    P,
    /// :up :down :left :right
    Up,
    Down,
    Left,
    Right,
    /// :kp-1 (P2 quick; also CONFIRM-P) :kp-0 :kp-enter (P2 mod; also CONFIRM-P) :kp-plus
    Kp1,
    Kp0,
    KpEnter,
    KpPlus,
    /// :return (CONFIRM-P), :escape (PAUSE-P)
    Return,
    Escape,
}

impl Key {
    pub const fn bit(self) -> u32 {
        1 << self as u8
    }
}

/// A side's bindings: per vpad action (`*vpad-actions*`) its key, and the stick's (up down left right).
struct Bindings {
    actions: [(&'static str, Key); 4],
    dirs: [Key; 4],
}

/// port: duel/lisp/control.lisp `*p1-default-bindings*` / `*p2-default-bindings*`, their `:key` inputs (:flash :sig :guard :breaker
/// :kikon are bound to nothing).
const BINDINGS: [Bindings; 2] = [
    Bindings { actions: [("quick", Key::J), ("step", Key::Space), ("mod", Key::LShift), ("awaken", Key::P)], dirs: [Key::W, Key::S, Key::A, Key::D] },
    Bindings { actions: [("quick", Key::Kp1), ("step", Key::Kp0), ("mod", Key::KpEnter), ("awaken", Key::KpPlus)], dirs: [Key::Up, Key::Down, Key::Left, Key::Right] },
];

/// flow.lisp CONFIRM-P's keys (:return :j :kp-1 :kp-enter) and PAUSE-P's (:escape).
pub const CONFIRM: u32 = Key::Return.bit() | Key::J.bit() | Key::Kp1.bit() | Key::KpEnter.bit();
pub const PAUSE: u32 = Key::Escape.bit();

#[derive(Default)]
pub struct Keyboard {
    /// The keys down now (KEY-DOWN), one bit per `Key`.
    pub held: u32,
    /// The keys that went down since the screens last read them (KEY-PRESSED), taken by `take_pressed`.
    pub pressed: u32,
    /// HASH-LOG's 600-tick state hash line into `Match.log` (the page's `?log`: the line allocates).
    pub hash_log: bool,
}

impl Keyboard {
    /// The page's key state this update: HELD down now, PRESSED gone down since the last update (both `Key` bits).
    pub fn set(&mut self, held: u32, pressed: u32) {
        self.held = held;
        self.pressed |= pressed;
    }

    /// The presses since the last call (the screens read them once a frame; the frames after it in one update see none).
    pub fn take_pressed(&mut self) -> u32 {
        std::mem::take(&mut self.pressed)
    }

    fn down(&self, k: Key) -> bool {
        self.held & k.bit() != 0
    }

    /// port: VPAD-READ! of SIDE's bindings on VP: every action in the vpad's order (`:mod` first, so a press with the modifier in the
    /// same step is modified), then the stick from the direction keys (VPAD-STICK!: clamped; no analog stick, so AX AY are 0).
    pub fn read_vpad(&self, vp: &mut Vpad, side: usize) {
        let b = &BINDINGS[side];
        for i in 0..vp.actions.len() {
            let a = vp.actions[i].as_str();
            let down = b.actions.iter().any(|&(name, k)| name == a && self.down(k));
            vp.set(i, down);
        }
        let dir = |plus: Key, minus: Key| (if self.down(plus) { 1.0f32 } else { 0.0 }) - (if self.down(minus) { 1.0 } else { 0.0 });
        let [up, dn, l, r] = b.dirs;
        vp.stick(0.0 + dir(r, l), 0.0 + dir(up, dn));
    }
}

/// Is SIDE a human (a vpad with a reader)? port: START-MATCH's SPAWN-PAIR `:cpu1 (eq *mode* :cpu-cpu) :cpu2 (not (eq *mode*
/// :vs-player))`; the reader is P1-READER / P2-READER only for a human. (Not the fighter's brain: the stepping CPU's brain is out of
/// its fighter while it thinks, and its own VPAD-BEGIN-STEP! calls `read` with no reader in the Lisp.)
fn human(m: &Match, side: usize) -> bool {
    if side == 0 { m.mode != Mode::CpuCpu } else { m.mode == Mode::VsPlayer }
}

impl PilotInput for Keyboard {
    fn read(&mut self, m: &mut Match, side: usize) {
        if !human(m, side) {
            return;
        }
        let e = if side == 0 { m.p1 } else { m.p2 };
        if let Some(p) = m.pilot.get_mut(e) {
            self.read_vpad(&mut p.vpad, side);
        }
    }

    /// port: HASH-LOG's state hash line (gate.lisp: every 600 battle ticks, a LOG-MSG), when the page asks for it.
    fn step_end(&mut self, m: &mut Match, _s: &mut Search) {
        if self.hash_log && m.flow == duel_sim::components::Flow::Battle && m.match_tick > 0 && m.match_tick % 600 == 0 {
            let l = duel_sim::hashline::state_hash_line(m);
            m.log.push(l);
        }
    }

    /// A rollout's read: the same keys again (the Lisp reader reads the same SDL state inside the frame), never a new press of its own.
    fn rollout_read(&mut self, m: &mut Match, side: usize) {
        self.read(m, side);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn vpad_read_as_the_lisp() {
        let d = duel_data::Data::embedded();
        let m = Match::new(Box::leak(Box::new(d)));
        let mut vp = Vpad::duel(m.data, &m.knobs).unwrap();
        let kb = Keyboard { held: Key::J.bit() | Key::LShift.bit() | Key::D.bit() | Key::W.bit(), ..Default::default() };
        vp.begin_step();
        kb.read_vpad(&mut vp, 0);
        let (q, md) = (vp.index("quick").unwrap(), vp.index("mod").unwrap());
        assert!(vp.down(q) && vp.down(md) && vp.modded_p(q), "J with Shift in the same step is modified (:mod read first)");
        assert_eq!((vp.sx, vp.sy), (std::f32::consts::FRAC_1_SQRT_2, std::f32::consts::FRAC_1_SQRT_2));
        // P2's keys move nothing on P1's vpad
        let kb2 = Keyboard { held: Key::Kp1.bit() | Key::Left.bit(), ..Default::default() };
        vp.begin_step();
        kb2.read_vpad(&mut vp, 0);
        assert!(!vp.down(q) && (vp.sx, vp.sy) == (0.0, 0.0));
        vp.begin_step();
        kb2.read_vpad(&mut vp, 1);
        assert!(vp.down(q) && (vp.sx, vp.sy) == (-1.0, 0.0));
    }
}
