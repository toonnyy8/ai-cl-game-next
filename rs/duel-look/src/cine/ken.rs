//! port: Kenpachi's cinematics' looks (ken.lisp, ken-look.lisp): the AT and DURING look forms of his nine DEFCINEs and the looks they
//! call (KEN-FOREST, KE-GLASS, KE-RIFT-BAND, KE-KK-CAM, the dust, blood and chips, the Kikon line's streaks and cuts, VFX-SKY-SPLIT,
//! VFX-AWAKEN-BURST, VFX-SKULL). The forms that move an actor (FACE-EACH-OTHER, CINE-PLACE, KE-KK-LINE / -AT / -YAW) are
//! `duel_sim::ken::cine`; these run after them (ruling R9).
use super::{during, Card};
use crate::canvas::{ui_poly4, ui_rect, ui_rect_outline, ui_scale};
use crate::draw::FrameOut;
use crate::fx::shapes::{drawing_no, fx_crescent, fx_disc, fx_line, fx_shard, fx_star, hash01, PAL_BLOOD, PAL_DUST, PAL_GOLD, PAL_HIT, PAL_INK, PAL_REIATSU};
use crate::fx::stamps::{stamp, vfx_shockwave, Kind};
use crate::fx::vfx::{flash_light, t_blob};
use crate::fx::{Ctx, Em, Mode, P_T_SHARD};
use crate::scene::Scene;
use duel_sim::cl::{expt2, max_f32, min_f32, mod_f32};
use duel_sim::ecs::Entity;
use duel_sim::fighter::{pos_of, yaw_of};
use duel_sim::ken::cine::KenCine;
use duel_sim::math::{f_cos, f_sin, f_sqrt, fwd_x, fwd_z};
use duel_sim::state::Match;

const INK: [f32; 4] = [0.03, 0.03, 0.047, 1.0];
const BLOOD_RIM: [f32; 3] = [0.82, 0.06, 0.11];

/// The running cinematic's Kikon line (ken-look.lisp `*ke-kk*`: KE-KK-LINE's victim x z and unit toward Kenpachi's side).
fn kk(m: &Match) -> [f32; 4] {
    m.cine.as_ref().map_or([0.0; 4], |c| c.line)
}

/// port: engine/lisp/fx-shapes.lisp %T-SHARD (FX-EMIT +P-T-SHARD+ with wob 0.05).
#[allow(clippy::too_many_arguments)]
pub(crate) fn t_shard(c: &mut Em, x: f32, y: f32, z: f32, vx: f32, vy: f32, vz: f32, life: f32, size: f32, grav: f32, pal: f32) {
    c.fx.emit_a(P_T_SHARD, x, y, z, vx, vy, vz, life, size, grav, 0.05, 0.0, 0.0, pal);
}

impl<'d> Scene<'d> {
    /// port: ken.lisp KE-KK-CAM — the camera on the Kikon line: S m from the victim's mark toward Kenpachi's side, HC high, looking at SL
    /// m along it, HL high.
    fn kk_cam(&mut self, m: &Match, s: f32, hc: f32, sl: f32, hl: f32) {
        (self.cine.subject, self.cine.close) = (None, false);
        let l = kk(m);
        self.cine_cam(l[0] + s * l[2], hc, l[1] + s * l[3], l[0] + sl * l[2], hl, l[1] + sl * l[3]);
    }

    /// The window's UI scale (UI-SCALE).
    pub(crate) fn ui(&self) -> f32 {
        let i = &self.inputs;
        ui_scale(i.width, i.height, i.density) as f32
    }

    /// Kenpachi's scripts' step-mode look forms at frame CF.
    pub(crate) fn ken_at(&mut self, m: &Match, k: KenCine, cf: i64, a: Entity, v: Entity) {
        match k {
            KenCine::Nozarashi => self.nozarashi_at(m, cf, a, v),
            KenCine::Bankai => self.bankai_at(m, cf, a, v),
            KenCine::KrKikon => self.kr_at(m, cf, a, v),
            KenCine::ZhKikon => self.zh_at(m, cf, a, v),
            KenCine::ZKikon1 => self.z1_at(m, cf, a, v),
            KenCine::ZKikon2 => self.z2_at(m, cf, a, v),
            KenCine::ZKikon3 => self.z3_at(m, cf, a, v),
            KenCine::SKikon1 => self.s1_at(m, cf, a, v),
            KenCine::SKikon2 => self.s2_at(m, cf, a, v),
        }
    }

    /// Kenpachi's scripts' draw-mode look forms at frame CF (in script order), into OUT; DT is CINE-DT.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn ken_during(&mut self, m: &Match, k: KenCine, cf: i64, a: Entity, v: Entity, out: &mut FrameOut, dt: f32) {
        match k {
            KenCine::Nozarashi => {
                if during(cf, 0, 108).is_some() {
                    let p = pos_of(m, a);
                    let h = if cf < 28 { 2.0 } else if cf < 58 { 6.5 } else { 3.2 };
                    let kk = if cf < 26 { 0.1 + 0.02 * cf as f32 } else { 1.0 };
                    crate::fx::vfx::vfx_aura(&mut self.ctx(out), p[0], 0.0, p[2], h, "nozarashi", dt, kk);
                }
                if during(cf, 40, 50).is_some() {
                    let (p, yaw) = (pos_of(m, a), yaw_of(m, a));
                    vfx_skull(&mut self.ctx(out), p[0] - 0.25 * fwd_x(yaw), 2.9, p[2] - 0.25 * fwd_z(yaw), 0.98);
                }
            }
            KenCine::Bankai => {
                if during(cf, 12, 58).is_some() {
                    self.ken_forest(cf, &mut out.ui);
                }
                if during(cf, 58, 186).is_some() {
                    let p = pos_of(m, a);
                    crate::fx::vfx::vfx_aura(&mut self.ctx(out), p[0], 0.0, p[2], 2.4, "oni", dt, if cf < 78 { 1.0 } else { 0.8 });
                }
            }
            KenCine::KrKikon => {
                if let Some(u) = during(cf, 40, 90) {
                    self.shot_on(m, v, 30.0 + 170.0 * u, 4.6 - 0.8 * u, 1.3 + 0.5 * u, 1.3, 0.0, 0.0);
                    self.lens(50.0, 6.0 * u);
                }
                if during(cf, 40, 112).is_some() {
                    let l = kk(m);
                    crate::fx::hazard::chigiri_cuts(&mut self.ctx(out), l[0], l[1], cf - 40, 24, 1.6, 1.4, 60, 10, 8);
                }
                if during(cf, 100, 140).is_some() {
                    self.ke_glass(cf - 100, &mut out.ui);
                }
            }
            KenCine::ZhKikon => {
                if let Some(u) = during(cf, 50, 56) {
                    self.shot_on(m, a, 110.0, 4.2, 0.4 + 2.4 * u, 1.6 + 1.6 * u, 0.0, 0.0);
                    self.lens(60.0, 0.0);
                }
                if during(cf, 56, 76).is_some() {
                    self.kk_cam(m, 10.0, 5.6, -6.0, 1.0);
                }
                if during(cf, 76, 96).is_some() {
                    self.kk_cam(m, -5.5, 1.4, 3.0, 2.0);
                }
                if during(cf, 96, 104).is_some() {
                    self.kk_cam(m, 10.0, 5.6, -6.0, 1.0);
                }
                if during(cf, 56, 160).is_some() {
                    let l = kk(m);
                    self.ke_rift_band(l[0], l[1], cf - 56, 40, &mut out.ui);
                }
                if during(cf, 62, 76).is_some() {
                    let p = pos_of(m, a);
                    crate::fx::hazard::tategoto_wave_at(&mut self.ctx(out), p[0], p[2], yaw_of(m, a), cf - 62, 30.0);
                }
                if during(cf, 60, 180).is_some() {
                    let (p, yaw) = (pos_of(m, a), yaw_of(m, a));
                    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
                    let age = (cf - 60) as f32 / 60.0;
                    crate::fx::hazard::vfx_line_cut(&mut self.ctx(out), p[0] + 0.8 * fx, p[2] + 0.8 * fz, p[0] + 30.0 * fx, p[2] + 30.0 * fz, age, 1.5, "meteor", 0.0);
                }
            }
            KenCine::ZKikon1 => {
                if let Some(u) = during(cf, 108, 122) {
                    // (KE-KK-YAW of V ran first in the sim's draw forms: `duel_sim::ken::cine::draw`)
                    let (l, q) = (kk(m), pos_of(m, v));
                    let (px, pz) = (l[3], -l[2]);
                    let k = (u * u) * (3.0 - 2.0 * u);
                    self.cine_cam(
                        (q[0] + 1.3 * l[2]) + 1.5 * px,
                        1.8,
                        (q[1] + 1.3 * l[3]) + 1.5 * pz,
                        q[0] + (1.0 - 2.6 * k) * l[2],
                        1.6 - 0.4 * k,
                        q[1] + (1.0 - 2.6 * k) * l[3],
                    );
                }
            }
            KenCine::ZKikon2 => {}
            KenCine::ZKikon3 => {
                if let Some(u) = during(cf, 98, 120) {
                    self.shot_on(m, a, 25.0, 3.0 - 0.8 * u, 1.6, 1.7, 0.0, 0.0);
                    self.lens(58.0, 0.0);
                }
                if during(cf, 122, 204).is_some() {
                    let q = pos_of(m, v);
                    self.vfx_sky_split(q[0], q[2], yaw_of(m, a), (cf - 122) as f32 / 60.0, 1.4, out);
                }
                if during(cf, 124, 204).is_some() {
                    let (p, yaw) = (pos_of(m, a), yaw_of(m, a));
                    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
                    let age = (cf - 124) as f32 / 60.0;
                    crate::fx::hazard::vfx_line_cut(&mut self.ctx(out), p[0] + 1.2 * fx, p[2] + 1.2 * fz, p[0] + 30.0 * fx, p[2] + 30.0 * fz, age, 1.4, "meteor", 0.0);
                }
            }
            KenCine::SKikon1 => {
                if let Some(u) = during(cf, 76, 100) {
                    ke_kk_streak(&mut self.ctx(out), kk(m), 3.2, max_f32(-3.2, 3.2 - 6.4 * min_f32(1.0, 2.0 * u)), 1.0 - u);
                }
                if during(cf, 98, 116).is_some() {
                    let p = pos_of(m, a);
                    let c = &mut self.ctx(out);
                    let seed = 640.0 + drawing_no(c.clock, 12.0);
                    crate::draw::ken::tornado(c, p[0], p[2], 1.5 * (cf - 98) as f32, 0.9, seed);
                }
            }
            KenCine::SKikon2 => {
                let l = kk(m);
                if during(cf, 79, 122).is_some() {
                    let q = pos_of(m, v);
                    self.cine_cam((l[0] + 4.2 * l[2]) + 3.2 * l[3], 0.4, (l[1] + 4.2 * l[3]) + -3.2 * l[2], q[0], q[1] + 0.8, q[2]);
                }
                if let Some(u) = during(cf, 165, 168) {
                    let c = &mut self.ctx(out);
                    let seed = 690.0 + drawing_no(c.clock, 12.0);
                    ke_kk_cut(c, l, 0.3 + 0.7 * u, 0.0, 0.0, seed);
                }
                if during(cf, 122, 152).is_some() {
                    let (p, q) = (pos_of(m, a), pos_of(m, v));
                    let (mx, mz) = (0.5 * (p[0] + q[0]), 0.5 * (p[2] + q[2]));
                    let my = 1.0 + 0.5 * (p[1] + q[1]);
                    self.cine_cam(mx + 11.0 * l[3], 0.4 + my, mz - 11.0 * l[2], mx, 0.8 + my, mz);
                }
                if during(cf, 152, 168).is_some() {
                    let p = pos_of(m, a);
                    self.cine_cam((p[0] + 2.8 * l[3]) + 1.2 * l[2], p[1] - 0.4, (p[2] + -2.8 * l[2]) + 1.2 * l[3], p[0], p[1] + 1.7, p[2]);
                }
                if let Some(u) = during(cf, 148, 170) {
                    let p = pos_of(m, a);
                    fx_billboard(&mut self.ctx(out), p[0], p[1] + 1.6, p[2], 1.6 * min_f32(1.0, 2.0 * u), 1.0, 0.85, 0.3, 0.5 * (1.0 - u * u));
                }
                if during(cf, 168, 196).is_some() {
                    self.cine_cam(l[0] + -10.0 * l[2], 3.6, l[1] + -10.0 * l[3], l[0] + 0.5 * l[2], 5.0, l[1] + 0.5 * l[3]);
                }
                if let Some(u) = during(cf, 168, 176) {
                    let c = &mut self.ctx(out);
                    let seed = 700.0 + drawing_no(c.clock, 12.0);
                    ke_kk_cut(c, l, 1.0 - 0.3 * u, 0.0, 0.0, seed);
                }
                if let Some(u) = during(cf, 172, 228) {
                    let d = 2.4 * f_sqrt(u);
                    let dr = 6.0 * expt2(max_f32(0.0, (u - 0.4) / 0.6));
                    let k = 1.0 - 0.5 * u;
                    let c = &mut self.ctx(out);
                    let s1 = 710.0 + drawing_no(c.clock, 12.0);
                    ke_kk_cut(c, l, k, d, dr, s1);
                    let s2 = 720.0 + drawing_no(c.clock, 12.0);
                    ke_kk_cut(c, l, k, -d, dr, s2);
                }
                if during(cf, 196, 228).is_some() {
                    let (p, q) = (pos_of(m, a), pos_of(m, v));
                    let (mx, mz, my) = (0.5 * (p[0] + q[0]), 0.5 * (p[2] + q[2]), 0.5 * (p[1] + q[1]));
                    self.cine_cam(mx + 9.0 * l[3], my + 1.2, mz - 9.0 * l[2], mx, my + 1.0, mz);
                }
                if let Some(u) = during(cf, 196, 228) {
                    ke_kk_tail(&mut self.ctx(out), pos_of(m, a), 1.0 - 0.4 * u);
                }
            }
        }
    }

    // ------------------------------------------------------------ the scripts' AT forms

    /// port: ken.lisp KEN-NOZARASHI-CINE's AT forms.
    fn nozarashi_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.clip(m, a, "ke-release", 3.0, 1.0 / 1.5, 0.0);
                self.clip(m, v, Self::stance(m, v), 6.0, 1.0, 0.0);
                self.set_weapon(a, "ken-katana");
                self.shot_on(m, a, 10.0, 1.9, 1.9, 1.85, 0.0, 0.0);
                self.hold_both(a, v, 10.0);
                self.impact("negative", 2.0);
                self.sfx("awaken-rise", 1.0, 1.0);
            }
            26 => {
                let p = pos_of(m, a);
                vfx_awaken_burst(&mut self.em(), p[0], 1.0, p[2], false);
                vfx_shockwave(&mut self.em(), p[0], p[2], 7.0, PAL_REIATSU); // (:rgb (1.0 0.9 0.3): REIATSU)
                self.impact("negative", 2.0);
                self.sfx("awaken-boom", 1.0, 1.0);
                self.shake(0.2, 0.3);
            }
            28 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(30.0, [1.0, 0.85, 0.23]);
                self.shot_on(m, a, 0.0, 4.6, 0.8, 1.6, 0.0, 0.0);
                self.lens(52.0, 0.0);
            }
            54 => self.clip(m, a, "ke-nome", 2.0, 1.0, 0.0),
            58 => {
                self.card(None, None);
                self.shot_on(m, a, 30.0, 1.6, 0.45, 1.5, 0.0, 0.0);
                self.lens(86.0, -8.0);
                self.silence(20.0);
            }
            78 => {
                self.set_weapon(a, "nozarashi");
                self.impact("negative", 2.0);
                self.card(Some(Card::White), Some(a));
                self.shot_on(m, a, 20.0, 4.4, 0.8, 1.3, 0.0, 0.9);
                self.lens(42.0, 0.0);
                let mut b = self.bcap("野晒");
                (b.kanji2, b.reading, b.side, b.ink) = (Some("呑め、"), Some("NOME, NOZARASHI"), 0, true);
                self.caption(b);
                self.sfx("whoosh-cleaver", 1.0, 1.0);
            }
            80 => self.impact("manga", 10.0),
            _ => {}
        }
    }

    /// port: ken.lisp KEN-BANKAI-CINE's AT forms.
    fn bankai_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                // (the base body without the Bankai kit's hide list; REFRESH-LOOK at 58 puts the oni and the list back)
                let data: &'d duel_data::Data = self.data;
                let body = data.bodies.get_key_value("kenpachi").map(|(k, _)| k.as_str()).expect("the kenpachi body");
                if let Some(md) = self.model_mut(a) {
                    (md.body, md.hide, md.hide_x) = (body, &[], &[]);
                }
                self.set_weapon(a, "nozarashi");
                self.cine.aura_off = Some(a);
                self.clip(m, a, "sh-crumple", 0.0, 1.0, 0.95);
                self.clip(m, v, Self::stance(m, v), 6.0, 1.0, 0.0);
                self.shot_on(m, a, 35.0, 3.0, 0.7, 0.9, 0.0, -0.7);
                self.lens(50.0, -6.0);
                self.hold(v, 12.0);
                self.freeze(12.0);
                self.impact("negative", 2.0);
                self.silence(12.0);
                self.impact_splash_at(m, a, 0.4, 10.0, 0.05);
            }
            12 => {
                self.card(Some(Card::White), Some(a));
                self.shot_on(m, a, 20.0, 3.6, 0.8, 0.9, 0.0, -1.0);
                self.lens(44.0, 0.0);
                let mut b = self.bcap("草鹿");
                (b.reading, b.sub, b.side, b.ink) = (Some("KUSAJISHI"), Some("KEN-CHAN"), 1, true);
                self.caption(b);
            }
            14 => self.sfx("yachiru-call", 1.0, 1.0),
            58 => {
                self.card(None, None);
                let kit = duel_sim::fighter::kit_of(m, a);
                self.refresh_look(a, kit);
                self.cine.aura_off = None;
                self.caption_exit();
                self.clip(m, a, "ke-b-roar", 2.0, 1.0, 0.0);
                let p = pos_of(m, a);
                vfx_awaken_burst(&mut self.em(), p[0], 0.0, p[2], true);
                vfx_shockwave(&mut self.em(), p[0], p[2], 7.0, PAL_BLOOD);
                vfx_shockwave(&mut self.em(), p[0], p[2], 4.0, PAL_INK);
                self.shot_on(m, a, 25.0, 5.2, 1.0, 1.6, 0.0, 0.0);
                self.lens(55.0, 0.0);
                self.impact("negative", 1.0);
                self.sfx("awaken-boom", 1.0, 1.0);
                self.sfx("laugh", 0.7, 1.0);
                self.shake(0.25, 0.35);
            }
            60 => self.impact("manga", 12.0),
            78 => {
                self.shot_on(m, a, 14.0, 1.05, 1.5, 1.58, 0.0, 0.0);
                self.lens(80.0, -8.0);
                self.silence(20.0);
                self.shout(a, 0.6, false);
            }
            108 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(58.0, BLOOD_RIM);
                self.shot_on(m, a, 20.0, 4.4, 0.8, 1.3, 0.0, 0.9);
                self.lens(42.0, 0.0);
                self.clip(m, a, Self::stance(m, a), 8.0, 1.0, 0.0);
                let mut b = self.bcap("卍解");
                (b.reading, b.side, b.hanko) = (Some("BANKAI"), 0, true);
                self.caption(b);
            }
            166 => {
                self.card(None, None);
                self.shot_on(m, a, 165.0, 5.6, 1.7, 1.4, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.caption_exit();
            }
            _ => {}
        }
    }

    /// port: ken.lisp KEN-KR-KIKON-CINE's AT forms and its step-mode tremor.
    fn kr_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.cine.aura_off = Some(a);
                self.clip(m, a, "ke-kr-chigiri", 2.0, 0.05, 0.0);
                self.clip(m, v, "sh-kikon-victim", 4.0, 1.0, 0.0);
                self.hold_both(a, v, 12.0);
                self.impact("negative", 1.0);
                self.sfx("whoosh-cleaver", 1.0, 1.0);
            }
            12 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(18.0, BLOOD_RIM);
                self.shot_on(m, a, 60.0, 4.2, 0.7, 1.5, 1.0, 0.8);
                self.lens(46.0, 8.0);
                self.silence(26.0);
                self.clip(m, a, "ke-kr-chigiri", 4.0, 8.0 / 18.0, 0.0);
                let mut b = self.bcap("千切");
                (b.kanji2, b.reading, b.sub, b.side, b.hanko) = (Some("狂嵐"), Some("CHIGIRI"), Some("KYORAN"), 0, true);
                self.caption(b);
            }
            30 => {
                self.card(None, None);
                self.shot_on(m, a, 85.0, 3.4, 1.0, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ke-kr-chigiri", 0.0, 0.3, 8.0 / 60.0);
            }
            40 => {
                self.clip(m, a, "ke-kr-chigiri", 0.0, 1.0, 11.0 / 60.0);
                self.impact("negative", 1.0);
                self.ui_flash(1.0, 1.0, 1.0, 0.8, 6.0);
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-stagger", 1.0, 1.0, 0.0);
                self.sfx("whoosh-cleaver", 1.0, 1.0);
                self.sfx("kikon-slash", 1.0, 1.0);
                self.shake(0.2, 0.25);
                self.focus(6.0, None);
            }
            42 => self.cine_grade(Some("manga")),
            46 => self.silence(42.0),
            52 => self.clip(m, a, "ke-kr-chigiri", 0.0, 12.0 / 38.0, 22.0 / 60.0),
            90 => {
                self.cine_grade(None);
                self.impact("negative", 1.0);
                self.card(Some(Card::Black), Some(a));
                self.back_rim(10.0, BLOOD_RIM);
                self.shot_on(m, a, -40.0, 1.8, 0.6, 1.25, 0.4, 0.0);
                self.lens(62.0, 8.0);
                self.shout(a, 1.2, true);
                self.clip(m, a, "ke-kr-chigiri", 0.0, 0.6, 34.0 / 60.0);
                self.sfx("oni-roar", 1.0, 1.0);
                self.sfx("laugh", 0.6, 1.0);
            }
            _ => {}
        }
        if (90..=99).contains(&cf) {
            self.shake(0.03 * (cf - 88) as f32, 0.1);
        }
        match cf {
            100 => {
                self.card(None, None);
                self.impact("red", 8.0);
                self.hold_both(a, v, 8.0);
                self.caption_exit();
                self.clip(m, a, "ke-kr-chigiri", 0.0, 1.0, 40.0 / 60.0);
                self.shot_on(m, v, 90.0, 7.5, 1.5, 1.2, 0.0, 0.0);
                self.lens(55.0, 0.0);
                let q = pos_of(m, v);
                crate::fx::feedback::vfx_ken_bk_burst(&mut self.em(), q[0], q[2], true);
                crate::fx::feedback::vfx_ken_bk_burst(&mut self.em(), q[0], q[2], true);
                vfx_shockwave(&mut self.em(), q[0], q[2], 9.0, PAL_BLOOD);
                vfx_shockwave(&mut self.em(), q[0], q[2], 5.0, PAL_INK);
                self.shatter(m, v, Self::kikon_n(m, a), 1.1, 0.0);
                self.impact_splash_at(m, v, 1.0, 16.0, 0.09);
                for s in ["rift-cut", "explode", "kikon-slash", "konpaku-shatter", "awaken-boom"] {
                    self.sfx(s, 1.0, 1.0);
                }
                self.shake(0.6, 0.6);
            }
            108 => {
                self.clip(m, v, "sh-launch", 1.0, 1.0, 0.0);
                self.shot_pair(m, a, v, 1.0, 10.0, 1.8);
                self.lens(50.0, 0.0);
            }
            130 => self.ken_landed(m, v),
            136 => {
                self.shot_on(m, a, 30.0, 4.4, 0.9, 1.4, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.shout(a, 1.4, true);
                self.sfx("laugh", 0.8, 1.0);
            }
            156 => {
                self.shot_on(m, a, 160.0, 7.0, 1.8, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// The Bankai Kikons' landing (KR's frame 130, ZH's 126, after KE-KK-AT in the sim): the victim down, a dust ring, the crack's
    /// sound, a shake.
    fn ken_landed(&mut self, m: &Match, v: Entity) {
        self.clip(m, v, "sh-down", 2.0, 1.0, 0.0);
        let q = pos_of(m, v);
        vfx_shockwave(&mut self.em(), q[0], q[2], 2.5, PAL_DUST);
        self.sfx("ground-crack", 1.0, 1.0);
        self.shake(0.2, 0.25);
    }

    /// port: ken.lisp KEN-ZH-KIKON-CINE's AT forms and its step-mode chips.
    fn zh_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.cine.aura_off = Some(a);
                self.clip(m, a, "ke-zh-tategoto", 2.0, 0.05, 0.0);
                self.clip(m, v, "sh-kikon-victim", 4.0, 1.0, 0.0);
                self.hold_both(a, v, 12.0);
                self.impact("negative", 1.0);
                self.sfx("whoosh-cleaver", 1.0, 1.0);
            }
            12 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(24.0, BLOOD_RIM);
                self.shot_on(m, a, 60.0, 4.2, 0.7, 1.6, 1.3, 0.8);
                self.lens(46.0, 8.0);
                self.silence(38.0);
                let mut b = self.bcap("盾ごと");
                (b.kanji2, b.reading, b.sub, b.side, b.hanko) = (Some("斬壞"), Some("TATE-GOTO"), Some("ZANKAI"), 0, true);
                self.caption(b);
            }
            36 => {
                self.card(None, None);
                self.shot_on(m, a, 110.0, 3.4, 0.25, 1.8, 0.0, 0.0);
                self.lens(72.0, -6.0);
                self.clip(m, a, "ke-zh-tategoto", 2.0, 11.0 / 14.0, 3.0 / 60.0);
            }
            _ => {}
        }
        if (36..=54).contains(&cf) && cf % 2 == 0 {
            // port: ken.lisp KE-ZH-CHIPS — floor chips floating up round A
            let p = pos_of(m, a);
            let c = &mut self.em();
            for _ in 0..2 {
                let ang = c.rr(0.0, 6.2832);
                let r = c.rr(0.4, 2.2);
                let (x, z) = (p[0] + r * f_cos(ang), p[2] + r * f_sin(ang));
                let vy = c.rr(0.8, 1.6);
                let life = c.rr(0.7, 1.0);
                let size = c.rr(0.06, 0.14);
                t_shard(c, x, 0.1, z, 0.0, vy, 0.0, life, size, 0.6, PAL_DUST);
            }
        }
        match cf {
            50 => self.clip(m, a, "ke-zh-tategoto", 0.0, 1.0, 14.0 / 60.0),
            52 => self.sfx("whoosh-heavy", 0.7, 1.0),
            56 => {
                self.impact("negative", 2.0);
                self.ui_flash(1.0, 1.0, 1.0, 0.7, 12.0);
                self.hold_both(a, v, 6.0);
                self.focus(20.0, None);
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-stagger", 1.0, 1.0, 0.0);
                self.lens(55.0, 0.0);
                self.sfx("kikon-slash", 1.0, 1.0);
                self.sfx("ground-crack", 1.0, 1.0);
                self.sfx("whoosh-cleaver", 0.7, 1.0);
                self.shake(0.45, 0.5);
            }
            62 => self.clip(m, a, "ke-zh-tategoto", 0.0, 13.0 / 34.0, 20.0 / 60.0),
            96 => {
                self.impact("red", 8.0);
                self.hold_both(a, v, 8.0);
                self.caption_exit();
                let l = kk(m);
                crate::fx::feedback::vfx_ken_tategoto_cut(&mut self.em(), l[0], l[1]);
                crate::fx::feedback::vfx_ken_bk_burst(&mut self.em(), l[0], l[1], true);
                self.shatter(m, v, Self::kikon_n(m, a), 1.1, 0.0);
                for s in ["rift-cut", "explode", "kikon-slash", "konpaku-shatter", "cut-heavy"] {
                    self.sfx(s, 1.0, 1.0);
                }
                self.shake(0.6, 0.6);
            }
            104 => {
                self.clip(m, v, "sh-launch", 1.0, 1.0, 0.0);
                self.shot_pair(m, a, v, 1.0, 11.0, 1.6);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ke-zh-tategoto", 2.0, 0.5, 33.0 / 60.0);
            }
            126 => self.ken_landed(m, v),
            140 => {
                self.shot_on(m, a, 40.0, 4.6, 0.9, 1.4, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.shout(a, 1.4, true);
                self.sfx("laugh", 0.8, 1.0);
            }
            160 => {
                self.shot_on(m, a, 160.0, 7.0, 1.8, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// The sealed / Shikai Kikons' frame 0 after CINE-PLACE and KE-KK-LINE (their opening shot at LOOK, DIST away): the stance and the
    /// victim's clip held 12 frames, a negative, the sound.
    fn kikon_open(&mut self, m: &Match, a: Entity, v: Entity, dist: f32, look: f32, stance: &'d str) {
        self.shot_on(m, a, 50.0, dist, 1.0, look, 0.0, 0.0);
        self.lens(50.0, 0.0);
        self.clip(m, a, stance, 2.0, 1.0, 0.0);
        self.clip(m, v, "sh-kikon-victim", 4.0, 1.0, 0.0);
        self.hold_both(a, v, 12.0);
        self.impact("negative", 2.0);
        self.sfx("whoosh-cleaver", 1.0, 1.0);
    }

    /// The white card's caption beat (frame 12 of 鈴, 斬ってみろよ, 回天斬, 墜天斬).
    fn kikon_white_card(&mut self, m: &Match, a: Entity, h: f32, look: f32) {
        self.card(Some(Card::White), Some(a));
        self.shot_on(m, a, 25.0, 3.0, h, look, 0.0, -0.8);
        self.lens(44.0, -10.0);
        self.silence(40.0);
    }

    /// port: ken.lisp KEN-Z-KIKON1-CINE's AT forms and its step-mode dust.
    fn z1_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.shot_on(m, a, 50.0, 3.6, 1.0, 1.1, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.cine.aura_off = Some(a);
                self.clip(m, a, "ke-z-st-1", 2.0, 1.0, 0.0);
                self.clip(m, v, "sh-kikon-victim", 4.0, 1.0, 0.0);
                self.hold_both(a, v, 12.0);
                self.impact("negative", 2.0);
                self.sfx("whoosh-cleaver", 1.0, 1.0);
            }
            12 => {
                self.kikon_white_card(m, a, 0.5, 1.2);
                let mut b = self.bcap("鈴");
                (b.reading, b.sub, b.side, b.ink, b.hanko) = (Some("RIN"), Some("KENPACHI  KIKON"), 1, true, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_pair(m, a, v, 1.0, 7.0, 1.0);
                self.lens(46.0, 0.0);
            }
            62 => {
                ke_z_dust(&mut self.em(), pos_of(m, a), 10);
                self.cine_scale(a, 0.001);
                self.sfx("whoosh-heavy", 1.3, 1.0);
                let p = pos_of(m, a);
                vfx_shockwave(&mut self.em(), p[0], p[2], 1.6, PAL_DUST);
            }
            _ => {}
        }
        if (64..=76).contains(&cf) && cf % 2 == 0 {
            ke_z_dust(&mut self.em(), pos_of(m, a), 2);
        }
        match cf {
            78 => {
                // (KE-KK-AT / KE-KK-YAW of A ran in the sim)
                self.kk_cam(m, 3.4, 1.4, 0.0, 1.3);
                self.lens(50.0, 0.0);
            }
            108 => {
                self.sfx("ken-bells", 1.0, 1.0);
                self.silence(30.0);
            }
            114 => {
                self.cine_scale(a, 1.0);
                self.clip(m, a, "ke-z-st-1", 0.0, 1.0, 0.0);
            }
            122 => {
                self.shot_pair(m, a, v, 1.0, 5.2, 0.6);
                self.lens(50.0, 0.0);
            }
            128 => {
                self.clip(m, a, "ke-z-as1", 2.0, 0.75, 0.0);
                self.sfx("whoosh-cleaver", 0.8, 1.0);
            }
            144 => {
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-launch", 1.0, 1.0, 0.0);
                self.impact("negative", 2.0);
                self.focus(14.0, None);
                self.shatter(m, v, Self::kikon_n(m, a), 1.0, 0.1);
                self.impact_splash_at(m, v, 1.0, 16.0, 0.08);
                self.sfx("kikon-slash", 1.0, 1.0);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.shake(0.35, 0.45);
            }
            146 => self.impact("manga", 12.0),
            172 => {
                // (KE-KK-AT of V ran in the sim)
                self.clip(m, v, "sh-down", 2.0, 1.0, 0.0);
                ke_z_dust(&mut self.em(), pos_of(m, v), 6);
                self.sfx("ground-crack", 1.0, 1.0);
                self.shake(0.15, 0.2);
            }
            174 => {
                self.shot_on(m, a, 30.0, 4.2, 0.9, 1.4, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.shout(a, 1.2, true);
                self.sfx("laugh", 1.0, 1.0);
                self.clip(m, a, "ke-z-st-1", 12.0, 1.0, 0.0);
            }
            186 => {
                self.shot_on(m, a, 160.0, 6.0, 1.6, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: ken.lisp KEN-Z-KIKON2-CINE's AT forms and its step-mode blood.
    fn z2_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.kikon_open(m, a, v, 3.4, 1.2, "ke-z-st-2"),
            12 => {
                self.kikon_white_card(m, a, 0.6, 1.3);
                let mut b = self.bcap("みろよ");
                (b.kanji2, b.reading, b.sub, b.side, b.ink, b.hanko) = (Some("斬って"), Some("KITTE MIRO YO"), Some("KENPACHI  KIKON"), 1, true, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, 50.0, 3.0, 1.1, 1.3, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.clip(m, a, "ke-z-open", 10.0, 1.0, 0.0);
                self.sfx("laugh", 0.7, 1.0);
            }
            74 => {
                self.shot_pair(m, a, v, 1.0, 4.6, 1.2);
                self.lens(50.0, 0.0);
                // the victim's own J1 (his kit's :q command move), its hit on f84
                let kv = duel_sim::fighter::kit_of(m, v);
                if let Some(mv) = duel_sim::kit::kit_command_move(m.data, kv, "q") {
                    let cs = mv.clip_speed;
                    let clip: &'d str = duel_sim::kit::kit_move_clip(kv, &mv.clip);
                    self.clip(m, v, clip, 2.0, cs, max_f32(0.0, mv.s as f32 * cs - 10.0 * cs) / 60.0);
                }
            }
            84 => {
                let p = pos_of(m, a);
                crate::fx::stamps::vfx_hit(&mut self.em(), p[0], p[1] + 1.35, p[2], "heavy", 0.0, -1.0);
                self.flash(a, 0.1);
                ke_z_blood(&mut self.em(), pos_of(m, a), yaw_of(m, a), 12);
                self.impact("negative", 2.0);
                self.sfx("cut-heavy", 1.0, 1.0);
                self.shake(0.2, 0.25);
            }
            _ => {}
        }
        if (86..=104).contains(&cf) && cf % 2 == 0 {
            ke_z_blood(&mut self.em(), pos_of(m, a), yaw_of(m, a), if cf < 94 { 4 } else { 2 });
        }
        match cf {
            92 => {
                self.clip(m, v, "sh-kikon-victim", 8.0, 1.0, 0.0);
                // (KE-KK-AT of V ran in the sim; this SHOT-ON of A reads only A)
                self.shot_on(m, a, 20.0, 1.7, 1.35, 1.4, 0.0, 0.0);
                self.lens(56.0, 0.0);
                self.silence(30.0);
            }
            98 => self.clip(m, a, "ke-z-wound", 10.0, 1.0, 0.0),
            122 => {
                self.shot_on(m, a, 20.0, 1.6, 1.0, 1.8, 0.0, 0.0);
                self.lens(80.0, -8.0);
                self.shout(a, 1.4, true);
                self.sfx("laugh", 1.0, 1.0);
                self.shake(0.12, 0.3);
            }
            140 => {
                self.shot_pair(m, a, v, -1.0, 5.4, 0.8);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ke-z-p2a", 3.0, 0.8, 3.0 / 60.0);
            }
            152 => self.sfx("whoosh-cleaver", 0.7, 1.0),
            156 => {
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-crumple", 1.0, 1.0, 0.0);
                self.impact("negative", 2.0);
                self.focus(14.0, None);
                let q = pos_of(m, v);
                crate::fx::crack::crack_add(&mut self.em(), q[0], q[2], 1.4);
                crate::fx::crack::stage_debris(&mut self.em(), q[0], q[2], 6, 1.0);
                vfx_shockwave(&mut self.em(), q[0], q[2], 4.0, PAL_DUST);
                self.shatter(m, v, Self::kikon_n(m, a), 0.8, 0.1);
                self.impact_splash_at(m, v, 0.8, 16.0, 0.08);
                for s in ["kikon-slash", "ground-crack", "konpaku-shatter"] {
                    self.sfx(s, 1.0, 1.0);
                }
                self.shake(0.45, 0.5);
            }
            158 => self.impact("manga", 12.0),
            176 => {
                self.shot_on(m, a, 35.0, 4.2, 0.9, 1.4, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.shout(a, 1.2, true);
                self.sfx("laugh", 0.8, 1.0);
                self.clip(m, a, "ke-z-st-2", 14.0, 1.0, 0.0);
            }
            192 => {
                self.shot_on(m, a, 160.0, 6.0, 1.6, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: ken.lisp KEN-Z-KIKON3-CINE's AT forms (its two AT 122 in script order).
    fn z3_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.kikon_open(m, a, v, 3.6, 1.2, "ke-z-st-3"),
            12 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(40.0, [0.91, 0.93, 0.96]);
                self.shot_on(m, a, 60.0, 4.2, 0.7, 1.5, 1.0, 0.8);
                self.lens(46.0, 8.0);
                self.silence(40.0);
                let mut b = self.bcap("両断");
                (b.reading, b.sub, b.side, b.hanko) = (Some("RYODAN"), Some("KENPACHI  KIKON"), 0, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, 70.0, 1.6, 1.4, 1.4, 0.6, 0.0);
                self.lens(60.0, 0.0);
                self.clip(m, a, "ke-z-tame", 6.0, 0.45, 0.0);
            }
            78 => {
                self.shot_on(m, a, -80.0, 3.4, 0.4, 1.8, 0.0, 0.0);
                self.lens(52.0, 0.0);
                self.clip(m, a, "ke-z-men", 10.0, 0.3, 6.0 / 60.0);
                self.sfx("awaken-rise", 0.6, 1.0);
            }
            98 => {
                self.clip(m, a, "ke-z-men", 4.0, 0.01, 12.0 / 60.0);
                self.silence(22.0);
            }
            120 => {
                self.clip(m, a, "ke-z-men", 0.0, 1.0, 12.0 / 60.0);
                self.sfx("whoosh-cleaver", 0.8, 1.0);
            }
            122 => {
                self.impact("negative", 2.0);
                self.ui_flash(1.0, 1.0, 1.0, 0.5, 12.0);
                self.hold_both(a, v, 4.0);
                self.focus(20.0, None);
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-stagger", 1.0, 1.0, 0.0);
                self.shatter(m, v, Self::kikon_n(m, a), 1.1, 0.0);
                self.impact_splash_at(m, v, 1.0, 16.0, 0.08);
                for s in ["kikon-slash", "ground-crack", "rift-cut", "konpaku-shatter"] {
                    self.sfx(s, 1.0, 1.0);
                }
                self.shake(0.5, 0.55);
                self.kk_cam(m, 10.0, 5.6, -6.0, 1.0);
                self.lens(55.0, 0.0);
            }
            146 => {
                self.kk_cam(m, -5.5, 1.4, 3.0, 1.6);
                self.clip(m, v, "sh-crumple", 3.0, 1.0, 0.0);
            }
            168 => {
                self.shot_on(m, a, 30.0, 4.4, 1.0, 1.4, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.clip(m, a, "ke-z-st-3", 16.0, 1.0, 0.0);
                self.sfx("laugh", 0.9, 1.0);
            }
            188 => {
                self.shot_on(m, a, 160.0, 6.0, 1.6, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: ken-look.lisp KEN-S-KIKON1-CINE's AT forms.
    fn s1_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.kikon_open(m, a, v, 3.6, 1.1, "ke-s-st-1"),
            12 => {
                self.kikon_white_card(m, a, 0.5, 1.2);
                let mut b = self.bcap("回天斬");
                (b.reading, b.sub, b.side, b.ink, b.hanko) = (Some("KAITENZAN"), Some("KENPACHI  KIKON"), 1, true, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_pair(m, a, v, 1.0, 7.0, 1.0);
                self.lens(46.0, 0.0);
                self.clip(m, a, "ke-s-p1a", 4.0, 0.5, 0.0);
                self.sfx("awaken-rise", 0.6, 1.0);
            }
            76 => {
                self.clip(m, a, "ke-s-issen", 0.0, 1.0, 8.0 / 60.0);
                self.sfx("whoosh-cleaver", 1.0, 1.0);
            }
            82 => {
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-stagger", 2.0, 1.0, 0.0);
                self.impact("negative", 2.0);
                self.shake(0.2, 0.3);
            }
            90 => {
                self.shot_on(m, v, 170.0, 5.5, 1.3, 1.1, -1.5, 0.0);
                self.lens(50.0, 0.0);
            }
            98 => {
                // (FACE-EACH-OTHER ran in the sim)
                self.clip(m, a, "ke-s-wheel", 2.0, 1.0, 6.0 / 60.0);
                self.sfx("whoosh-cleaver", 0.8, 1.0);
                self.shot_pair(m, a, v, -1.0, 7.5, 1.4);
                self.lens(46.0, 0.0);
            }
            104 => {
                self.slash(m, v, "heavy");
                self.sfx("cut-heavy", 1.0, 1.0);
            }
            112 => {
                self.impact("negative", 2.0);
                self.clip(m, v, "sh-crumple", 3.0, 1.0, 0.0);
                self.shatter(m, v, Self::kikon_n(m, a), 1.0, 0.1);
                self.impact_splash_at(m, v, 0.0, 16.0, 0.07);
                self.sfx("kikon-slash", 1.0, 1.0);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.shake(0.35, 0.45);
            }
            114 => self.impact("manga", 12.0),
            124 => {
                self.sfx("laugh", 1.0, 1.0);
                self.clip(m, a, "ke-s-st-1", 10.0, 1.0, 0.0);
            }
            138 => {
                self.shot_on(m, a, 160.0, 6.0, 1.6, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: ken-look.lisp KEN-S-KIKON2-CINE's AT forms (each frame's forms in script order; the script lists 122 after 165).
    fn s2_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.kikon_open(m, a, v, 3.4, 1.2, "ke-s-st-2"),
            12 => {
                self.kikon_white_card(m, a, 0.6, 1.3);
                let mut b = self.bcap("墜天斬");
                (b.reading, b.sub, b.side, b.ink, b.hanko) = (Some("TSUITENZAN"), Some("KENPACHI  KIKON"), 1, true, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, 70.0, 3.4, 0.7, 1.2, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.clip(m, a, "ke-s-flick", 3.0, 0.4, 0.0);
            }
            77 => {
                self.slash(m, v, "heavy");
                self.clip(m, v, "sh-launch", 2.0, 1.0, 0.0);
                self.impact("negative", 2.0);
                self.sfx("cut-heavy", 1.0, 1.0);
                self.shake(0.25, 0.3);
            }
            79 => self.lens(50.0, 0.0),
            102 => self.clip(m, a, "ke-s-meteor", 6.0, 0.3, 0.0),
            150 => self.clip(m, a, "ke-s-meteor", 4.0, 0.25, 13.0 / 60.0),
            165 => {
                self.clip(m, a, "ke-s-meteor", 0.0, 1.0, 17.0 / 60.0);
                self.lens(62.0, 10.0);
                self.sfx("whoosh-cleaver", 0.8, 1.0);
            }
            122 => {
                self.sfx("whoosh-heavy", 0.7, 1.0);
                self.lens(46.0, 0.0);
            }
            152 => {
                self.lens(52.0, 6.0);
                self.sfx("awaken-rise", 0.7, 1.0);
            }
            168 => {
                self.slash(m, v, "heavy");
                self.impact("negative", 3.0);
                self.focus(24.0, None);
                self.cine_slow(0.0);
                self.sfx("kikon-slash", 1.0, 1.0);
                self.sfx("cut-heavy", 1.0, 1.0);
                self.sfx("explode", 0.7, 1.0);
                self.shake(0.55, 0.6);
                self.lens(40.0, 0.0);
            }
            174 => self.cine_slow(0.25),
            196 => {
                self.cine_slow(1.0);
                self.lens(44.0, 0.0);
                self.clip(m, a, "ke-s-meteor", 4.0, 0.5, 24.0 / 60.0);
            }
            228 => {
                self.clip(m, v, "sh-down", 2.0, 1.0, 0.0);
                self.clip(m, a, "ke-s-meteor", 2.0, 1.0, 38.0 / 60.0);
                let (q, l) = (pos_of(m, v), kk(m));
                // port: ken-look.lisp KE-METEOR-IMPACT
                crate::fx::crack::crack_add(&mut self.em(), q[0], q[2], 2.4);
                vfx_shockwave(&mut self.em(), q[0], q[2], 4.5, PAL_REIATSU);
                crate::fx::crack::stage_debris(&mut self.em(), q[0], q[2], 10, 1.2);
                self.shake(0.35, 0.45);
                for sd in [2.4f32, -2.4] {
                    let x = (l[0] + -0.6 * l[2]) + sd * l[3];
                    let z = (l[1] + -0.6 * l[3]) + sd * -l[2];
                    crate::fx::crack::crack_add(&mut self.em(), x, z, 1.4);
                    crate::fx::crack::stage_debris(&mut self.em(), x, z, 6, 1.0);
                }
                self.shatter(m, v, Self::kikon_n(m, a), 0.4, 0.1);
                self.impact_splash_at(m, v, 0.0, 16.0, 0.08);
                self.sfx("ground-crack", 1.0, 1.0);
                self.sfx("explode", 0.5, 1.0);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.shake(0.5, 0.7);
            }
            230 => self.impact("manga", 12.0),
            246 => {
                self.sfx("laugh", 1.0, 1.0);
                self.clip(m, a, "ke-s-st-2", 12.0, 1.0, 0.0);
            }
            260 => {
                self.shot_on(m, a, 150.0, 6.5, 1.8, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    // ------------------------------------------------------------ the UI-space looks

    /// port: ken.lisp KEN-FOREST — the Kusajishi forest on the white card (UI space, the cine clock CF): ink trunks with a branch each,
    /// petals re-drawn every drawing, Yachiru for two drawings.
    fn ken_forest(&self, cf: i64, ui: &mut Vec<f32>) {
        const TRUNKS: [(f32, f32); 6] = [(0.03, 0.05), (0.1, 0.022), (0.62, 0.04), (0.71, 0.018), (0.8, 0.06), (0.93, 0.03)];
        let (w, h) = (self.inputs.width as f32, self.inputs.height as f32);
        let paper = [0.96, 0.96, 0.94, 1.0];
        let dr = cf.div_euclid(2);
        for (i, (fx, fw)) in TRUNKS.into_iter().enumerate() {
            let (x, tw) = (fx * w, fw * w);
            let lean = (if i % 2 == 0 { 0.02 } else { -0.015 }) * w;
            ui_poly4(ui, x + lean, 0.0, (x + lean) + tw, 0.0, x + 1.2 * tw, h, x - 0.2 * tw, h, INK, INK);
            let by = h * (0.18 + 0.11 * (i % 3) as f32);
            let dir = if i % 2 == 0 { 1.0 } else { -1.0 };
            let bx = x + 0.5 * tw;
            ui_poly4(ui, bx, by, bx + (dir * 0.09) * w, by - 0.07 * h, bx + (dir * 0.09) * w, by - 0.06 * h, bx, by + 0.02 * h, INK, INK);
        }
        for k in 0..18i64 {
            let px = w * mod_f32((k as f32 * 0.137 + 0.003 * dr as f32) + 0.01 * f_sin((k + dr) as f32), 1.0);
            let py = h * mod_f32(k as f32 * 0.071 + 0.012 * dr as f32, 1.0);
            let r = 0.006 * h;
            ui_poly4(ui, px, py - r, px + r, py, px, py + r, px - r, py, paper, paper);
            ui_rect_outline(ui, px - r, py - r, 2.0 * r, 2.0 * r, INK, 1.0);
        }
        if (24..=31).contains(&cf) {
            let (cx, base, u) = (0.52 * w, 0.8 * h, 0.05 * h);
            let j = if cf < 28 { 0.0 } else { 0.08 * u };
            ui_poly4(ui, cx - 0.35 * u, base - 1.3 * u, cx + 0.35 * u, base - 1.3 * u, cx + 0.6 * u, base, cx - 0.6 * u, base, INK, INK);
            for k in 0..8 {
                let (a0, a1) = (k as f32 * 0.785, (k + 1) as f32 * 0.785);
                let (hx, hy, r) = (cx, (base - 1.75 * u) - j, 0.42 * u);
                ui_poly4(ui, hx, hy, hx + r * f_cos(a0), hy + r * f_sin(a0), hx + r * f_cos(a1), hy + r * f_sin(a1), hx, hy, INK, INK);
            }
            ui_poly4(ui, cx + 0.2 * u, (base - 2.1 * u) - j, cx + 0.55 * u, (base - 2.35 * u) - j, cx + 0.5 * u, (base - 1.95 * u) - j, cx + 0.3 * u, (base - 1.9 * u) - j, INK, INK);
        }
    }

    /// port: ken.lisp KE-GLASS — 狂嵐's Kikon burst in UI space: AGE < 8 the screen cracked from its centre (rays and rings in ink with
    /// a white core); then the pieces fly out and fall, gone by 40.
    fn ke_glass(&self, age: i64, ui: &mut Vec<f32>) {
        let (w, h) = (self.inputs.width as f32, self.inputs.height as f32);
        let us = self.ui();
        const N: i64 = 14;
        let rings = [0.0f32, 0.11, 0.27, 0.8];
        let wh_max = max_f32(w, h);
        let pt = |i: i64, k: usize| -> (f32, f32) {
            let i = i.rem_euclid(N);
            let a = i as f32 * (6.2832 / N as f32) + 0.32 * (hash01(i as f32, 3.3) - 0.5);
            let r = (wh_max * rings[k]) * (1.0 + 0.3 * (hash01(i as f32, (11 + k) as f32) - 0.5));
            (0.5 * w + r * f_cos(a), 0.45 * h + r * f_sin(a))
        };
        if age < 8 {
            let wh = [1.0, 1.0, 0.97, 1.0];
            for i in 0..N {
                for k in 0..3 {
                    let (x0, y0) = pt(i, k);
                    let (x1, y1) = pt(i, k + 1);
                    ui_seg(ui, x0, y0, x1, y1, us * 7.0, INK);
                    ui_seg(ui, x0, y0, x1, y1, us * 2.5, wh);
                    if k > 0 {
                        let (x1, y1) = pt(i + 1, k);
                        ui_seg(ui, x0, y0, x1, y1, us * 6.0, INK);
                        ui_seg(ui, x0, y0, x1, y1, us * 2.0, wh);
                    }
                }
            }
        } else {
            let u = min_f32(1.0, (age - 8) as f32 / 32.0);
            let tt = (age - 8) as f32 / 60.0;
            let o = 1.0 - u;
            if u < 1.0 {
                let (ink, wh, glaze) = ([0.03, 0.03, 0.047, o], [1.0, 1.0, 0.97, o], [1.0, 1.0, 1.0, 0.3 * o]);
                for i in 0..N {
                    for k in 0..3 {
                        let (ax, ay) = pt(i, k);
                        let (bx, by) = pt(i + 1, k);
                        let (cx, cy) = pt(i + 1, k + 1);
                        let (dx, dy) = pt(i, k + 1);
                        let (mx, my) = (0.25 * (((ax + bx) + cx) + dx), 0.25 * (((ay + by) + cy) + dy));
                        let (ox, oy) = (mx - 0.5 * w, my - 0.45 * h);
                        let ol = max_f32(1.0, f_sqrt(ox * ox + oy * oy));
                        let sp = wh_max * (0.35 + 0.4 * hash01(i as f32, (21 + k) as f32));
                        let tx = (sp * tt) * (ox / ol);
                        let ty = (sp * tt) * (oy / ol) + ((1.4 * h) * tt) * tt;
                        let s = 1.0 - 0.35 * u;
                        let px = |x: f32| (mx + tx) + s * (x - mx);
                        let py = |y: f32| (my + ty) + s * (y - my);
                        ui_poly4(ui, px(ax), py(ay), px(bx), py(by), px(cx), py(cy), px(dx), py(dy), glaze, glaze);
                        ui_seg(ui, px(ax), py(ay), px(bx), py(by), us * 5.0, ink);
                        ui_seg(ui, px(bx), py(by), px(cx), py(cy), us * 5.0, ink);
                        ui_seg(ui, px(cx), py(cy), px(dx), py(dy), us * 5.0, ink);
                        ui_seg(ui, px(dx), py(dy), px(ax), py(ay), us * 5.0, ink);
                        ui_seg(ui, px(ax), py(ay), px(dx), py(dy), us * 1.5, wh);
                    }
                }
            }
        }
    }

    /// port: ken.lisp KE-RIFT-BAND — 斬壞's Kikon rift in UI space through ground point (x z), AGE frames after the chop: held and
    /// trembling until CUT, then the white flare narrowing while the screen halves shear (`*grade-split*`), then the ink scar.
    fn ke_rift_band(&mut self, x: f32, z: f32, age: i64, cut: i64, ui: &mut Vec<f32>) {
        let (w, h) = (self.inputs.width as f32, self.inputs.height as f32);
        let us = self.ui();
        let dr = drawing_no(self.draw.post.fx_clock, 12.0);
        let sx = self.world_to_screen(x, 1.0, z).map_or(0.5 * w, |s| s[0]);
        let v = age - cut;
        self.draw.post.grade_split =
            if -1 < v && v < 18 { (0.04 * h) * max_f32(0.0, min_f32(min_f32(1.0, (v + 1) as f32 / 2.0), (18 - v) as f32 / 4.0)) } else { 0.0 };
        if v < 0 {
            let bw = us * ((11.0 + 4.0 * hash01(dr, 9.0)) + 10.0 * (age as f32 / cut as f32));
            let cx = sx + (us * 4.0) * (hash01(dr, 5.0) - 0.5);
            ui_rect(ui, (cx - 0.5 * bw) - 2.5 * us, 0.0, bw + 5.0 * us, h, INK);
            ui_rect(ui, cx - 0.5 * bw, 0.0, bw, h, [0.816, 0.063, 0.11, 1.0]);
            ui_rect(ui, cx - 0.15 * bw, 0.0, 0.3 * bw, h, [1.0, 1.0, 0.97, 1.0]);
        } else if v < 10 {
            let bw = us * (8.0 + 90.0 * (1.0 - v as f32 / 10.0));
            ui_rect(ui, (sx - 0.5 * bw) - 4.0 * us, 0.0, bw + 8.0 * us, h, INK);
            ui_rect(ui, sx - 0.5 * bw, 0.0, bw, h, [1.0, 1.0, 0.97, 1.0]);
        } else if v < 50 {
            ui_rect(ui, sx - 2.0 * us, 0.0, 4.0 * us, h, [0.03, 0.03, 0.047, 1.0 - (v - 10) as f32 / 40.0]);
        }
    }

    /// port: vfx.lisp VFX-SKY-SPLIT — a vertical line of light across the screen through ground (x z) (UI space), the ground split 16 m
    /// along YAW (a :meteor line cut), and the screen halves sheared for the first 0.2 s (`*grade-split*`).
    fn vfx_sky_split(&mut self, x: f32, z: f32, yaw: f32, age: f32, life: f32, out: &mut FrameOut) {
        let v = min_f32(1.0, age / max_f32(life, 0.01));
        let fade = 1.0 - (v * v) * v;
        let (fx, fz) = (-f_sin(yaw), -f_cos(yaw));
        let w = self.inputs.width as f32;
        let sx = self.world_to_screen(x, 1.0, z).map_or(0.5 * w, |s| s[0]);
        let h = self.inputs.height as f32;
        let us = self.ui();
        let wide = us * (3.0 + 40.0 * max_f32(0.0, 1.0 - age / 0.12));
        crate::fx::hazard::vfx_line_cut(&mut self.ctx(out), x - 8.0 * fx, z - 8.0 * fz, x + 8.0 * fx, z + 8.0 * fz, age, life, "meteor", 0.0);
        self.draw.post.grade_split = (0.035 * h) * max_f32(0.0, min_f32(min_f32(1.0, age / 0.03), (0.2 - age) / 0.05));
        let iw = wide + us * 5.0;
        ui_rect(&mut out.ui, sx - 0.5 * iw, 0.0, iw, h, [0.03, 0.03, 0.047, fade]);
        ui_rect(&mut out.ui, sx - 0.5 * wide, 0.0, wide, h, [1.0, 1.0, 0.97, fade]);
    }
}

/// port: ken.lisp KE-UI-SEG — a UI stroke from (x0 y0) to (x1 y1), W px wide, colour C.
#[allow(clippy::too_many_arguments)]
fn ui_seg(ui: &mut Vec<f32>, x0: f32, y0: f32, x1: f32, y1: f32, w: f32, c: [f32; 4]) {
    let (dx, dy) = (x1 - x0, y1 - y0);
    let l = max_f32(0.001, f_sqrt(dx * dx + dy * dy));
    let (nx, ny) = ((0.5 * w) * (-dy / l), (0.5 * w) * (dx / l));
    ui_poly4(ui, x0 + nx, y0 + ny, x1 + nx, y1 + ny, x1 - nx, y1 - ny, x0 - nx, y0 - ny, c, c);
}

/// port: ken.lisp KE-Z-DUST — N dust puffs kicked out round the feet P.
fn ke_z_dust(c: &mut Em, p: [f32; 3], n: usize) {
    for _ in 0..n {
        let ang = c.rr(0.0, 6.2832);
        let sp = c.rr(0.8, 2.2);
        let x = p[0] + c.rr(-0.3, 0.3);
        let z = p[2] + c.rr(-0.3, 0.3);
        let vy = c.rr(0.2, 0.9);
        let life = c.rr(0.6, 1.1);
        let size = c.rr(0.18, 0.32);
        t_blob(c, x, 0.15, z, sp * f_cos(ang), vy, sp * f_sin(ang), life, size, -0.2, 0.4, PAL_DUST);
    }
}

/// port: ken.lisp KE-Z-BLOOD — N drops of blood out of the chest of a fighter at P facing YAW, forward and up.
fn ke_z_blood(c: &mut Em, p: [f32; 3], yaw: f32, n: usize) {
    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
    for _ in 0..n {
        let sp = c.rr(1.5, 3.5);
        let vx = sp * (fx + c.rr(-0.5, 0.5));
        let vy = c.rr(0.5, 2.5);
        let vz = sp * (fz + c.rr(-0.5, 0.5));
        let life = c.rr(0.4, 0.7);
        let size = c.rr(0.03, 0.07);
        t_blob(c, p[0] + 0.25 * fx, 1.35, p[2] + 0.25 * fz, vx, vy, vz, life, size, 9.0, 0.3, PAL_BLOOD);
    }
}

/// port: ken-look.lisp KE-KK-STREAK — a white and yellow streak along the Kikon line L from S0 to S1 at 1 m, presence K.
fn ke_kk_streak(c: &mut Ctx, l: [f32; 4], s0: f32, s1: f32, k: f32) {
    let (x0, z0, x1, z1) = (l[0] + s0 * l[2], l[1] + s0 * l[3], l[0] + s1 * l[2], l[1] + s1 * l[3]);
    fx_line(c, [x0, 1.0, z0], [x1, 1.0, z1], 0.02, 1.0, 0.86, 0.45, 0.6 * k, Mode::Add, 0.22, 0.6 * k);
    fx_line(c, [x0, 1.0, z0], [x1, 1.0, z1], 0.01, 1.0, 0.97, 0.9, k, Mode::Add, 0.08, k);
}

/// port: ken-look.lisp KE-KK-CUT — TSUITENZAN's cut: the arc in the line L's vertical plane, OFF metres to the side, DROP down,
/// presence K; a white core over a yellow body.
fn ke_kk_cut(c: &mut Ctx, l: [f32; 4], k: f32, off: f32, drop: f32, seed: f32) {
    let (ox, oz) = (off * l[3], off * -l[2]);
    let y1 = max_f32(0.05, 0.1 - drop);
    let (x0, z0) = ((l[0] + 1.4 * l[2]) + ox, (l[1] + 1.4 * l[3]) + oz);
    let (x1, z1) = ((l[0] + -1.2 * l[2]) + ox, (l[1] + -1.2 * l[3]) + oz);
    let (bx, bz) = ((l[0] + -0.4 * l[2]) + ox, (l[1] + -0.4 * l[3]) + oz);
    fx_crescent(c, [x0, 8.0 - drop, z0], [x1, y1, z1], [bx, 6.4 - drop, bz], 0.55 * k, false, 0.06, seed, PAL_GOLD, k, 0.2);
    fx_crescent(c, [x0, 8.0 - drop, z0], [x1, y1, z1], [bx, 6.4 - drop, bz], 0.25 * k, false, 0.05, seed + 7.0, PAL_HIT, k, 0.3);
}

/// port: ken-look.lisp KE-KK-TAIL — a yellow-white tail 3 m up from the head of a fighter at P, presence K.
fn ke_kk_tail(c: &mut Ctx, p: [f32; 3], k: f32) {
    let (x, y, z) = (p[0], p[1] + 1.8, p[2]);
    fx_line(c, [x, y + 3.0, z], [x, y, z], 0.02, 1.0, 0.86, 0.45, 0.7 * k, Mode::Add, 0.5, 0.7 * k);
    fx_line(c, [x, y + 3.0, z], [x, y, z], 0.01, 1.0, 0.97, 0.85, k, Mode::Add, 0.2, k);
}

/// port: render.lisp FX-BILLBOARD with :mode :add and no :rot — a camera-facing soft round sprite of radius S at (x y z).
#[allow(clippy::too_many_arguments)]
fn fx_billboard(c: &mut Ctx, x: f32, y: f32, z: f32, s: f32, r: f32, g: f32, b: f32, a: f32) {
    let (rt, up) = (c.cam.right, c.cam.upv);
    let (cs, sn) = (f_cos(0.0), f_sin(0.0));
    let (rx, ry, rz) = (s * (cs * rt[0] - sn * up[0]), s * (cs * rt[1] - sn * up[1]), s * (cs * rt[2] - sn * up[2]));
    let (ux, uy, uz) = (s * (sn * rt[0] + cs * up[0]), s * (sn * rt[1] + cs * up[1]), s * (sn * rt[2] + cs * up[2]));
    if let Some(v) = c.verts(Mode::Add, 6) {
        crate::fx::bb_verts(v, x, y, z, rx, ry, rz, ux, uy, uz, r, g, b, a);
    }
}

/// port: vfx.lisp VFX-AWAKEN-BURST for Kenpachi's kinds: :nozarashi (ONI false: the yellow reiatsu pillar, the :land stamp) and :oni
/// (the BLOOD pillar over INK flames), at the feet (x y z).
fn vfx_awaken_burst(c: &mut Em, x: f32, y: f32, z: f32, oni: bool) {
    #[allow(clippy::too_many_arguments)]
    fn blobs(c: &mut Em, x: f32, y: f32, z: f32, n: usize, xz: f32, yr: f32, vxz: f32, vy: [f32; 2], life: [f32; 2], size: [f32; 2], pal: f32) {
        for _ in 0..n {
            let px = x + c.rr(-xz, xz);
            let py = y + c.rr(0.0, yr);
            let pz = z + c.rr(-xz, xz);
            let vx = c.rr(-vxz, vxz);
            let vyy = c.rr(vy[0], vy[1]);
            let vz = c.rr(-vxz, vxz);
            let l = c.rr(life[0], life[1]);
            let s = c.rr(size[0], size[1]);
            t_blob(c, px, py, pz, vx, vyy, vz, l, s, 0.0, 0.3, pal);
        }
    }
    if oni {
        blobs(c, x, y, z, 28, 0.35, 1.0, 0.3, [10.0, 20.0], [0.35, 0.6], [0.3, 0.5], PAL_BLOOD);
        blobs(c, x, y, z, 14, 0.5, 0.6, 0.4, [6.0, 12.0], [0.4, 0.7], [0.35, 0.55], PAL_INK);
        flash_light(c, x, y + 1.0, z, 1.0, 0.15, 0.12);
    } else {
        blobs(c, x, y, z, 28, 0.35, 1.0, 0.3, [10.0, 20.0], [0.35, 0.6], [0.3, 0.5], PAL_REIATSU);
        stamp(c, Kind::Land, x, y, z, 0.0, 0.0, -1.0, 2.4, 0.0);
        flash_light(c, x, y + 1.0, z, 1.0, 0.85, 0.3);
    }
}

/// port: vfx.lisp VFX-SKULL — the skull in the Nozarashi pillar, drawn in the screen plane at (x y z), re-drawn on twos; K presence.
fn vfx_skull(c: &mut Ctx, x: f32, y: f32, z: f32, k: f32) {
    let dr = drawing_no(c.clock, 12.0);
    let sd = ((dr as i32) % 5) as f32;
    let (rt, up) = (c.cam.right, c.cam.upv);
    let at = |px: f32, py: f32| [(x + px * rt[0]) + py * up[0], (y + px * rt[1]) + py * up[1], (z + px * rt[2]) + py * up[2]];
    let p = at(0.0, 0.08);
    fx_disc(c, p[0], p[1], p[2], 0.56, 0.06, 70.0 + sd, PAL_INK, k, 0.1);
    let p = at(0.0, -0.42);
    fx_star(c, p[0], p[1], p[2], 0.36, 0.3, 6, 0.52, 0.0, 0.0, 0.05, 71.0 + sd, PAL_INK, k, 0.12);
    let p = at(-0.21, 0.04);
    fx_disc(c, p[0], p[1], p[2], 0.15, 0.1, 72.0 + sd, PAL_REIATSU, k, 0.2);
    let p = at(0.21, 0.04);
    fx_disc(c, p[0], p[1], p[2], 0.15, 0.1, 73.0 + sd, PAL_REIATSU, k, 0.2);
    let p = at(0.0, -0.2);
    fx_star(c, p[0], p[1], p[2], 0.08, 0.06, 3, 3.1416, 0.0, 0.0, 0.05, 74.0 + sd, PAL_REIATSU, k, 0.2);
    for i in 0..6 {
        let f = i as f32;
        let px = 0.09 * (f - 2.5);
        let p = at(px, -0.4);
        fx_shard(c, p[0], p[1], p[2], -up[0], -up[1], -up[2], if i == 0 || i == 5 { 0.16 } else { 0.11 }, 0.03, 0.05, f + dr, PAL_HIT, k, 0.22);
    }
}
