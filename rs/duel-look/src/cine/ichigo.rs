//! port: Ichigo's cinematics' looks (ichigo-look.lisp): the AT and DURING look forms of his eight DEFCINEs and the looks they call (the
//! Cero's orb, thread, hook, flame and ring; the phantom charges; the black C; the split; the blood chains). The forms that move an actor
//! (FACE-EACH-OTHER, 血鎖's reel-in) are `duel_sim::ichigo::cine`; these run after them (ruling R9).
use super::{during, Card};
use crate::draw::FrameOut;
use crate::fx::shapes::{fx_line, PAL_ASH, PAL_INK, PAL_REIATSU};
use crate::fx::stamps::vfx_shockwave;
use crate::fx::vfx::t_blob;
use crate::fx::{Ctx, Mode};
use crate::rig::{body_weapon_point, joint_index, joint_point};
use crate::scene::Scene;
use duel_sim::cl::{max_f32, min_f32};
use duel_sim::ecs::Entity;
use duel_sim::fighter::{pos_of, yaw_of};
use duel_sim::ichigo::cine::IcCine;
use duel_sim::math::{deg, dir_yaw, f_abs, f_cos, f_sin, fwd_x, fwd_z, hypot};
use duel_sim::state::Match;

const BLOOD_RIM: [f32; 3] = [0.82, 0.06, 0.11];
/// ichigo-look.lisp +IC-GOLD+, +IC-VIOLET+, +IC-CERO-CORE+.
const GOLD: [f32; 3] = [1.0, 0.76, 0.23];
const VIOLET: [f32; 3] = [0.75, 0.25, 0.91];
const CERO_CORE: [f32; 3] = [0.35, 0.04, 0.06];

/// FX-LINE with its keyword defaults (:mode :add, end width and alpha the start's).
fn line(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], w: f32, rgb: [f32; 3], a: f32) {
    fx_line(c, p0, p1, w, rgb[0], rgb[1], rgb[2], a, Mode::Add, w, a);
}

/// FX-LINE :mode :alpha.
fn line_a(c: &mut Ctx, p0: [f32; 3], p1: [f32; 3], w: f32, rgb: [f32; 3], a: f32) {
    fx_line(c, p0, p1, w, rgb[0], rgb[1], rgb[2], a, Mode::Alpha, w, a);
}

/// port: ichigo-look.lisp IC-LINE-FROM — A's feet, the unit vector to V, the distance (at least 0.5 m).
fn line_from(m: &Match, a: Entity, v: Entity) -> (f32, f32, f32, f32, f32) {
    let (p, q) = (pos_of(m, a), pos_of(m, v));
    let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
    let d = max_f32(0.5, hypot(dx, dz));
    (p[0], p[2], dx / d, dz / d, d)
}

impl<'d> Scene<'d> {
    /// port: ichigo-look.lisp IC-JOINT — the world point of E's joint J at the local offset L (its last drawn joints).
    fn ic_joint(&self, e: Entity, j: usize, l: [f32; 3]) -> [f32; 3] {
        self.model(e).map_or([0.0; 3], |md| joint_point(&md.joints[j], l))
    }

    /// port: ichigo-look.lisp IC-BLADE — E's held blade's base and tip (BODY-WEAPON-BASE / -TIP of its model's weapon, or WEAPON).
    fn ic_blade(&self, e: Entity, weapon: Option<&str>) -> ([f32; 3], [f32; 3]) {
        let Some(md) = self.model(e) else { return ([0.0; 3], [0.0; 3]) };
        let wd = &self.data.weapons[weapon.unwrap_or(md.weapon)];
        (body_weapon_point(&md.joints, wd.base), body_weapon_point(&md.joints, wd.len))
    }

    /// `(setf (model-hide (model e)) (hide-set TAGS))` for a set no kit lists (`Model.hide_x`).
    fn hide_set(&mut self, e: Entity, tags: &'static [&'static str]) {
        if let Some(md) = self.md_mut(e) {
            (md.hide, md.hide_x) = (&[], tags);
        }
    }

    /// Ichigo's scripts' step-mode look forms at frame CF.
    pub(crate) fn ichigo_at(&mut self, m: &Match, k: IcCine, cf: i64, a: Entity, v: Entity) {
        match k {
            IcCine::Kikon => self.ic_kikon_at(m, cf, a, v),
            IcCine::KessaKikon => self.ic_kessa_kikon_at(m, cf, a, v),
            IcCine::Haste => self.ic_haste_at(m, cf, a, v),
            IcCine::KessaGetsuga => self.ic_getsuga_at(m, cf, a, v),
            IcCine::HeavyKikon => self.ic_heavy_at(m, cf, a, v),
            IcCine::RushKikon => self.ic_rush_at(m, cf, a, v),
            IcCine::ChainKikon => self.ic_chain_at(m, cf, a, v),
            IcCine::Kessa => self.ic_kessa_at(m, cf, a, v),
        }
    }

    /// The Kikons' frame 0 after FACE-EACH-OTHER: the opening shot (60 deg, DIST, 1.1 high), the strike and the victim's clip held 12
    /// frames, a negative, the sound.
    #[allow(clippy::too_many_arguments)]
    fn ic_open(&mut self, m: &Match, a: Entity, v: Entity, dist: f32, clip: &'d str, time: f32, sfx: &'static str, pitch: f32) {
        self.shot_on(m, a, 60.0, dist, 1.1, 1.1, 0.0, 0.0);
        self.lens(50.0, 0.0);
        self.clip(m, a, clip, 2.0, 1.0, time);
        self.clip(m, v, "sh-kikon-victim", 4.0, 1.0, 0.0);
        self.hold_both(a, v, 12.0);
        self.impact("negative", 2.0);
        self.sfx(sfx, pitch, 1.0);
    }

    /// The impact beat on V (the Kikon's 160, the Getsuga's 140): the Konpaku of N souls and a heavy hit at his chest, the splash.
    fn ic_hit(&mut self, m: &Match, v: Entity, n: i64, splash: f32) {
        let p = pos_of(m, v);
        let (x, y, z) = (p[0], p[1] + 1.0, p[2]);
        crate::fx::stamps::vfx_konpaku_shatter(&mut self.em(), x, y + 0.1, z, n.max(0) as usize);
        crate::fx::stamps::vfx_hit(&mut self.em(), x, y + 0.3, z, "heavy", 0.0, -1.0);
        self.impact_splash_at(m, v, 0.0, 14.0, splash);
    }

    /// The black-card ending of 千影, 超速連斬 and 連斬 (after FACE-EACH-OTHER 3.2): behind Ichigo, the victim collapsed, the stamp.
    #[allow(clippy::too_many_arguments)]
    fn ic_card_end(&mut self, m: &Match, a: Entity, v: Entity, rim: [f32; 3], stance: &'d str, kanji: &'d str, reading: &'d str, sub: &'d str) {
        self.card(Some(Card::Black), None);
        self.back_rim(56.0, rim);
        self.shot_on(m, a, 155.0, 3.2, 0.55, 1.3, 0.0, -0.5);
        self.clip(m, a, stance, 0.0, 1.0, 0.0);
        self.clip(m, v, "sh-crumple", 0.0, 1.0, 0.0);
        let mut b = self.bcap(kanji);
        (b.reading, b.sub, b.side, b.hanko) = (Some(reading), Some(sub), 1, true);
        self.caption(b);
    }

    /// The impact frame after the black card: a negative, the Konpaku, the sounds, a shake.
    fn ic_card_impact(&mut self, m: &Match, a: Entity, v: Entity) {
        self.impact("negative", 2.0);
        self.shatter(m, v, Self::kikon_n(m, a), 1.0, 0.1);
        self.sfx("konpaku-shatter", 1.0, 1.0);
        self.sfx("explode", 0.6, 0.6);
        self.shake(0.3, 0.4);
    }

    /// port: IC-KIKON-CINE's AT forms.
    fn ic_kikon_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.ic_open(m, a, v, 3.6, "ic-juji-x", 0.15, "whoosh-heavy", 1.1),
            12 => {
                self.card(Some(Card::White), Some(a));
                self.shot_on(m, a, 30.0, 3.2, 0.7, 1.1, 0.0, -0.8);
                self.lens(44.0, -8.0);
                self.silence(58.0);
                let mut b = self.bcap("月牙天衝");
                (b.kanji2, b.reading, b.sub, b.side, b.ink, b.hanko) =
                    (Some("王虚の閃光"), Some("GETSUGA TENSHO"), Some("GRAN REY CERO  KIKON"), 1, true, true);
                self.caption(b);
            }
            70 => {
                self.card(Some(Card::Black), Some(a));
                self.caption_exit();
                // (FACE-EACH-OTHER 7.0 ran in the sim; the card and the exit read no place)
                self.shot_on(m, a, 40.0, 4.6, 0.5, 2.3, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.clip(m, a, "ic-cero-raise", 6.0, 1.0, 0.0);
                self.sfx("awaken-rise", 0.8, 1.0);
            }
            100 => {
                self.lens(52.0, 0.0);
                self.sfx("getsuga", 1.2, 1.0);
                self.sfx("awaken-boom", 0.7, 0.6);
            }
            128 => {
                self.card(None, None);
                self.shot_on(m, a, 90.0, 4.2, 1.2, 1.3, 0.0, 0.0);
                self.lens(46.0, 0.0);
                self.clip(m, a, "ic-getsuga", 0.0, 1.0, 0.2);
                self.sfx("getsuga", 1.0, 1.0);
            }
            132 => self.impact("negative", 2.0),
            138 => {
                self.card(Some(Card::White), None);
                self.shot_on(m, a, 200.0, 5.2, 0.5, 2.6, 0.0, 0.8);
                self.lens(36.0, 0.0);
                self.sfx("explode", 0.6, 1.0);
                let e = &mut self.draw.env;
                (e.sky_top, e.fog_color) = ([0.94, 0.85, 0.86], [0.94, 0.85, 0.86]);
            }
            160 => {
                self.card(None, None);
                self.shot_on(m, v, 150.0, 5.0, 1.2, 1.3, 0.0, 0.0);
                self.lens(58.0, 0.0);
                self.impact("negative", 2.0);
                self.ic_hit(m, v, 2, 0.08);
                self.sfx("getsuga", 0.7, 1.0);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.shake(0.3, 0.4);
            }
            162 => self.impact("manga", 12.0),
            172 => {
                self.shot_on(m, a, 170.0, 5.2, 1.0, 1.2, 0.0, 0.0);
                self.lens(48.0, 0.0);
                self.clip(m, a, "ic-stance", 8.0, 1.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-KESSA-KIKON-CINE's AT forms.
    fn ic_kessa_kikon_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.ic_open(m, a, v, 3.8, "ic-k-uchi", 7.0 / 60.0, "clone", 0.8),
            12 => {
                self.card(Some(Card::Black), Some(v));
                self.shot_on(m, v, 30.0, 5.0, 1.2, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.sfx("hoho-out", 1.0, 1.0);
                self.silence(14.0);
            }
            30 => self.lens(40.0, 0.0),
            34 => self.sfx("cut", 1.0, 1.0),
            50 => self.sfx("cut", 1.1, 1.0),
            66 => self.sfx("cut", 0.95, 1.0),
            82 => self.sfx("cut", 1.15, 1.0),
            100 => {
                self.sfx("cut-heavy", 1.0, 1.0);
                self.sfx("clone", 0.6, 1.0);
                self.shake(0.2, 0.3);
            }
            110 => {
                self.card(None, None);
                self.ui_flash(1.0, 1.0, 1.0, 1.0, 6.0);
                self.silence(10.0);
                self.lens(50.0, 0.0);
            }
            120 => self.ic_card_end(m, a, v, BLOOD_RIM, "ic-k-stance", "千影", "SEN'EI", "KESSA NO ICHIGO  KIKON"),
            124 => self.ic_card_impact(m, a, v),
            126 => self.impact("manga", 12.0),
            176 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, 150.0, 7.0, 2.0, 1.4, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-HASTE-KIKON-CINE's AT forms.
    fn ic_haste_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.ic_open(m, a, v, 3.8, "ic-k-f1", 14.0 / 60.0, "clone", 0.8),
            12 => {
                self.card(Some(Card::Black), Some(v));
                self.shot_on(m, v, 30.0, 5.0, 1.2, 1.2, 0.0, 0.0);
                self.lens(45.0, 0.0);
                self.sfx("hoho-out", 1.0, 1.0);
                self.silence(14.0);
            }
            30 => self.sfx("cut", 1.0, 1.0),
            44 => self.sfx("cut", 1.1, 1.0),
            56 => self.sfx("cut", 0.95, 1.0),
            66 => self.sfx("cut", 1.15, 1.0),
            74 => self.sfx("cut", 1.2, 1.0),
            80 => {
                self.sfx("cut-heavy", 1.0, 1.0);
                self.shake(0.2, 0.3);
            }
            96 => {
                self.card(None, None);
                self.ui_flash(1.0, 1.0, 1.0, 1.0, 6.0);
                self.silence(10.0);
                self.lens(50.0, 0.0);
            }
            106 => self.ic_card_end(m, a, v, BLOOD_RIM, "ic-k-stance", "超速連斬", "CHOSOKU RENZAN", "KESSA NO ICHIGO  KIKON"),
            110 => self.ic_card_impact(m, a, v),
            112 => self.impact("manga", 12.0),
            148 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, 150.0, 7.0, 2.0, 1.4, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-KESSA-GETSUGA-CINE's AT forms.
    fn ic_getsuga_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.shot_on(m, a, 60.0, 4.0, 1.1, 1.1, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ic-k-cut", 2.0, 1.0, 0.15);
                self.clip(m, v, "sh-kikon-victim", 4.0, 1.0, 0.0);
                self.hold_both(a, v, 12.0);
                self.impact("negative", 2.0);
                self.silence(12.0);
            }
            12 => {
                self.shot_on(m, a, 20.0, 3.6, 0.6, 2.2, 0.0, 0.0);
                self.lens(60.0, 0.0);
                self.clip(m, a, "ic-k-f3", 6.0, 0.0, 13.0 / 60.0);
                self.sfx("awaken-rise", 0.5, 1.0);
            }
            48 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(52.0, BLOOD_RIM);
                self.shot_on(m, a, 20.0, 4.2, 0.9, 1.1, 0.0, 0.9);
                self.lens(42.0, 0.0);
                let mut b = self.bcap("月牙天衝");
                (b.kanji2, b.reading, b.sub, b.side, b.hanko) = (Some("漆黒"), Some("GETSUGA TENSHO"), Some("KESSA NO ICHIGO  SOUL BREAK"), 0, true);
                self.caption(b);
            }
            100 => {
                self.card(None, None);
                self.caption_exit();
                self.lens(40.0, 0.0);
                self.clip(m, a, "ic-k-f3", 0.0, 1.0, 17.0 / 60.0);
                self.sfx("getsuga", 0.6, 1.0);
                self.sfx("explode", 0.5, 1.0);
                self.shake(0.35, 0.5);
            }
            112 => {
                self.lens(74.0, 0.0);
                self.silence(20.0);
            }
            140 => {
                self.shot_on(m, v, 160.0, 5.0, 1.3, 1.3, 0.0, 0.0);
                self.lens(58.0, 0.0);
                self.impact("negative", 2.0);
                self.ic_hit(m, v, 4, 0.1);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.sfx("chain-snap", 1.0, 1.0);
                self.shake(0.3, 0.4);
            }
            142 => self.impact("manga", 12.0),
            160 => {
                self.clip(m, a, "ic-k-stance", 10.0, 1.0, 0.0);
                self.lens(74.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-HEAVY-KIKON-CINE's AT forms.
    fn ic_heavy_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.ic_open(m, a, v, 3.6, "ic-drop", 23.0 / 60.0, "whoosh-heavy", 0.9),
            12 => {
                self.card(Some(Card::White), Some(a));
                self.shot_on(m, a, 30.0, 3.2, 0.7, 1.1, 0.0, -0.8);
                self.lens(44.0, -8.0);
                self.silence(40.0);
                let mut b = self.bcap("落牙");
                (b.reading, b.sub, b.side, b.ink, b.hanko) = (Some("RAKUGA"), Some("ICHIGO  KIKON"), 1, true, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                // (FACE-EACH-OTHER 4.2 ran in the sim)
                self.shot_on(m, a, 50.0, 5.0, 0.5, 1.7, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ic-ns1", 6.0, 0.0, 16.0 / 60.0);
                self.sfx("awaken-rise", 0.6, 1.0);
            }
            84 => {
                self.shake(0.08, 0.4);
                self.sfx("awaken-rise", 0.8, 0.6);
            }
            100 => {
                self.shot_on(m, a, 90.0, 7.0, 1.0, 1.2, 2.0, 0.0);
                self.lens(44.0, 0.0);
                self.clip(m, a, "ic-drop", 0.0, 1.0, 9.0 / 60.0);
                self.sfx("whoosh-heavy", 0.7, 1.0);
            }
            112 => {
                self.impact("negative", 2.0);
                self.sfx("ground-crack", 1.0, 1.0);
                self.sfx("explode", 0.5, 1.0);
                self.shake(0.45, 0.6);
                let (px, pz, ux, uz, _) = line_from(m, a, v);
                crate::fx::crack::crack_add(&mut self.em(), px + 1.6 * ux, pz + 1.6 * uz, 2.6);
                vfx_shockwave(&mut self.em(), px + 1.6 * ux, pz + 1.6 * uz, 4.0, PAL_REIATSU); // (:rgb (1.0 0.9 0.5): REIATSU)
            }
            114 => self.impact("manga", 6.0),
            118 => {
                self.shot_on(m, v, 150.0, 5.0, 1.0, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            124 => {
                self.impact("negative", 2.0);
                self.clip(m, v, "sh-crumple", 3.0, 1.0, 0.0);
                self.shatter(m, v, Self::kikon_n(m, a), 1.0, 0.1);
                let p = pos_of(m, v);
                crate::fx::stamps::vfx_hit(&mut self.em(), p[0], (p[1] + 1.0) + 0.3, p[2], "heavy", 0.0, -1.0);
                self.impact_splash_at(m, v, 0.0, 14.0, 0.08);
                crate::fx::crack::crack_add(&mut self.em(), p[0], p[2], 2.0);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.sfx("explode", 0.6, 0.6);
                self.shake(0.3, 0.4);
            }
            126 => self.impact("manga", 12.0),
            142 => {
                self.shot_on(m, a, 165.0, 4.6, 0.5, 1.0, 0.0, 0.0);
                self.lens(40.0, 0.0);
                self.clip(m, a, "ic-stance", 12.0, 1.0, 0.0);
            }
            166 => {
                self.shot_on(m, a, 150.0, 7.5, 2.2, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-RUSH-KIKON-CINE's AT forms.
    fn ic_rush_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.ic_open(m, a, v, 3.8, "ic-rangetsu", 17.0 / 60.0, "cut", 0.9),
            12 => {
                self.card(Some(Card::Black), Some(v));
                self.shot_on(m, v, 30.0, 5.0, 1.2, 1.2, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.sfx("hoho-out", 1.0, 1.0);
                self.silence(10.0);
            }
            22 => self.lens(40.0, 0.0),
            36 => {
                self.sfx("cut", 1.0, 1.0);
                self.clip(m, v, "sh-stagger", 2.0, 1.0, 0.0);
            }
            48 => self.sfx("cut", 1.1, 1.0),
            60 => {
                self.sfx("cut", 0.95, 1.0);
                self.clip(m, v, "sh-flinch", 2.0, 1.0, 0.0);
            }
            72 => self.sfx("cut", 1.15, 1.0),
            84 => {
                self.sfx("cut", 1.05, 1.0);
                self.clip(m, v, "sh-stagger", 2.0, 1.0, 0.0);
            }
            96 => {
                self.sfx("cut-heavy", 1.0, 1.0);
                self.shake(0.2, 0.3);
            }
            100 => {
                self.card(None, None);
                self.ui_flash(1.0, 1.0, 1.0, 1.0, 6.0);
                self.silence(6.0);
            }
            104 => {
                // (FACE-EACH-OTHER 2.4 ran in the sim)
                self.shot_on(m, a, 80.0, 6.0, 1.3, 1.4, 1.2, 0.0);
                self.lens(44.0, 0.0);
                self.clip(m, a, "ic-tsuki-otoshi", 0.0, 1.0, 6.0 / 60.0);
                self.clip(m, v, "sh-stagger", 0.0, 1.0, 0.0);
                self.sfx("whoosh-heavy", 1.0, 1.0);
            }
            116 => {
                self.impact("negative", 2.0);
                self.sfx("cut-heavy", 1.0, 1.0);
                self.sfx("explode", 0.6, 1.0);
                self.shake(0.35, 0.5);
                let q = pos_of(m, v);
                crate::fx::crack::crack_add(&mut self.em(), q[0], q[2], 2.2);
                vfx_shockwave(&mut self.em(), q[0], q[2], 3.5, PAL_REIATSU);
            }
            118 => self.ic_card_end(m, a, v, [1.0, 0.86, 0.45], "ic-stance", "連斬", "RENZAN", "ICHIGO  KIKON"),
            124 => self.ic_card_impact(m, a, v),
            126 => self.impact("manga", 12.0),
            166 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, 150.0, 7.0, 2.0, 1.4, 0.0, 0.0);
                self.lens(50.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-CHAIN-KIKON-CINE's AT forms.
    fn ic_chain_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => self.ic_open(m, a, v, 3.8, "ic-k-whip", 26.0 / 60.0, "chain-snap", 1.0),
            12 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(40.0, BLOOD_RIM);
                self.shot_on(m, a, 20.0, 4.2, 0.9, 1.1, 0.0, 0.9);
                self.lens(42.0, 0.0);
                self.silence(20.0);
                self.clip(m, a, "ic-k-st-chain", 6.0, 1.0, 0.0);
                self.sfx("chain-rattle", 0.7, 1.0);
                let mut b = self.bcap("血鎖");
                (b.reading, b.sub, b.side, b.hanko) = (Some("KESSA"), Some("KESSA NO ICHIGO  KIKON"), 0, true);
                self.caption(b);
            }
            52 => {
                self.card(None, None);
                self.caption_exit();
                // (FACE-EACH-OTHER 7.0 ran in the sim)
                self.shot_on(m, a, 150.0, 5.0, 1.6, 1.1, 0.0, 0.6);
                self.lens(44.0, 0.0);
                self.clip(m, a, "ic-k-whip", 3.0, 1.0, 6.0 / 60.0);
                self.sfx("chain-rattle", 1.0, 1.0);
            }
            66 => {
                self.sfx("chain-snap", 1.0, 1.0);
                self.shake(0.15, 0.3);
                self.clip(m, v, "sh-stagger", 2.0, 1.0, 0.0);
                self.impact("negative", 1.0);
            }
            72 => {
                self.shot_on(m, v, 35.0, 3.8, 0.9, 1.1, 0.0, 0.0);
                self.lens(52.0, 0.0);
                self.sfx("chain-rattle", 0.8, 1.0);
            }
            88 => {
                self.shot_on(m, a, 90.0, 7.5, 1.3, 1.1, 2.5, 0.0);
                self.lens(44.0, 0.0);
                self.clip(m, a, "ic-k-yank", 0.0, 1.0, 14.0 / 60.0);
                self.sfx("chain-snap", 0.8, 1.0);
                self.shake(0.2, 0.3);
            }
            100 => {
                self.clip(m, a, "ic-k-f3", 0.0, 1.0, 17.0 / 60.0);
                self.clip(m, v, "sh-launch", 0.0, 1.0, 0.0);
                self.shot_on(m, a, 60.0, 5.2, 1.2, 1.2, 1.2, 0.0);
                self.lens(44.0, 0.0);
                self.impact("negative", 2.0);
                self.sfx("cut-heavy", 1.0, 1.0);
                self.sfx("chain-snap", 1.0, 1.0);
                self.shake(0.3, 0.4);
            }
            112 => {
                self.card(Some(Card::Black), None);
                self.back_rim(40.0, BLOOD_RIM);
                self.shot_on(m, v, 150.0, 3.8, 1.1, 1.1, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.clip(m, v, "sh-crumple", 4.0, 1.0, 0.0);
            }
            124 => {
                self.impact("negative", 2.0);
                self.shatter(m, v, Self::kikon_n(m, a), 1.0, 0.1);
                let p = pos_of(m, v);
                crate::fx::stamps::vfx_hit(&mut self.em(), p[0], (p[1] + 1.0) + 0.3, p[2], "heavy", 0.0, -1.0);
                self.impact_splash_at(m, v, 0.0, 14.0, 0.1);
                self.sfx("konpaku-shatter", 1.0, 1.0);
                self.sfx("chain-snap", 1.0, 1.0);
                self.sfx("explode", 0.6, 0.6);
                self.shake(0.3, 0.4);
            }
            126 => self.impact("manga", 12.0),
            150 => {
                self.card(None, None);
                self.shot_on(m, a, -30.0, 6.0, 1.4, 1.1, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ic-k-stance", 10.0, 1.0, 0.0);
            }
            _ => {}
        }
    }

    /// port: IC-KESSA-CINE's AT forms (the awakening).
    fn ic_kessa_at(&mut self, m: &Match, cf: i64, a: Entity, v: Entity) {
        match cf {
            0 => {
                self.set_weapon(a, "zangetsu-long");
                self.hide_set(a, &["kessa", "mark"]);
                self.cine.aura_off = Some(a);
                self.shot_on(m, a, 30.0, 3.4, 1.0, 1.0, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.clip(m, a, "ic-awaken", 3.0, 1.0, 0.0);
                self.clip(m, v, Self::stance(m, v), 6.0, 1.0, 0.0);
                self.hold_both(a, v, 12.0);
                self.impact("negative", 2.0);
                self.silence(12.0);
            }
            12 => {
                self.shot_on(m, a, 20.0, 1.3, 1.62, 1.62, 0.0, 0.0);
                self.lens(70.0, 0.0);
                self.sfx("awaken-rise", 0.6, 1.0);
            }
            26 => self.hide_set(a, &["kessa"]),
            40 => {
                self.shot_on(m, a, 40.0, 3.0, 0.5, 1.1, 0.0, 0.4);
                self.lens(64.0, -4.0);
            }
            58 => {
                self.set_weapon(a, "tensa");
                self.hide_set(a, &["shikai", "kessa"]);
                self.ui_flash(1.0, 1.0, 1.0, 1.0, 20.0);
                self.sfx("awaken-boom", 1.2, 1.0);
            }
            70 => {
                self.shot_on(m, a, 170.0, 3.6, 0.35, 1.0, 0.0, 0.0);
                self.lens(76.0, -6.0);
                self.hide_set(a, &["shikai", "mark"]);
                self.sfx("chain-rattle", 1.0, 1.0);
                self.sfx("awaken-boom", 1.0, 1.0);
            }
            80 => {
                self.sfx("chain-rattle", 0.8, 1.0);
                self.shake(0.15, 0.3);
            }
            96 => {
                self.card(Some(Card::Black), Some(a));
                self.back_rim(54.0, BLOOD_RIM);
                self.shot_on(m, a, 20.0, 4.4, 0.9, 1.1, 0.0, 0.9);
                self.lens(42.0, 0.0);
                let mut b = self.bcap("血鎖の一護");
                (b.reading, b.sub, b.side) = (Some("KESSA NO ICHIGO"), Some("TENSA ZANGETSU"), 0);
                self.caption(b);
            }
            150 => {
                self.card(None, None);
                self.caption_exit();
                self.shot_on(m, a, -30.0, 6.0, 1.4, 1.1, 0.0, 0.0);
                self.lens(50.0, 0.0);
                self.cine.aura_off = None;
                self.clip(m, a, "ic-k-stance", 10.0, 1.0, 0.0);
            }
            _ => {}
        }
    }

    // ------------------------------------------------------------ the DURING forms

    /// Ichigo's scripts' draw-mode look forms at frame CF (in script order), into OUT.
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn ichigo_during(&mut self, m: &Match, k: IcCine, cf: i64, a: Entity, v: Entity, out: &mut FrameOut, _dt: f32) {
        match k {
            IcCine::Kikon => self.ic_kikon_during(m, cf, a, v, out),
            IcCine::KessaKikon => {
                if let Some(u) = during(cf, 30, 110) {
                    let q = pos_of(m, v);
                    let ang = 0.5 + 6.2832 * u;
                    self.cine_cam(q[0] + 5.0 * f_cos(ang), 1.6, q[2] + 5.0 * f_sin(ang), q[0], 1.1, q[2]);
                }
                if during(cf, 30, 116).is_some() {
                    let q = pos_of(m, v);
                    const CLIPS: [&str; 3] = ["ic-k-f1", "ic-k-f3", "ic-k-cut"];
                    let (waves, per) = (4i64, 3i64); // (*cine-clone-waves*)
                    for w in 0..waves {
                        for i in 0..per {
                            let ang = ((0.5 + 3.1416) + 6.2832 * ((8 + 16 * w) as f32 / 80.0)) + (i - 1) as f32 * 0.6;
                            let h0 = if i == 1 { 3.5 } else { 0.0 };
                            self.ic_cine_charge(out, q[0], q[2], ang, 30 + 16 * w, cf, 22.0, h0, CLIPS[((w + i) % 3) as usize], false);
                        }
                    }
                    for i in 0..12usize {
                        self.ic_cine_charge(out, q[0], q[2], i as f32 * 0.5236, 96, cf, 45.0, if i % 2 == 1 { 2.5 } else { 0.0 }, CLIPS[i % 3], false);
                    }
                }
            }
            IcCine::Haste => {
                if let Some(u) = during(cf, 24, 96) {
                    let q = pos_of(m, v);
                    let ang = 0.5 + 4.0 * u;
                    self.cine_cam(q[0] + 4.6 * f_cos(ang), 1.5, q[2] + 4.6 * f_sin(ang), q[0], 1.1, q[2]);
                }
                if during(cf, 24, 100).is_some() {
                    let q = pos_of(m, v);
                    let c = &mut self.ctx(out);
                    for back in 0..5 {
                        let k = cf - back;
                        let th = 2.399963 * k as f32;
                        let dy = 0.7 * f_sin(1.3 * k as f32);
                        let fade = 1.0 - 0.2 * back as f32;
                        if k % 2 == 0 {
                            let (cs, sn) = (f_cos(th), f_sin(th));
                            line(c, [q[0] + 1.9 * cs, 1.1 + dy, q[2] + 1.9 * sn], [q[0] - 1.9 * cs, 1.1 - dy, q[2] - 1.9 * sn], 0.03, [1.0; 3], fade);
                        }
                    }
                }
            }
            IcCine::KessaGetsuga => self.ic_getsuga_during(m, cf, a, v, out),
            IcCine::HeavyKikon => {
                if let Some(u) = during(cf, 58, 112) {
                    self.vfx_ic_glow_blade(a, min_f32(1.0, 1.5 * u), out);
                }
                if during(cf, 60, 112).is_some() {
                    let p = pos_of(m, a);
                    let mut cx = self.ctx(out);
                    let c = &mut cx.em();
                    if c.rnd() < 0.6 {
                        let x = p[0] + c.rr(-1.6, 1.6);
                        let z = p[2] + c.rr(-1.6, 1.6);
                        t_blob(c, x, 0.1, z, 0.0, 0.6, 0.0, 0.9, 0.06, -0.05, 0.1, PAL_ASH);
                    }
                }
                if during(cf, 112, 180).is_some() {
                    let (px, pz, ux, uz, d) = line_from(m, a, v);
                    let l = (d + 6.0) * min_f32(1.0, (cf - 112) as f32 / 12.0);
                    let k = if cf < 150 { 0.95 } else { max_f32(0.0, 0.95 - 0.03 * (cf - 150) as f32) };
                    let mut cx = self.ctx(out);
                    vfx_ic_split(&mut cx, px + 1.6 * ux, pz + 1.6 * uz, ux, uz, l, k);
                    let c = &mut cx.em();
                    if cf < 136 && c.rnd() < 0.7 {
                        let s = c.rr(0.0, l);
                        let vx = c.rr(-1.0, 1.0);
                        let vy = c.rr(3.0, 6.0);
                        let vz = c.rr(-1.0, 1.0);
                        super::ken::t_shard(c, px + (1.6 + s) * ux, 0.1, pz + (1.6 + s) * uz, vx, vy, vz, 0.3, 0.06, 0.0, PAL_INK);
                    }
                }
            }
            IcCine::RushKikon => {
                if let Some(u) = during(cf, 22, 98) {
                    let q = pos_of(m, v);
                    let ang = 0.5 + 4.4 * u;
                    self.cine_cam(q[0] + 5.5 * f_cos(ang), 1.5, q[2] + 5.5 * f_sin(ang), q[0], 1.1, q[2]);
                }
                if during(cf, 22, 104).is_some() {
                    let q = pos_of(m, v);
                    const DIRS: [f32; 6] = [0.4, 3.0, 5.2, 1.7, 4.1, 0.9]; // (*cine-rush-dirs*)
                    for (i, ang) in DIRS.into_iter().enumerate() {
                        let st = 22 + 12 * i as i64;
                        let r = 9.0 - 40.0 * ((cf - st) as f32 / 60.0);
                        self.ic_cine_charge(out, q[0], q[2], ang, st, cf, 40.0, 0.0, if i % 2 == 0 { "ic-rangetsu" } else { "ic-f1" }, true);
                        if cf >= st && r < 8.0 && r > -6.0 {
                            let (r0, r1, k) = (min_f32(9.0, r + 6.0), max_f32(-6.0, r), min_f32(0.8, 0.12 * (r + 6.0)));
                            let (cs, sn) = (f_cos(ang), f_sin(ang));
                            fx_line(&mut self.ctx(out), [q[0] + r0 * cs, 1.0, q[2] + r0 * sn], [q[0] + r1 * cs, 1.0, q[2] + r1 * sn], 0.03, 1.0, 0.9, 0.55, k, Mode::Add, 0.12, k);
                        }
                    }
                }
                if during(cf, 104, 116).is_some() {
                    self.vfx_ic_glow_blade(a, 0.9, out);
                }
            }
            IcCine::ChainKikon => self.ic_chain_during(m, cf, a, v, out),
            IcCine::Kessa => {
                if during(cf, 70, 168).is_some() {
                    let g = min_f32(1.0, (cf - 70) as f32 / 10.0);
                    let p = pos_of(m, a);
                    for (i, j) in ["neck", "hand-r", "hand-l", "shin-r", "shin-l"].into_iter().enumerate() {
                        let [x, y, z] = self.ic_joint(a, joint_index(&self.data.rig, j), [0.0; 3]);
                        let (dx, dz) = (x - p[0], z - p[2]);
                        let l = max_f32(0.05, hypot(dx, dz));
                        let r = g * (0.8 + 0.3 * f_sin(0.1 * cf as f32 + i as f32));
                        let y1 = (y + 0.4 * g) + 0.2 * f_sin(0.13 * cf as f32 + i as f32);
                        crate::draw::ichigo::vfx_ic_chain(&mut self.ctx(out), [x, y, z], [x + r * (dx / l), y1, z + r * (dz / l)], 0.9);
                    }
                }
            }
        }
    }

    /// IC-KIKON-CINE's DURING forms.
    fn ic_kikon_during(&mut self, m: &Match, cf: i64, a: Entity, v: Entity, out: &mut FrameOut) {
        if during(cf, 70, 100).is_some() {
            // a violet haze at the frame's right edge
            let (q, yaw) = (pos_of(m, a), yaw_of(m, a));
            let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
            let p0 = [(q[0] + 3.0 * fz) + -2.0 * fx, 0.5, (q[2] - 3.0 * fx) - 2.0 * fz];
            let p1 = [(q[0] + 3.4 * fz) + -2.0 * fx, 3.5, (q[2] - 3.4 * fx) - 2.0 * fz];
            line(&mut self.ctx(out), p0, p1, 1.2, VIOLET, 0.25);
        }
        if let Some(u) = during(cf, 80, 100) {
            let (_, w) = self.ic_blade(a, None);
            let head = self.ic_joint(a, joint_index(&self.data.rig, "head"), [-0.26, 0.215, 0.06]);
            let c = &mut self.ctx(out);
            vfx_ic_orb(c, w, 0.05 + 0.3 * u, 0.95);
            line(c, head, w, 0.012, GOLD, if cf % 6 < 2 { 0.95 } else { 0.55 });
        }
        if during(cf, 100, 128).is_some() {
            let (_, w) = self.ic_blade(a, None);
            let k = if cf < 116 { 0.95 } else { max_f32(0.1, 0.95 - 0.08 * (cf - 116) as f32) };
            let (p, yaw) = (pos_of(m, a), yaw_of(m, a));
            {
                let c = &mut self.ctx(out);
                vfx_ic_hook(c, w, yaw, 1.6, k);
                vfx_ic_flame_body(c, p, if cf < 120 { 0.95 } else { 0.5 }, cf as f32);
            }
            if cf >= 116 {
                self.vfx_ic_red_blade(a, min_f32(1.0, (cf - 114) as f32 / 6.0), out);
            }
        }
        if during(cf, 128, 138).is_some() {
            self.vfx_ic_red_blade(a, 0.9, out);
        }
        if during(cf, 138, 162).is_some() {
            let (p, q) = (pos_of(m, a), pos_of(m, v));
            let (dx, dz) = (q[0] - p[0], q[2] - p[2]);
            let d = max_f32(0.1, hypot(dx, dz));
            let uu = min_f32(1.0, (cf - 136) as f32 / 22.0);
            let c = &mut self.ctx(out);
            vfx_ic_cero_ring(c, p[0] + dx * (0.3 + 0.7 * uu), 2.4, p[2] + dz * (0.3 + 0.7 * uu), dx / d, dz / d, 0.14 * (cf as f32 / 60.0), 0.95);
        }
        if let Some(u) = during(cf, 160, 172) {
            let q = pos_of(m, v);
            vfx_ic_cero_ring(&mut self.ctx(out), q[0], 2.0, q[2], 1.0, 0.0, 0.0, max_f32(0.05, 0.9 - 1.2 * u));
        }
        if during(cf, 172, 186).is_some() {
            let q = pos_of(m, v);
            let mut cx = self.ctx(out);
            let c = &mut cx.em();
            if c.rnd() < 0.5 {
                let x = q[0] + c.rr(-2.0, 2.0);
                let y = c.rr(0.5, 3.0);
                let z = q[2] + c.rr(-2.0, 2.0);
                t_blob(c, x, y, z, 0.0, 0.3, 0.0, 1.2, 0.05, -0.05, 0.1, PAL_ASH);
            }
        }
    }

    /// IC-KESSA-GETSUGA-CINE's DURING forms.
    fn ic_getsuga_during(&mut self, m: &Match, cf: i64, a: Entity, v: Entity, out: &mut FrameOut) {
        if let Some(u) = during(cf, 12, 48) {
            let (b, w) = self.ic_blade(a, Some("tensa"));
            let mut cx = self.ctx(out);
            line_a(&mut cx, b, w, 0.08 + 0.18 * u, [0.02, 0.02, 0.03], 0.9 * u);
            let c = &mut cx.em();
            for _ in 0..3 {
                let f = c.rnd();
                let a0 = c.rr(0.0, 6.28);
                let x = (b[0] + f * (w[0] - b[0])) + 1.2 * f_cos(a0);
                let y = b[1] + f * (w[1] - b[1]);
                let z = (b[2] + f * (w[2] - b[2])) + 1.2 * f_sin(a0);
                super::ken::t_shard(c, x, y, z, -3.0 * f_cos(a0), 0.0, -3.0 * f_sin(a0), 0.35, 0.05, 0.0, PAL_INK);
            }
        }
        if let Some(u) = during(cf, 100, 112) {
            let (px, pz, ux, uz, d) = line_from(m, a, v);
            let (hx, hz) = (px + (0.5 * d) * ux, pz + (0.5 * d) * uz);
            self.cine_cam(hx + 14.0 * -uz, 2.6, hz + 14.0 * ux, hx, 2.4, hz);
            vfx_ic_c_cut(&mut self.ctx(out), px, pz, ux, uz, d, 0.95, 0.0, min_f32(1.0, 1.4 * u), 1.0, 0.0);
        }
        if let Some(u) = during(cf, 112, 140) {
            let (px, pz, ux, uz, d) = line_from(m, a, v);
            let cc = 0.84 * d - 0.5 * u;
            self.cine_cam(px + cc * ux, 2.4, pz + cc * uz, px, 2.4, pz);
            vfx_ic_c_cut(&mut self.ctx(out), px, pz, ux, uz, d, 0.8 + 0.15 * f_sin(0.4 * cf as f32), 0.0, 1.0, 1.0, 0.0);
        }
        if let Some(u) = during(cf, 140, 160) {
            let (px, pz, ux, uz, d) = line_from(m, a, v);
            vfx_ic_c_cut(&mut self.ctx(out), px, pz, ux, uz, d, 0.95, 0.0, 1.0, 1.0, 1.0 - u);
        }
        if let Some(u) = during(cf, 160, 180) {
            let (px, pz, ux, uz, d) = line_from(m, a, v);
            self.cine_cam(px + (0.8 * d) * ux, 2.4, pz + (0.8 * d) * uz, px, 2.4, pz);
            vfx_ic_c_cut(&mut self.ctx(out), px, pz, ux, uz, d, 0.9 - 0.5 * u, 0.5 * u, 1.0 - 0.5 * u, 1.0, 0.0);
        }
    }

    /// IC-CHAIN-KIKON-CINE's DURING forms.
    fn ic_chain_during(&mut self, m: &Match, cf: i64, a: Entity, v: Entity, out: &mut FrameOut) {
        let n = self.fl.kn.ic.chain_roots.len();
        let root = |sc: &Scene, i: usize| sc.fl.kn.ic.chain_roots[i];
        if let Some(u) = during(cf, 12, 52) {
            // the chains uncoiling round him
            let p = pos_of(m, a);
            let g = min_f32(1.0, 2.0 * u);
            for i in 0..n {
                let (j, l) = root(self, i);
                let mut p0 = self.ic_joint(a, j, l);
                for k in 0..3 {
                    let an = (0.06 * cf as f32 + i as f32 * 1.571) + (k + 1) as f32 * 0.6;
                    let rr = g * (0.7 + 0.25 * k as f32);
                    let p1 = [p[0] + rr * f_cos(an), (0.4 + 0.35 * (i % 2) as f32) + (g * 0.3) * k as f32, p[2] + rr * f_sin(an)];
                    crate::draw::ichigo::vfx_ic_chain(&mut self.ctx(out), p0, p1, 0.9);
                    p0 = p1;
                }
            }
        }
        if let Some(u) = during(cf, 52, 66) {
            self.vfx_ic_chain_bind(a, v, u, 0.95, out);
        }
        if during(cf, 66, 108).is_some() {
            self.vfx_ic_chain_bind(a, v, 1.0, 0.95, out);
        }
        if let Some(u) = during(cf, 70, 108) {
            vfx_ic_chain_wrap(&mut self.ctx(out), pos_of(m, v), cf as f32, min_f32(0.9, 4.0 * u));
        }
        if let Some(u) = during(cf, 100, 112) {
            let (q, yaw) = (pos_of(m, v), yaw_of(m, v));
            let k = 0.95 - 0.8 * u;
            let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
            let p0 = [q[0] + 1.0 * fz, 2.0, q[2] - 1.0 * fx];
            let p1 = [q[0] - 1.0 * fz, 0.3, q[2] + 1.0 * fx];
            let c = &mut self.ctx(out);
            line_a(c, p0, p1, 0.16, BLOOD_RIM, k);
            line(c, p0, p1, 0.04, [1.0; 3], k);
        }
        if let Some(u) = during(cf, 150, 180) {
            // the chains back round him
            let p = pos_of(m, a);
            let g = min_f32(1.0, 3.0 * u);
            for i in 0..n {
                let (j, l) = root(self, i);
                let r = self.ic_joint(a, j, l);
                let an = 0.05 * cf as f32 + i as f32 * 1.571;
                let rr = g * 0.85;
                let p1 = [p[0] + rr * f_cos(an), 0.5 + 0.3 * (i % 2) as f32, p[2] + rr * f_sin(an)];
                crate::draw::ichigo::vfx_ic_chain(&mut self.ctx(out), r, p1, 0.8);
            }
        }
    }

    /// port: ichigo-look.lisp VFX-IC-CHAIN-BIND — KESSA's four chains cast at V: each tip REACH of the way to its grip on him, arcing up
    /// on the way; presence K.
    fn vfx_ic_chain_bind(&mut self, a: Entity, v: Entity, reach: f32, k: f32, out: &mut FrameOut) {
        let grips = ["upper-arm-l", "upper-arm-r", "thigh-l", "thigh-r"].map(|n| joint_index(&self.data.rig, n)); // (*cine-chain-grips*)
        for (i, g) in grips.into_iter().enumerate().take(self.fl.kn.ic.chain_roots.len()) {
            let (j, l) = self.fl.kn.ic.chain_roots[i];
            let r = self.ic_joint(a, j, l);
            let w = self.ic_joint(v, g, [0.0; 3]);
            let s = min_f32(1.0, max_f32(0.0, 1.2 * reach - 0.05 * i as f32));
            let [x0, y0, z0] = r;
            if s > 0.0 {
                // (* 0.9 (sin (* pi s)) (- 1.0 s)): a long-float pi, so a double, added last and rounded once by the call
                let arc = (0.9 * duel_sim::math::sin_d(std::f64::consts::PI * s as f64)) * (1.0 - s) as f64;
                let y1 = ((y0 + s * (w[1] - y0)) as f64 + arc) as f32;
                let p1 = [x0 + s * (w[0] - x0), y1, z0 + s * (w[2] - z0)];
                crate::draw::ichigo::vfx_ic_chain(&mut self.ctx(out), r, p1, if i == 0 { k } else { 0.85 * k });
            }
        }
    }

    /// port: ichigo-look.lisp VFX-IC-GLOW-BLADE — the Shikai's yellow-white reiatsu along E's held cleaver, presence K.
    fn vfx_ic_glow_blade(&mut self, e: Entity, k: f32, out: &mut FrameOut) {
        let (b, w) = self.ic_blade(e, None);
        let c = &mut self.ctx(out);
        line_a(c, b, w, 0.1 + 0.2 * k, [1.0, 0.86, 0.45], 0.6 * k);
        line(c, b, w, 0.03 + 0.06 * k, [1.0, 0.97, 0.85], k);
        c.light(w[0], w[1], w[2], 1.0, 0.86, 0.45, 5.0, 2.0 * k, 8);
    }

    /// port: ichigo-look.lisp VFX-IC-RED-BLADE — the gold drained out of the blade: a red slash in a pink-violet glow.
    fn vfx_ic_red_blade(&mut self, e: Entity, k: f32, out: &mut FrameOut) {
        let (b, w) = self.ic_blade(e, None);
        let c = &mut self.ctx(out);
        line(c, b, w, 0.22, VIOLET, 0.7 * k);
        line_a(c, b, w, 0.07, BLOOD_RIM, k);
        c.light(w[0], w[1], w[2], VIOLET[0], VIOLET[1], VIOLET[2], 5.0, 2.0 * k, 8);
    }

    /// port: ichigo-look.lisp IC-CINE-CHARGE — one phantom of a charge: from 9 m out at ANG (H0 up) at SPEED m/s from frame START
    /// through the victim at (VX VZ), dissolving 1 m past him; the ink streak and the white flash where it passes.
    #[allow(clippy::too_many_arguments)]
    fn ic_cine_charge(&mut self, out: &mut FrameOut, vx: f32, vz: f32, ang: f32, start: i64, cf: i64, speed: f32, h0: f32, clip: &str, shikai: bool) {
        let tt = (cf - start) as f32 / 60.0;
        let r = 9.0 - speed * tt;
        if cf >= start && r > -1.0 {
            let (cs, sn) = (f_cos(ang), f_sin(ang));
            let (x, z, y) = (vx + r * cs, vz + r * sn, h0 * max_f32(0.0, r / 9.0));
            let yaw = dir_yaw(-cs, -sn);
            let a = if r < 0.0 { 0.5 * (1.0 + r) } else { 0.5 };
            let Scene { fl, cos, fx, draw, data, .. } = self;
            let c = &mut Ctx { out, cam: &draw.camera, cos, fx, clock: draw.post.fx_clock };
            crate::draw::ichigo::ic_body_at(c, fl, data, x, y, z, yaw, clip, 0.3 * tt, a, shikai);
            if f_abs(r) < 1.2 {
                line_a(c, [vx + 1.5 * cs, 1.1, vz + 1.5 * sn], [vx - 1.5 * cs, 1.0, vz - 1.5 * sn], 0.06, [0.02, 0.02, 0.03], 0.9);
                line(c, [vx + 1.2 * cs, 1.1, vz + 1.2 * sn], [vx - 1.2 * cs, 1.0, vz - 1.2 * sn], 0.025, [1.0; 3], 0.9);
            }
        }
    }
}

/// port: ichigo-look.lisp VFX-IC-ORB — the gold orb on the blade's tip P (radius R): a white-yellow core in a gold-orange rim, its light.
fn vfx_ic_orb(c: &mut Ctx, p: [f32; 3], r: f32, k: f32) {
    let [x, y, z] = p;
    line(c, [x, y - r, z], [x, y + r, z], 1.4 * r, GOLD, 0.8 * k);
    line(c, [x, y - 0.6 * r, z], [x, y + 0.6 * r, z], 0.8 * r, [1.0, 0.96, 0.82], k);
    c.light(x, y, z, GOLD[0], GOLD[1], GOLD[2], 5.0, 2.5 * k, 8);
}

/// port: ichigo-look.lisp VFX-IC-HOOK — the orb burst into a hooked flame crescent curling back over the tip P (facing YAW, S m).
fn vfx_ic_hook(c: &mut Ctx, p: [f32; 3], yaw: f32, s: f32, k: f32) {
    let [x, y, z] = p;
    let (fx, fz) = (fwd_x(yaw), fwd_z(yaw));
    let n = 10;
    for i in 0..n {
        let (fi, fi1, nf) = (i as f32, (i + 1) as f32, n as f32);
        let (a0, a1) = (3.9 * (fi / nf), 3.9 * (fi1 / nf));
        let (r0, r1) = ((s * 0.5) * (1.0 - 0.12 * (fi / nf)), (s * 0.5) * (1.0 - 0.12 * (fi1 / nf)));
        let p0 = [x + (r0 * f_sin(a0)) * -fx, y + r0 * (1.0 - f_cos(a0)), z + (r0 * f_sin(a0)) * -fz];
        let p1 = [x + (r1 * f_sin(a1)) * -fx, y + r1 * (1.0 - f_cos(a1)), z + (r1 * f_sin(a1)) * -fz];
        let w = (s * 0.09) * f_sin(3.14 * ((fi + 0.5) / nf));
        line(c, p0, p1, 1.6 * w, GOLD, 0.9 * k);
        line_a(c, p0, p1, 0.6 * w, [0.85, 0.1, 0.12], k);
    }
    c.light(x, y + 0.4 * s, z, GOLD[0], GOLD[1], GOLD[2], 7.0, 2.2 * k, 8);
}

/// port: ichigo-look.lisp VFX-IC-FLAME-BODY — the gold flame swallowing the body at feet P, flickering with TM (the cine frame).
fn vfx_ic_flame_body(c: &mut Ctx, p: [f32; 3], k: f32, tm: f32) {
    for i in 0..28 {
        let fi = i as f32;
        let a = fi * 0.2244 + 0.05 * f_sin(0.7 * fi);
        let r = 0.55 + 0.25 * f_sin(3.1 * fi + 0.2 * tm);
        let y0 = 2.2 * ((7 * i % 11) as f32 / 11.0);
        let l = 0.7 + 0.6 * f_abs(f_sin(1.7 * fi + 0.35 * tm));
        let (ca, sa) = (f_cos(a), f_sin(a));
        let (x0, z0) = (p[0] + r * ca, p[2] + r * sa);
        fx_line(c, [x0, y0, z0], [x0 + 0.2 * ca, y0 + l, z0 + 0.2 * sa], 0.2, GOLD[0], GOLD[1], GOLD[2], 0.55 * k, Mode::Add, 0.0, 0.55 * k);
        fx_line(c, [x0, y0, z0], [x0 + 0.1 * ca, y0 + 0.6 * l, z0 + 0.1 * sa], 0.09, 1.0, 0.95, 0.8, 0.5 * k, Mode::Add, 0.0, 0.5 * k);
    }
    c.light(p[0], 1.4, p[2], 1.0, 0.62, 0.2, 6.0, 2.0 * k, 8);
}

/// port: ichigo-look.lisp VFX-IC-CERO-RING — the Cero Getsuga: an 8 m violet ring round a dark blood-red disc, four gold spikes at the
/// diagonals; its plane facing along (UX UZ), turned ROT about it.
#[allow(clippy::too_many_arguments)]
fn vfx_ic_cero_ring(c: &mut Ctx, x: f32, y: f32, z: f32, ux: f32, uz: f32, rot: f32, k: f32) {
    let (rx, rz, n, r) = (-uz, ux, 32, 4.0f32);
    let pt = |a: f32, rr: f32| [x + (rr * f_cos(a)) * rx, y + rr * f_sin(a), z + (rr * f_cos(a)) * rz];
    for i in 0..48 {
        let a = rot + i as f32 * 0.1309;
        let p1 = pt(a, 0.95 * r);
        fx_line(c, [x, y, z], p1, 0.05, CERO_CORE[0], CERO_CORE[1], CERO_CORE[2], 0.95 * k, Mode::Alpha, 0.9, 0.95 * k);
    }
    for i in 0..n {
        let p0 = pt(rot + i as f32 * (6.2832 / n as f32), r);
        let p1 = pt(rot + (i + 1) as f32 * (6.2832 / n as f32), r);
        line_a(c, p0, p1, 0.5, VIOLET, 0.9 * k);
        line(c, p0, p1, 0.25, VIOLET, 0.5 * k);
    }
    for i in 0..4 {
        let a = (rot + 0.785) + i as f32 * 1.5708;
        let (p0, p1, p2) = (pt(a - 0.3, 1.15 * r), pt(a + 0.3, 1.15 * r), pt(a, 1.45 * r));
        fx_line(c, p0, p2, 0.22, GOLD[0], GOLD[1], GOLD[2], k, Mode::Alpha, 0.02, k);
        fx_line(c, p1, p2, 0.22, GOLD[0], GOLD[1], GOLD[2], k, Mode::Alpha, 0.02, k);
    }
    c.light(x, y, z, 0.75, 0.25, 0.91, 10.0, 3.0 * k, 9);
}

/// port: ichigo-look.lisp VFX-IC-SPLIT — RAKUGA's split: a jagged ink gash L m from (PX PZ) along (UX UZ), a yellow-white ember in it.
fn vfx_ic_split(c: &mut Ctx, px: f32, pz: f32, ux: f32, uz: f32, l: f32, k: f32) {
    let (n, rx, rz) = (14, -uz, ux);
    let pt = |j: i32| {
        let s = l * (j as f32 / n as f32);
        let o = (0.18 * f_sin(2.7 * j as f32)) * (1.0 - j as f32 / n as f32);
        ((px + s * ux) + o * rx, (pz + s * uz) + o * rz)
    };
    for i in 0..n {
        let ((x0, z0), (x1, z1)) = (pt(i), pt(i + 1));
        let w = 0.32 * (1.0 - 0.8 * (i as f32 / n as f32));
        fx_line(c, [x0, 0.03, z0], [x1, 0.03, z1], w, 0.02, 0.02, 0.03, k, Mode::Alpha, 0.85 * w, k);
        fx_line(c, [x0, 0.04, z0], [x1, 0.04, z1], 0.3 * w, 1.0, 0.9, 0.55, 0.9 * k, Mode::Add, 0.25 * w, 0.9 * k);
    }
}

/// port: ichigo-look.lisp VFX-IC-CHAIN-WRAP — two coils of blood chain round the fighter at Q's chest and thighs, turning with TM.
fn vfx_ic_chain_wrap(c: &mut Ctx, q: [f32; 3], tm: f32, k: f32) {
    for hy in [1.2f32, 0.6] {
        for i in 0..8 {
            let a0 = (0.05 * tm) * hy + i as f32 * 0.785;
            let a1 = (0.05 * tm) * hy + (i + 1) as f32 * 0.785;
            crate::draw::ichigo::vfx_ic_chain(
                c,
                [q[0] + 0.42 * f_cos(a0), hy + 0.04 * i as f32, q[2] + 0.42 * f_sin(a0)],
                [q[0] + 0.42 * f_cos(a1), hy + 0.04 * (i + 1) as f32, q[2] + 0.42 * f_sin(a1)],
                k,
            );
        }
    }
}

/// The C's band thickness at a point: the value and whether it is a single (MAX kept the single 0.0 of a zero sine: every point built
/// on it is single arithmetic) or a double (the long-float pi's sine).
#[derive(Clone, Copy)]
struct Wd(f64, bool);

/// port: ichigo-look.lisp VFX-IC-C-CUT — 漆黒の月牙天衝's C from fraction LO to HI of its arc (SCALE its band, FLARE its halo), with
/// IC-C-POINT-OUT. The band's thickness W(u) goes through the long-float pi (`(sin (* pi u))`), so it and every point built on it are
/// doubles, rounded to singles by FX-LINE's F32, as the Lisp computes them; a zero sine takes MAX's single 0.0 and stays single.
#[allow(clippy::too_many_arguments)]
fn vfx_ic_c_cut(c: &mut Ctx, px: f32, pz: f32, ux: f32, uz: f32, d: f32, k: f32, lo: f32, hi: f32, scale: f32, flare: f32) {
    let (g0, g1, n, clk) = (deg(32.0), deg(328.0), 40, c.clock);
    // W(u): (* scale (+ 0.3 (* 1.4 (expt (max 0.0 (sin (* pi u))) 0.6))))
    let w = |u: f32| -> Wd {
        let sn = duel_sim::math::sin_d(std::f64::consts::PI * u as f64);
        if sn > 0.0 {
            Wd(scale as f64 * (0.3f32 as f64 + 1.4f32 as f64 * duel_sim::math::pow_d(sn, 0.6f32 as f64)), false)
        } else {
            Wd((scale * (0.3 + 1.4 * duel_sim::cl::musl_powf(0.0, 0.6))) as f64, true)
        }
    };
    // IC-C-POINT-OUT with O = F x W: (values (+ px (* ux (- h (* hx (cos th))))) (max 0.03 (+ 2.4 (* (+ 3.2 o) (sin th)))) (+ pz …))
    let pt = |th: f32, f: f32, wd: Wd| -> [f32; 3] {
        let h = 0.5 * d;
        let (ct, st) = (f_cos(th), f_sin(th));
        if wd.1 {
            let o = f * wd.0 as f32;
            let hx = 0.5 * d + o;
            [px + ux * (h - hx * ct), max_f32(0.03, 2.4 + (3.2 + o) * st), pz + uz * (h - hx * ct)]
        } else {
            let o = f as f64 * wd.0;
            let hx = (0.5 * d) as f64 + o;
            let x = px as f64 + ux as f64 * (h as f64 - hx * ct as f64);
            let yy = 2.4f32 as f64 + (3.2f32 as f64 + o) * st as f64;
            let z = pz as f64 + uz as f64 * (h as f64 - hx * ct as f64);
            [x as f32, if yy > 0.03f32 as f64 { yy as f32 } else { 0.03 }, z as f32]
        }
    };
    for i in 0..n {
        let (u0, u1) = (i as f32 / n as f32, (i + 1) as f32 / n as f32);
        if u1 > lo && u0 < hi {
            let (v0, v1) = (max_f32(lo, u0), min_f32(hi, u1));
            let (t0, t1) = (g0 + (g1 - g0) * v0, g0 + (g1 - g0) * v1);
            let (w0, w1) = (w(v0), w(v1));
            // a line from offset f0 x w0 to f1 x w1 (thickness fractions), WID x the widths
            let seg = |c: &mut Ctx, f0: f32, f1: f32, wid: f32, rgb: [f32; 3], a: f32, fade: f32| {
                let (p0, p1) = (pt(t0, f0, w0), pt(t1, f1, w1));
                fx_line(c, p0, p1, (wid as f64 * w0.0) as f32, rgb[0], rgb[1], rgb[2], a, Mode::Alpha, (wid as f64 * w1.0) as f32, fade * a);
            };
            seg(c, 1.15, 1.15, 0.9, [0.92, 0.92, 0.9], min_f32(1.0, k * (0.22 + 0.5 * flare)), 1.0);
            for j in 0..3 {
                let nz = f_sin((12.9898 * i as f32 + 78.233 * j as f32) + 7.0 * clk);
                let f = (1.0 + 0.28 * f_abs(nz)) + 0.1 * j as f32;
                seg(c, f, f + 0.25 * f_abs(nz), 0.2 + 0.15 * f_abs(nz), [0.06, 0.06, 0.07], k * (0.6 - 0.15 * j as f32), 0.0);
            }
            seg(c, 0.83, 0.83, 0.4, [0.01, 0.01, 0.015], k, 1.0);
            seg(c, 0.5, 0.5, 0.42, [0.01, 0.01, 0.015], k, 1.0);
            seg(c, 0.17, 0.17, 0.4, [0.01, 0.01, 0.015], k, 1.0);
        }
    }
}
