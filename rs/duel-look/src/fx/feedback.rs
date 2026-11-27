//! port: duel/lisp/feedback.lisp FEEDBACK-SYSTEM — every event a step emitted, shown oldest first (the sink's second pass): the
//! stamps and scraps, the shake, the screen punctuation, the stage's marks, the sounds (collected in `Scene.sounds`), and
//! ken-art.lisp's Bankai bursts. Model looks (SMEAR, HOLD-POSE, MODEL-SUPER / -FLASH, START-GHOST, FACE-BEAT) are the fighters'
//! draw (task 7); the big words (ANNOUNCE) and the HUD's cues the canvas / HUD (task 8, M3b).
use super::crack::{stage_debris, stage_mark};
use super::screen::{focus_lines, impact_frame, shake};
use super::shapes::{PAL_BLOOD, PAL_DUST, PAL_HIT};
use super::stamps::*;
use super::{Em, P_T_SHARD};
use crate::scene::{push_sound, Scene, SoundReq};
use duel_sim::components::Burst;
use duel_sim::ecs::Entity;
use duel_sim::fighter::{kit_of, pos_of, yaw_of};
use duel_sim::look::Event;
use duel_sim::math::{f_cos, f_sin, fwd_x, fwd_z, hypot};
use duel_sim::state::Match;

/// port: feedback.lisp HIT-DIR — the unit direction from ATT to DEF.
fn hit_dir(m: &Match, att: Entity, def: Entity) -> (f32, f32) {
    let (p, q) = (pos_of(m, att), pos_of(m, def));
    let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
    let d = duel_sim::cl::max_f32(0.01, hypot(dx, dz));
    (dx / d, dz / d)
}

impl<'d> Scene<'d> {
    fn em(&mut self) -> Em<'_, 'd> {
        Em { cos: &mut self.cos, fx: &mut self.fx, clock: self.draw.post.fx_clock }
    }
    /// port: feedback.lisp SFX-ON — KEY at E's chest (pos + 1 m).
    fn sfx_on(&mut self, m: &Match, key: &'static str, e: Entity, gain: f32, pitch: f32) {
        let p = pos_of(m, e);
        push_sound(&mut self.sounds, SoundReq::At { key, p: [p[0], p[1] + 1.0, p[2]], gain, pitch });
    }
    fn sfx_at(&mut self, key: &'static str, x: f32, y: f32, z: f32, gain: f32, pitch: f32) {
        push_sound(&mut self.sounds, SoundReq::At { key, p: [x, y, z], gain, pitch });
    }
    fn play(&mut self, key: &'static str, gain: f32) {
        push_sound(&mut self.sounds, SoundReq::Play { key, gain });
    }
    /// port: feedback.lisp STOP-HUM — the side's Breaker hum, if one runs.
    fn stop_hum(&mut self, m: &Match, e: Entity) {
        let i = m.fighter.get(e).map_or(0, |f| f.side as usize);
        if self.hums[i] {
            self.hums[i] = false;
            push_sound(&mut self.sounds, SoundReq::HumStop { side: i });
        }
    }
    /// port: feedback.lisp SHOW-HIT.
    #[allow(clippy::too_many_arguments)]
    fn show_hit(&mut self, m: &Match, att: Entity, def: Entity, x: f32, y: f32, z: f32, counter: bool, dmg: i64, kind: &str) {
        let (dx, dz) = hit_dir(m, att, def);
        let look = if counter {
            "counter"
        } else {
            match kind {
                "breaker" => "breaker",
                "fire" => "fire",
                "bind" | "quick" => "cut",
                _ => "heavy",
            }
        };
        vfx_hit(&mut self.em(), x, y, z, look, dx, dz);
        // task 7: a heavy / counter / breaker look holds the attacker's pose 3 f (HOLD-POSE) and smears the victim (SMEAR)
        let key = match kind {
            "breaker" => "punch",
            "fire" => "explode",
            "bind" => "bones",
            "ice" => "freeze",
            "quick" => "cut",
            _ => "cut-heavy",
        };
        self.sfx_at(key, x, y, z, if kind == "quick" { 0.8 } else { 1.0 }, 1.0);
        // task 7: (setf (model-flash (model def)) (max 0.06 (/ hs 60.0)))
        let d = &mut self.draw;
        if dmg >= 150 {
            shake(d, 0.22, 0.3);
        } else if dmg >= 60 {
            shake(d, 0.09, 0.18);
        } else {
            shake(d, 0.03, 0.1);
        }
        if kind == "fire" {
            stage_mark(&mut self.em(), false, x, z, 0.8);
        } else if dmg >= 150 || kind == "breaker" {
            stage_mark(&mut self.em(), true, x, z, 0.9);
            stage_debris(&mut self.em(), x, z, 3, 1.0);
        }
        if counter {
            impact_frame(&mut self.draw, "manga", 2.0); // task 8: ANNOUNCE "COUNTER"
        }
    }

    /// port: feedback.lisp FEEDBACK-SYSTEM's arm for one event.
    pub(crate) fn feedback(&mut self, m: &Match, ev: &Event) {
        match *ev {
            Event::Swing { e, kind } => {
                // task 7: a heavy swing's SMEAR
                let key = if kind == "quick" { "whoosh-light" } else { kit_of(m, e).swing_sfx.as_deref().unwrap_or("whoosh-heavy") };
                self.sfx_on(m, key, e, 0.7, 1.0);
            }
            Event::Super { e } => self.sfx_on(m, "whoosh-heavy", e, 1.0, 0.7), // task 7: MODEL-SUPER
            Event::Breaker { e } => {
                self.stop_hum(m, e);
                let i = m.fighter.get(e).map_or(0, |f| f.side as usize);
                self.hums[i] = true;
                push_sound(&mut self.sounds, SoundReq::HumStart { side: i, gain: 0.7 });
            }
            Event::BreakerEnd { e } => self.stop_hum(m, e),
            Event::Rush { e } => {
                let p = pos_of(m, e);
                vfx_kikon_rush(&mut self.em(), p[0], p[2]); // task 7: SMEAR, MODEL-SUPER 0.12
                self.sfx_on(m, "whoosh-heavy", e, 1.0, 0.6);
            }
            Event::RushDash { e } => {
                let Some(mv) = m.fighter.get(e).and_then(|f| f.mv).map(|id| duel_sim::fighter::mv(m, id)) else { return };
                let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
                if let Some(sfx) = mv.params.sfx.as_deref() {
                    self.sfx_on(m, sfx, e, 1.0, 1.0);
                }
                vfx_rush_dash(&mut self.em(), p[0], p[2], fwd_x(yaw), fwd_z(yaw), mv.params.look.as_deref());
                if mv.params.look.as_deref() == Some("flash-step") {
                    self.unported.get_or_insert("a flash step's afterimage (draw.lisp START-GHOST: task 7)");
                }
            }
            Event::KikonFollow { att, .. } => {
                let p = pos_of(m, att);
                vfx_kikon_rush(&mut self.em(), p[0], p[2]);
                self.sfx_on(m, "whoosh-heavy", att, 1.0, 0.6);
                focus_lines(&mut self.draw, 10.0); // task 8: ANNOUNCE "KIKON"
            }
            Event::Hit { att, def, x, y, z, hs: _, counter, dmg, kind } => {
                self.show_hit(m, att, def, x, y, z, counter, dmg, kind);
                match kit_of(m, att).hooks.get("hit-fx").map(|h| h.as_str()) {
                    Some("KEN-BK-HIT-FX") => {
                        // port: ken.lisp KEN-BK-HIT-FX (the Bankai kits' :hit-fx: a sound)
                        self.sfx_at("rift-cut", x, y, z, 0.55, 1.0);
                        if dmg >= 80 || kind != "quick" {
                            self.sfx_at("awaken-boom", x, y, z, 0.4, 1.0);
                        }
                    }
                    Some(_) => {
                        self.unported.get_or_insert("a kit's :hit-fx (Hisagi's chain tip: M4)");
                    }
                    None => {}
                }
            }
            Event::Blocked { att, def, x, y, z } => {
                let (dx, dz) = hit_dir(m, att, def);
                vfx_hit(&mut self.em(), x, y, z, "guard", dx, dz);
                if duel_sim::fighter::passive_p(m, att, "pierce") {
                    vfx_hit(&mut self.em(), x + 0.7 * dx, y, z + 0.7 * dz, "cut", dx, dz);
                }
                self.sfx_at("clang", x, y, z, 1.0, 1.0);
            }
            Event::Armored { def, x, y, z } => {
                if kit_of(m, def).hooks.contains_key("armored-fx") {
                    self.unported.get_or_insert("a kit's :armored-fx (Yamamoto's garb: M4)");
                } else {
                    vfx_hit(&mut self.em(), x, y, z, "reiatsu", 0.0, -1.0);
                }
                self.sfx_at("cut", x, y, z, 0.7, 1.0);
                if let Some(k) = kit_of(m, def).absorb_sfx.as_deref() {
                    self.sfx_on(m, k, def, 0.8, 1.0);
                }
            }
            Event::Parried { att, def, x, y, z } => {
                let (dx, dz) = hit_dir(m, att, def);
                vfx_ember(&mut self.em(), x, y, z, -dx, -dz, 1.3);
                self.sfx_at("clang", x, y, z, 1.0, 1.0);
                self.sfx_at("sizzle", x, y, z, 1.0, 1.0);
                shake(&mut self.draw, 0.12, 0.2);
                impact_frame(&mut self.draw, "negative", 1.0); // task 8: ANNOUNCE "PARRY"
            }
            Event::Refused { e, .. } => self.sfx_on(m, "clang", e, 0.35, 1.6), // M3b: WEBHUD-REFUSED!
            Event::SpBreak { .. } => {}                                          // M3b: WEBHUD-BREAK!
            Event::Absorbed { def, x, y, z } => {
                vfx_hit(&mut self.em(), x, y, z, "guard", 0.0, -1.0);
                self.sfx_at("cut", x, y, z, 0.7, 1.0);
                if let Some(k) = kit_of(m, def).absorb_sfx.as_deref()
                    && self.cos.rnd01() < 0.5
                {
                    self.sfx_on(m, k, def, 0.8, 1.0);
                }
            }
            Event::GuardCrush { att, def, x, y, z } => {
                let (dx, dz) = hit_dir(m, att, def);
                vfx_hit(&mut self.em(), x, y, z, "guard-crush", dx, dz);
                self.sfx_at("guard-break", x, y, z, 1.0, 1.2);
                self.sfx_at("clang", x, y, z, 1.0, 0.8);
                shake(&mut self.draw, 0.15, 0.25);
                impact_frame(&mut self.draw, "negative", 1.0); // task 8: ANNOUNCE "GUARD CRUSH"
            }
            Event::GuardBack { e } => self.sfx_on(m, "clang", e, 0.5, 1.4), // task 8: ANNOUNCE "GUARD"
            Event::GuardBreak { att, def, x, y, z } => {
                let (dx, dz) = hit_dir(m, att, def);
                vfx_hit(&mut self.em(), x, y, z, "guard-break", dx, dz);
                self.sfx_at("guard-break", x, y, z, 1.0, 1.0);
                shake(&mut self.draw, 0.2, 0.3);
                self.fx.ui_flash = [1.0, 1.0, 1.0, 0.9, 50.0];
                stage_mark(&mut self.em(), true, x, z, 1.1);
                stage_debris(&mut self.em(), x, z, 4, 1.0); // task 8: ANNOUNCE "GUARD BREAK"
            }
            Event::StanceBreak { att, def, x, y, z } => {
                let (dx, dz) = hit_dir(m, att, def);
                vfx_hit(&mut self.em(), x, y, z, "guard-break", dx, dz);
                self.sfx_at("guard-break", x, y, z, 1.0, 1.0); // task 8: ANNOUNCE "BROKEN"
            }
            Event::Clash { x, y, z } => {
                vfx_hit(&mut self.em(), x, y, z, "clash", 0.0, -1.0);
                self.sfx_at("clash", x, y, z, 1.0, 1.0);
                shake(&mut self.draw, 0.25, 0.3);
                stage_mark(&mut self.em(), true, x, z, 1.2);
                stage_debris(&mut self.em(), x, z, 4, 1.0);
                impact_frame(&mut self.draw, "negative", 2.0);
                focus_lines(&mut self.draw, 20.0); // task 8: the lines' centre (x y z), ANNOUNCE "CLASH"
            }
            Event::HazardCut { x, y, z } => {
                vfx_hit(&mut self.em(), x, y, z, "heavy", 0.0, -1.0);
                self.sfx_at("cut-heavy", x, y, z, 1.0, 1.0);
            }
            Event::Step { e } => {
                let p = pos_of(m, e);
                let v = m.motion.get(e).map_or([0.0; 3], |mo| mo.kb);
                let l = hypot(v[0], v[2]);
                let yaw = yaw_of(m, e);
                let (dx, dz) = if l > 1e-4 { (v[0] / l, v[2] / l) } else { (fwd_x(yaw), fwd_z(yaw)) };
                vfx_step_dust(&mut self.em(), p[0], p[2], -dx, -dz); // task 7: SMEAR
                self.sfx_on(m, "step", e, 0.6, 1.0);
                let leap = self.data.clips.get("ke-b-step-b");
                if self.model(e).and_then(|md| md.anim.clip).zip(leap).is_some_and(|(a, b)| std::ptr::eq(a, b)) {
                    self.sfx_on(m, "oni-roar", e, 1.0, 1.0); // task 7: FACE-BEAT :shout 0.4
                }
            }
            Event::HohoOut { e, x, z } => {
                let yaw = yaw_of(m, e);
                vfx_hoho(&mut self.em(), x, 1.0, z, false, fwd_x(yaw), fwd_z(yaw));
                self.unported.get_or_insert("the Hoho's afterimage (draw.lisp START-GHOST: task 7)");
                self.sfx_on(m, "hoho-out", e, 1.0, 1.0);
            }
            Event::HohoIn { e, x, z } => {
                let yaw = yaw_of(m, e);
                vfx_hoho(&mut self.em(), x, 1.0, z, true, fwd_x(yaw), fwd_z(yaw));
                self.sfx_on(m, "hoho-in", e, 1.0, 1.0);
            }
            Event::Perfect { .. } => {
                self.play("perfect", 1.0);
                self.draw.cam.punch_t = 0.5; // task 8: ANNOUNCE "PERFECT"
            }
            Event::Burst { e, mode, .. } => {
                let p = pos_of(m, e);
                vfx_burst(&mut self.em(), p[0], p[1], p[2]);
                self.sfx_on(m, "clash", e, 1.0, if mode == Burst::White { 0.9 } else { 0.7 });
                self.sfx_on(m, "hoho-in", e, 1.0, 1.0);
                shake(&mut self.draw, 0.15, 0.25); // task 8: ANNOUNCE (BURST-NAME m)
            }
            Event::BurstEnd { e } => self.sfx_on(m, "hoho-out", e, 0.5, 0.8),
            Event::Launch { e } => self.sfx_on(m, "launch", e, 0.8, 1.0),
            Event::Land { e } => {
                self.sfx_on(m, "land", e, 1.0, 1.0);
                let p = pos_of(m, e);
                vfx_shockwave(&mut self.em(), p[0], p[2], 1.2, PAL_DUST);
                stage_mark(&mut self.em(), true, p[0], p[2], 0.6);
                stage_debris(&mut self.em(), p[0], p[2], 2, 0.6);
            }
            Event::Konpaku { victim, lost } => {
                // port: hud.lisp PIPS-SHATTER (the glass burst at ACTOR-POINT 1.6, its sound)
                let p = pos_of(m, victim);
                vfx_konpaku_shatter(&mut self.em(), p[0], p[1] + 1.6, p[2], lost.max(0) as usize);
                self.play("konpaku-shatter", 1.0);
            }
            Event::Kikon { .. } => self.play("bell", 1.0), // task 7: MODEL-SUPER 0.15 of the attacker
            Event::SoulBreak { .. } | Event::Bankai { .. } => {}
            Event::Awaken { e } => self.sfx_on(m, "awaken-boom", e, 1.0, 1.0),
            Event::Form { .. } => {}                                 // task 8: ANNOUNCE the kit's callout
            Event::Evolution { .. } => self.play("evolution", 1.0), // task 8: ANNOUNCE "EVOLUTION"
            Event::Sfx { key, e } => self.sfx_on(m, key, e, 1.0, 1.0),
            Event::GroundScar { x, z, yaw, ds, n, r } => {
                // port: feedback.lisp GROUND-SCAR
                for &d in &ds[..n as usize] {
                    let (mx, mz) = (x + d * fwd_x(yaw), z + d * fwd_z(yaw));
                    stage_mark(&mut self.em(), true, mx, mz, r);
                    stage_debris(&mut self.em(), mx, mz, 3, 1.0);
                }
            }
            Event::Reset => {
                self.play("bell", 0.6);
                self.fx.stage.clear_marks();
            }
            Event::KenBkBurst { e, kind } => self.ken_bk_burst(m, e, kind),
        }
    }

    /// FEEDBACK-SYSTEM's :ken-bk-burst arm (Kenpachi's special AS, DUEL_KEN_V3 §30).
    fn ken_bk_burst(&mut self, m: &Match, e: Entity, kind: &'static str) {
        let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
        let ahead = (p[0] + 2.2 * fwd_x(yaw), p[2] + 2.2 * fwd_z(yaw));
        match kind {
            "bankai" => {
                vfx_ken_bk_burst(&mut self.em(), p[0], p[2], true);
                vfx_shockwave(&mut self.em(), p[0], p[2], 7.0, PAL_BLOOD);
                impact_frame(&mut self.draw, "red", 6.0);
                self.sfx_on(m, "awaken-boom", e, 1.0, 1.0);
                self.sfx_on(m, "oni-roar", e, 1.0, 1.0);
                self.sfx_on(m, "explode", e, 0.7, 1.0);
                shake(&mut self.draw, 0.45, 0.6);
            }
            "chigiri-draw" => {
                impact_frame(&mut self.draw, "negative", 1.0);
                self.sfx_on(m, "rift-open", e, 1.0, 1.0);
            }
            "chigiri-still" => {
                let f = self.data.tuning["*CHIGIRI-STILL-FRAMES*"].as_f64().expect("tuning *CHIGIRI-STILL-FRAMES*") as f32;
                impact_frame(&mut self.draw, "manga", f);
            }
            "chigiri-quake" => {
                self.sfx_on(m, "awaken-rise", e, 1.0, 1.0);
                self.sfx_on(m, "rift-open", e, 1.2, 1.0);
                shake(&mut self.draw, 0.15, 0.12);
            }
            "chigiri" => {
                vfx_ken_bk_burst(&mut self.em(), p[0], p[2], true);
                impact_frame(&mut self.draw, "red", 10.0);
                self.sfx_on(m, "oni-roar", e, 1.0, 1.0);
                self.sfx_on(m, "konpaku-shatter", e, 1.0, 1.0);
                self.sfx_on(m, "rift-cut", e, 1.0, 1.0);
                shake(&mut self.draw, 0.35, 0.5);
            }
            "tategoto-cut" => {
                vfx_ken_tategoto_cut(&mut self.em(), ahead.0, ahead.1);
                self.sfx_on(m, "rift-cut", e, 1.0, 1.0);
                self.sfx_on(m, "kikon-slash", e, 0.8, 1.0);
                shake(&mut self.draw, 0.35, 0.45);
            }
            _ => {
                vfx_ken_bk_burst(&mut self.em(), ahead.0, ahead.1, false);
                self.sfx_on(m, "ground-crack", e, 1.0, 1.0);
                self.sfx_on(m, "kikon-slash", e, 0.7, 1.0);
                self.sfx_on(m, "rift-open", e, 1.0, 1.0);
                shake(&mut self.draw, 0.3, 0.4);
            }
        }
    }
}

/// port: ken-art.lisp VFX-KEN-BK-BURST — CHIGIRI: 28 white and BLOOD shards round (x z), a white ring; else (TATE-GOTO) 12 and a
/// DUST ring; a light.
pub fn vfx_ken_bk_burst(c: &mut Em, x: f32, z: f32, chigiri: bool) {
    let n = if chigiri { 28 } else { 12 };
    for i in 0..n {
        let a = c.rr(0.0, 6.2832);
        let sp = c.rr(3.0, 7.0);
        let r = c.rr(0.6, 2.4);
        let (ca, sa) = (f_cos(a), f_sin(a));
        let y = c.rr(0.4, 2.4);
        let vy = c.rr(0.5, 4.0);
        let l = c.rr(0.5, 0.9);
        let s = c.rr(0.12, 0.26);
        let pal = if i % 3 == 0 { PAL_BLOOD } else { PAL_HIT };
        c.fx.emit_a(P_T_SHARD, x + r * ca, y, z + r * sa, sp * ca, vy, sp * sa, l, s, 7.0, 0.05, 0.0, 0.0, pal);
    }
    vfx_shockwave(c, x, z, if chigiri { 4.5 } else { 3.0 }, if chigiri { PAL_HIT } else { PAL_DUST });
    super::vfx::flash_light(c, x, 1.4, z, 1.0, 0.95, 0.9);
}

/// port: ken-art.lisp VFX-KEN-TATEGOTO-CUT — the heavy white hit, the INK gash stood up from the floor, 14 shards, a light.
pub fn vfx_ken_tategoto_cut(c: &mut Em, x: f32, z: f32) {
    vfx_hit(c, x, 1.2, z, "heavy", 0.0, -1.0);
    stamp(c, Kind::Gash, x, 0.2, z, 0.0, 1.0, 0.0, 5.5, 0.0);
    for i in 0..14 {
        let a = c.rr(0.0, 6.2832);
        let sp = c.rr(2.5, 6.0);
        let y = c.rr(0.3, 3.0);
        let vy = c.rr(0.5, 3.5);
        let l = c.rr(0.5, 0.9);
        let s = c.rr(0.12, 0.24);
        let pal = if i % 3 == 0 { PAL_BLOOD } else { PAL_HIT };
        c.fx.emit_a(P_T_SHARD, x, y, z, sp * f_cos(a), vy, sp * f_sin(a), l, s, 7.0, 0.05, 0.0, 0.0, pal);
    }
    super::vfx::flash_light(c, x, 1.4, z, 1.0, 0.95, 0.9);
}
