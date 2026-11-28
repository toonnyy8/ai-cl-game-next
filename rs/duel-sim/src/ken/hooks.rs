//! port: ken.lisp's hook functions (the kits' :hooks, the moves' frame / tick / release / land hooks). The EMITs are looks.
use crate::components::{Button, Contact, Form, HzData, MoveId, Phase, State, Sym};
use crate::ecs::Entity;
use crate::fighter::{callout, fighter, fighter_mut, id_of, kit_of, mv, pos_of, side_name, start_move, to_idle, yaw_of};
use crate::math::{fwd_x, fwd_z};
use crate::rules::Res;
use crate::state::Match;
use duel_data::Move;

// ---------------------------------------------------------------- the kits' :hooks

/// port: KEN-ARMOR (:armor, OWN-ARMOR-P): NS2's armour (:armor-hits, spent in COMBAT) lasts through the active frames.
pub fn armor(m: &Match, e: Entity, mvd: &Move) -> bool {
    let f = fighter(m, e);
    mvd.params.armor_act
        && f.armor_left > 0
        && f.phase == Some(Phase::Main)
        && m.knobs.armor_from <= f.sf
        && f.sf < (mvd.s + mvd.a) as i64
}

/// port: KEN-DMG-MULT (:dmg-mult, APPLY-HIT): the Shikai's burst hits its damage by the route's level (FIGHTER-LV-CAP), else 1.0.
/// HW-DMG is the window's damage.
pub fn dmg_mult(m: &mut Match, att: Entity, hw_dmg: i64, mvd: Option<&Move>, hazard: bool) -> f32 {
    match mvd.filter(|_| !hazard).and_then(|x| x.params.burst) {
        Some(b) if hw_dmg > 0 => {
            let lv = fighter(m, att).lv_cap;
            let d = b[0.max(lv.min(b.len() as i64 - 1)) as usize];
            crate::clog!(m, "{} BURST {} (L{})", side_name(m, att), d, lv);
            d as f32 / hw_dmg as f32 // ((/ d (float (hw-dmg hw))): a fixnum over a single)
        }
        _ => 1.0,
    }
}

/// port: KEN-LV (:lv, CORE-SNAP-LV!): the unlock level L, held in the kit meter.
pub fn lv(m: &Match, e: Entity) -> i64 {
    crate::cl::round_f32(m.gauges.get(e).expect("gauges").meter)
}

/// port: KEN-LINK-OK (:link-ok, a J link as it starts): J4-J7 (:params :lv 3) only at L3.
pub fn link_ok(m: &Match, e: Entity, next: &Move) -> bool {
    next.params.lv.map_or(0, i64::from) <= lv(m, e)
}

/// port: KEN-HIT (:hit, APPLY-HIT): the first clean hit of an NS segment, or of an AS that keeps the pointer (:lv-up), raises L by
/// one (up to *KEN-LV-MAX*); once a combo (the victim's first hit starts a new one).
pub fn hit(m: &mut Match, att: Entity, def: Entity, res: Res, mvd: Option<&Move>, hazard: bool) {
    let clean = matches!(res, Res::Hit | Res::Counter);
    if clean && fighter(m, def).combo_hits <= 1 {
        fighter_mut(m, att).lv_got = false; // a new combo
    }
    let f = fighter(m, att);
    if let Some(x) = mvd
        && !hazard
        && clean
        && !f.lv_got
        && (f.cls == Some(crate::components::Cls::Ns) || x.params.lv_up)
    {
        fighter_mut(m, att).lv_got = true;
        if lv(m, att) < m.knobs.ken_lv_max {
            let l = lv(m, att);
            m.gauges.get_mut(att).expect("gauges").meter = (1 + l) as f32;
            crate::clog!(m, "{} L{}", side_name(m, att), lv(m, att));
        }
    }
}

/// port: KEN-AS-PICK (:as-pick, CORE-AS-START!, N the press count's AS): SP after J7 = the Bankai's burst AS (:bankai-as), after J4-J6
/// = the pointer's special AS (:special-as), an AS that writes the other pointer = the burst to it (L back to 0); else None: the
/// pointer's AS. Some((move, the pointer it writes: None = kept)).
pub fn as_pick(m: &mut Match, e: Entity, n: i64) -> Option<(MoveId, Option<i64>)> {
    let f = fighter(m, e);
    let p = f.mv.map(|id| &mv(m, id).params);
    let cur = f.ptr;
    let kit = kit_of(m, e);
    let nth_as = |m: &Match, i: i64| -> MoveId {
        let x = crate::kit::kit_move(m.data, kit, &kit.core.as_segs[i as usize]).expect("an AS of the kit");
        id_of(m, x)
    };
    if p.is_some_and(|p| p.bankai_as) {
        Some((nth_as(m, 6), None)) // the Bankai's burst AS: the reiatsu detonating, then the form
    } else if p.is_some_and(|p| p.special_as) {
        Some((nth_as(m, 3 + cur), None))
    } else if n != cur {
        m.gauges.get_mut(e).expect("gauges").meter = 0.0;
        crate::clog!(m, "{} BURST to pointer {} (L{})", side_name(m, e), n, fighter(m, e).lv_cap);
        Some((nth_as(m, 1 + n), Some(n)))
    } else {
        None
    }
}

/// port: KEN-BK-TICK (the Bankai kits' :tick, GAUGE-SYSTEM): the special AS over (out of :move and :cine), back to the Shikai on the
/// pointer he came from, L 0, -1 Konpaku unless it is his last.
pub fn bk_tick(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    if !(f.bk_out && !matches!(f.state, State::Move | State::Cine)) {
        return;
    }
    let from = if f.form == Form::Bankai2 { 2 } else { 1 };
    fighter_mut(m, e).bk_out = false;
    let g = m.gauges.get_mut(e).expect("gauges");
    if g.konpaku > 1 {
        g.konpaku -= 1;
        m.emit(crate::look::Event::Konpaku { victim: e, lost: 1 }); // look: emit :konpaku
    }
    if !crate::gauges::set_form(m, e, Form::Nozarashi) {
        return;
    }
    fighter_mut(m, e).ptr = from;
    m.gauges.get_mut(e).expect("gauges").meter = 0.0;
    if fighter(m, e).state == State::Idle {
        to_idle(m, e, 0.0);
    }
    let k = m.gauges.get(e).expect("gauges").konpaku;
    crate::clog!(m, "{} BANKAI ends: Shikai pointer {}, konpaku {}", side_name(m, e), from, k);
}

// ---------------------------------------------------------------- the moves' frame hooks

/// port: KEN-BK-COST: a Bankai NS / AS segment's frame 0: *KEN-BK-COST* of his Reishi burnt, never below 1.
pub fn bk_cost(m: &mut Match, e: Entity) {
    let c = m.knobs.ken_bk_cost;
    let g = m.gauges.get_mut(e).expect("gauges");
    g.reishi = crate::rules::burn(g.reishi, c);
    let r = g.reishi;
    crate::clog!(m, "{} bankai cost {}, reishi {}", side_name(m, e), c, r);
}

/// port: KEN-BK-SPECIAL: the special AS's frame 0: its cost, and the way back to the Shikai once it is over (KEN-BK-TICK).
pub fn bk_special(m: &mut Match, e: Entity) {
    bk_cost(m, e);
    fighter_mut(m, e).bk_out = true;
}

/// port: KEN-CHIGIRI-OPEN: 千切's draw (a look hazard: its entity is sim state).
pub fn chigiri_open(m: &mut Match, e: Entity) {
    let life = m.knobs.chigiri_burst + 4;
    crate::hazards::spawn_look(m, e, Sym("KEN-CHIGIRI-LOOK"), None, None, 0.0, 1.0, life, 0, HzData::Nil);
    m.emit(crate::look::Event::KenBkBurst { e, kind: "chigiri-draw" }); // look: emit :ken-bk-burst :chigiri-draw
}

/// port: KEN-CHIGIRI-BURST: the fight frozen *KEN-CHIGIRI-STOP* frames (the damage lands on this frame: :dmg-at, DELAY-HIT).
pub fn chigiri_burst(m: &mut Match, e: Entity) {
    let s = m.knobs.ken_chigiri_stop as f32;
    m.time.hitstop(s);
    m.emit(crate::look::Event::KenBkBurst { e, kind: "chigiri" }); // look: emit :ken-bk-burst :chigiri
}

/// port: KEN-TATEGOTO-SPLIT: TATE-GOTO's chop lands: the rift 2.2 m before him, the sword wave, the floor split (look hazards).
pub fn tategoto_split(m: &mut Match, e: Entity) {
    let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
    let (x, z) = (p[0] + 2.2 * fwd_x(yaw), p[2] + 2.2 * fwd_z(yaw));
    let life = m.knobs.tategoto_cut + 2;
    crate::hazards::spawn_look(m, e, Sym("KEN-TATEGOTO-LOOK"), Some(x), Some(z), 0.0, 1.0, life, 0, HzData::Nil);
    crate::hazards::spawn_look(m, e, Sym("KEN-TATEGOTO-WAVE"), None, None, yaw, 1.0, 14, 0, HzData::Nil);
    let len = m.knobs.tategoto_wave_len;
    crate::hazards::spawn_ground_line(m, e, len, 70, Sym(":METEOR"));
    m.emit(scar(p[0], p[2], yaw, &[1.9, 4.0, 6.5, 9.0, 11.5, 14.0], 0.9)); // look: emit :ground-scar
    m.emit(crate::look::Event::KenBkBurst { e, kind: "tategoto" }); // look: emit :ken-bk-burst :tategoto
}

/// port: KEN-TATEGOTO-CUT: the rift cuts, frozen *KEN-TATEGOTO-STOP* frames.
pub fn tategoto_cut(m: &mut Match, e: Entity) {
    let s = m.knobs.ken_tategoto_stop as f32;
    m.time.hitstop(s);
    m.emit(crate::look::Event::KenBkBurst { e, kind: "tategoto-cut" }); // look: emit :ken-bk-burst :tategoto-cut
}

/// port: KEN-BANKAI-ENTER: the Bankai's burst AS, 3 frames after the detonation: the Bankai of his pointer, no cinematic, nothing
/// restored.
pub fn bankai_enter(m: &mut Match, e: Entity) {
    let cur = fighter(m, e).ptr;
    crate::clog!(m, "{} BANKAI from pointer {}", side_name(m, e), cur);
    crate::gauges::bankai(m, e, if cur == 2 { Form::Bankai2 } else { Form::Bankai }, false, false);
}

/// port: KEN-STANCE-RELEASE: the stance's cut deals 100 + stored, guard-crushing at stored >= 150.
pub fn stance_release(m: &mut Match, e: Entity) {
    let (dmg, crush) = crate::rules::stance_release(&m.knobs, fighter(m, e).stored);
    let base = m.knobs.stance_base_damage;
    let f = fighter_mut(m, e);
    (f.dmg_bonus, f.crush, f.stored) = (dmg - base, crush, 0);
    if crush {
        callout(m, e, "KITTE MIRO YO!");
    }
    m.emit(crate::look::Event::Sfx { key: if crush { "laugh" } else { "whoosh-heavy" }, e }); // look: emit :sfx
}

/// port: KEN-GROUND-CRACK: Buttagiru lands: a 3.5 m crack (a look hazard).
pub fn ground_crack(m: &mut Match, e: Entity) {
    let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
    crate::hazards::spawn_ground_line(m, e, 3.5, 50, Sym(":CRACK"));
    m.emit(scar(p[0], p[2], yaw, &[1.2, 2.8], 0.9)); // look: emit :ground-scar
    m.emit(crate::look::Event::Sfx { key: "ground-crack", e }); // look: emit :sfx :ground-crack
}

/// `(:ground-scar x z yaw ds r)` with DS (at most six).
fn scar(x: f32, z: f32, yaw: f32, ds: &[f32], r: f32) -> crate::look::Event {
    let mut a = [0.0; 6];
    a[..ds.len()].copy_from_slice(ds);
    crate::look::Event::GroundScar { x, z, yaw, ds: a, n: ds.len() as u8, r }
}

/// port: KEN-BK-SLAM: 斬壞's J5 lands: a short crack (a look hazard).
pub fn bk_slam(m: &mut Match, e: Entity) {
    crate::hazards::spawn_ground_line(m, e, 2.4, 40, Sym(":CRACK"));
    let (p, yaw) = (pos_of(m, e), yaw_of(m, e));
    m.emit(scar(p[0], p[2], yaw, &[1.9], 0.7)); // look: emit :ground-scar
    m.emit(crate::look::Event::Sfx { key: "ground-crack", e }); // look: emit :sfx :ground-crack
}

/// port: KEN-CHARGE-TICK: SP2's dash at :dash-speed through the active frames until it touches; the button still down as the dash
/// starts = guard-crushing.
pub fn charge_tick(m: &mut Match, e: Entity) {
    let f = fighter(m, e);
    let mvd = mv(m, f.mv.expect("the charge"));
    if f.phase != Some(Phase::Main) {
        return;
    }
    let (s, a, sf) = (mvd.s as i64, mvd.a as i64, f.sf);
    let down = f.button.is_some_and(|b: Button| m.pilot.get(e).expect("a pilot").vpad.down(b as usize));
    if sf == s && down {
        fighter_mut(m, e).crush = true;
    }
    let f = fighter(m, e);
    if s <= sf && sf < s + a && f.contact.is_none() && f.dist > 1.2 {
        let (sp, yaw) = (mvd.params.dash_speed.expect("a :dash-speed"), yaw_of(m, e));
        let v = &mut m.motion.get_mut(e).expect("a motion").vel;
        (v[0], v[2]) = (sp * fwd_x(yaw), sp * fwd_z(yaw));
    }
}

/// port: KEN-FLURRY (:on-land): the charge connected: on a hit, the flurry (its :land string).
pub fn flurry(m: &mut Match, e: Entity) {
    if fighter(m, e).contact != Some(Contact::Hit) {
        return;
    }
    let n = crate::kit::kit_next(m.data, kit_of(m, e), "ke-charge", "land").expect("the charge's :land string");
    let id = id_of(m, n);
    start_move(m, e, id, None);
    let f = fighter_mut(m, e);
    (f.contact, f.land_sf) = (Some(Contact::Hit), 0);
}
