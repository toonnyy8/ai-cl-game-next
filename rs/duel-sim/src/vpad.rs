//! The virtual controller: port of engine/lisp/input.lisp (make-vpad … vpad-command). Buttons are indexes into `actions`
//! (`index` finds one by name once; the Lisp EQ loop per call is not kept). Per button: `downs` 1 / 0, `since` the tick the
//! hold began, `press` the tick of the last unconsumed press (`NO_PRESS` = none), `modded` 1 = pressed with the modifier.
//! Devices (vpad-read!, bindings) are the app's (M2+); a reader here is the caller writing `set` after `begin_step`.
use crate::consts::NO_PRESS;
use crate::knobs::Knobs;
use duel_data::Data;

#[derive(Debug, Clone, PartialEq)]
pub struct Vpad {
    pub actions: Vec<String>,
    /// The modifier button (`mod-index`, -1 → None).
    pub mod_index: Option<usize>,
    /// Steps a press stays buffered.
    pub buffer: i64,
    pub tick: i64,
    pub downs: Vec<i64>,
    pub since: Vec<i64>,
    pub press: Vec<i64>,
    pub modded: Vec<i64>,
    pub sx: f32,
    pub sy: f32,
}

/// A command-table entry's MOD: T (modified), NIL (unmodified), :ANY.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mod {
    Yes,
    No,
    Any,
}

impl Vpad {
    /// port: make-vpad. `modifier` must be one of `actions`.
    pub fn new(actions: &[&str], modifier: Option<&str>, buffer: i64) -> Result<Vpad, String> {
        let n = actions.len();
        let mod_index = match modifier {
            Some(m) => Some(actions.iter().position(|a| *a == m).ok_or_else(|| format!("modifier {m} is not an action"))?),
            None => None,
        };
        Ok(Vpad {
            actions: actions.iter().map(|a| a.to_string()).collect(),
            mod_index,
            buffer,
            tick: 0,
            downs: vec![0; n],
            since: vec![0; n],
            press: vec![NO_PRESS; n],
            modded: vec![0; n],
            sx: 0.0,
            sy: 0.0,
        })
    }

    /// port: duel/lisp/control.lisp NEW-VPAD: `*vpad-actions*` (tables.vpad_actions), modifier :mod, `*input-buffer*`.
    pub fn duel(d: &Data, k: &Knobs) -> Result<Vpad, String> {
        let acts = d.tables.get("vpad_actions").and_then(|v| v.as_array()).ok_or("tables: vpad_actions missing")?;
        let acts = acts.iter().map(|a| a.as_str().ok_or("tables: vpad_actions holds a non-name")).collect::<Result<Vec<_>, _>>()?;
        Vpad::new(&acts, Some("mod"), k.input_buffer)
    }

    /// port: vpad-index (an unknown action is an error).
    pub fn index(&self, action: &str) -> Result<usize, String> {
        self.actions.iter().position(|a| a == action).ok_or_else(|| format!("unknown vpad action {action}"))
    }

    /// port: vpad-begin-step! (the device reader is the caller's).
    pub fn begin_step(&mut self) {
        self.tick += 1;
    }

    /// port: vpad-set!. Going down stamps a press and records whether the modifier is down (or goes down this step).
    pub fn set(&mut self, i: usize, down: bool) {
        if down && self.downs[i] == 0 {
            self.downs[i] = 1;
            self.since[i] = self.tick;
            self.press[i] = self.tick;
            self.modded[i] = self.mod_index.map_or(0, |m| self.downs[m]); // (after downs[i]: the SETF is sequential)
            if self.mod_index == Some(i) {
                for j in 0..self.downs.len() {
                    if self.press[j] == self.tick {
                        self.modded[j] = 1;
                    }
                }
            }
        } else if !down && self.downs[i] == 1 {
            self.downs[i] = 0;
        }
    }

    /// port: vpad-stick! (clamped to unit length).
    pub fn stick(&mut self, x: f32, y: f32) {
        let m2 = x * x + y * y;
        if m2 > 1.0 {
            let m = libm::sqrtf(m2);
            self.sx = x / m;
            self.sy = y / m;
        } else {
            self.sx = x;
            self.sy = y;
        }
    }

    /// port: vpad-clear! (since and tick are kept).
    pub fn clear(&mut self) {
        self.downs.fill(0);
        self.press.fill(NO_PRESS);
        self.modded.fill(0);
        self.sx = 0.0;
        self.sy = 0.0;
    }

    /// port: vpad-flush! (holds are kept).
    pub fn flush(&mut self) {
        self.press.fill(NO_PRESS);
    }

    /// port: vpad-down.
    pub fn down(&self, i: usize) -> bool {
        self.downs[i] == 1
    }

    /// port: vpad-held: steps held (1 on the step it went down), 0 if up.
    pub fn held_for(&self, i: usize) -> i64 {
        if self.downs[i] == 1 { 1 + (self.tick - self.since[i]) } else { 0 }
    }

    /// port: vpad-pressed: pressed within the last `within` steps (None: the buffer; this step included) and not consumed.
    pub fn pressed(&self, i: usize, within: Option<i64>) -> bool {
        self.tick - self.press[i] < within.unwrap_or(self.buffer)
    }

    /// port: vpad-modded-p.
    pub fn modded_p(&self, i: usize) -> bool {
        self.modded[i] == 1
    }

    /// port: vpad-stamp! (a press made for the player, held or not).
    pub fn stamp(&mut self, i: usize, modded: bool) {
        self.downs[i] = 1;
        self.press[i] = self.tick;
        self.modded[i] = modded as i64;
    }

    /// port: vpad-hold! (down without a new press).
    pub fn hold(&mut self, i: usize) {
        self.downs[i] = 1;
    }

    /// port: vpad-consume! (modded is kept).
    pub fn consume(&mut self, i: usize) {
        self.press[i] = NO_PRESS;
    }

    /// port: vpad-command-pressed-p.
    pub fn command_pressed_p(&self, button: usize, m: Mod) -> bool {
        self.pressed(button, None)
            && match m {
                Mod::Any => true,
                Mod::Yes => self.modded_p(button),
                Mod::No => !self.modded_p(button),
            }
    }

    /// port: vpad-command: the first buffered entry of `commands` (highest priority first) among `allowed` (empty = all, as
    /// NIL); the button is the one to consume.
    pub fn command<'a, C: PartialEq>(&self, commands: &'a [(C, usize, Mod)], allowed: &[C]) -> Option<(&'a C, usize)> {
        commands
            .iter()
            .find(|(c, b, m)| (allowed.is_empty() || allowed.contains(c)) && self.command_pressed_p(*b, *m))
            .map(|(c, b, _)| (c, *b))
    }
}

/// tests/input-test.lisp, the same checks and values (26 of its 33: the device-read section's 7 are the app's, M2).
#[cfg(test)]
mod tests {
    use super::*;

    const SHIFT: usize = 0;
    const ATTACK: usize = 1;
    const JUMP: usize = 2;
    const GUARD: usize = 3;

    fn pad(buffer: i64) -> Vpad {
        Vpad::new(&["shift", "attack", "jump", "guard"], Some("shift"), buffer).unwrap()
    }
    fn steps(vp: &mut Vpad, n: usize) {
        for _ in 0..n {
            vp.begin_step();
        }
    }
    fn table() -> Vec<(&'static str, usize, Mod)> {
        vec![("super", ATTACK, Mod::Yes), ("jump", JUMP, Mod::Any), ("attack", ATTACK, Mod::No)]
    }
    fn pressed(actions: &[usize]) -> Vpad {
        let mut vp = pad(10);
        vp.begin_step();
        for &a in actions {
            vp.set(a, true);
        }
        vp
    }

    #[test]
    fn buffer_within_consume() {
        let mut vp = pad(5);
        vp.begin_step();
        vp.set(ATTACK, true);
        vp.set(ATTACK, false);
        assert!(vp.pressed(ATTACK, None));
        steps(&mut vp, 4);
        assert!(vp.pressed(ATTACK, None)); // 5th step: still buffered
        steps(&mut vp, 1);
        assert!(!vp.pressed(ATTACK, None)); // 6th: gone
        vp.begin_step();
        vp.set(JUMP, true);
        steps(&mut vp, 1);
        assert!(vp.pressed(JUMP, None) && !vp.pressed(JUMP, Some(1)));
        vp.consume(JUMP);
        assert!(!vp.pressed(JUMP, None));
    }

    #[test]
    fn stamp_and_hold() {
        let mut vp = pad(10);
        vp.begin_step();
        vp.set(ATTACK, true);
        vp.consume(ATTACK);
        vp.stamp(ATTACK, true);
        assert!(vp.down(ATTACK) && vp.pressed(ATTACK, None) && vp.modded_p(ATTACK));
        vp.begin_step();
        vp.consume(ATTACK);
        vp.hold(JUMP);
        assert!(vp.down(JUMP) && !vp.pressed(JUMP, None));
    }

    #[test]
    fn holds() {
        let mut vp = pad(10);
        vp.begin_step();
        vp.set(GUARD, true);
        vp.consume(GUARD);
        steps(&mut vp, 3);
        vp.set(GUARD, true);
        assert!(vp.down(GUARD) && vp.held_for(GUARD) == 4 && !vp.pressed(GUARD, None));
        vp.set(GUARD, false);
        assert!(!vp.down(GUARD) && vp.held_for(GUARD) == 0);
    }

    #[test]
    fn modifier_and_command_table() {
        assert!(!pressed(&[ATTACK]).modded_p(ATTACK));
        assert!(pressed(&[SHIFT, ATTACK]).modded_p(ATTACK));
        assert!(pressed(&[ATTACK, SHIFT]).modded_p(ATTACK));
        let mut vp = pressed(&[ATTACK]); // modifier a step later: not modded
        vp.begin_step();
        vp.set(SHIFT, true);
        assert!(!vp.modded_p(ATTACK));
        let t = table();
        assert_eq!(pressed(&[ATTACK]).command(&t, &[]), Some((&"attack", ATTACK)));
        assert_eq!(pressed(&[SHIFT, ATTACK]).command(&t, &[]), Some((&"super", ATTACK)));
        assert_eq!(pressed(&[SHIFT, JUMP, ATTACK]).command(&t, &[]).map(|c| *c.0), Some("super"));
        assert_eq!(pressed(&[SHIFT, JUMP]).command(&t, &[]).map(|c| *c.0), Some("jump")); // :any ignores the modifier
        assert_eq!(pressed(&[SHIFT, ATTACK]).command(&t, &["attack"]), None); // modded never falls back
        let mut vp = pressed(&[JUMP, ATTACK]);
        let b = vp.command(&t, &[]).unwrap().1;
        vp.consume(b);
        assert_eq!(vp.command(&t, &[]).map(|c| *c.0), Some("attack"));
    }

    #[test]
    fn no_modifier_and_unknown_names() {
        let mut vp = Vpad::new(&["a", "b"], None, 10).unwrap();
        vp.begin_step();
        vp.set(vp.index("a").unwrap(), true);
        assert!(vp.pressed(0, None) && !vp.modded_p(0));
        assert!(vp.index("c").is_err());
        assert!(Vpad::new(&["a"], Some("b"), 10).is_err());
    }

    #[test]
    fn stick() {
        let mut vp = pad(10);
        vp.stick(3.0, 4.0);
        assert!((vp.sx - 0.6).abs() < 1e-4 && (vp.sy - 0.8).abs() < 1e-4);
        vp.stick(0.3, 0.0);
        assert_eq!(vp.sx, 0.3);
    }

    #[test]
    fn flush_and_clear() {
        let mut vp = pad(10);
        vp.begin_step();
        vp.set(GUARD, true);
        vp.set(ATTACK, true);
        vp.stick(1.0, 0.0);
        vp.flush();
        assert!(vp.down(GUARD) && !vp.pressed(ATTACK, None));
        vp.clear();
        assert!(!vp.down(GUARD) && vp.sx == 0.0);
    }
}
