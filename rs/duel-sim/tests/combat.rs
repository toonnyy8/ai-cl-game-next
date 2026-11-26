//! Task 10: the hit / damage / settle checks of tests/duel-rules/core.lisp (BROKEN-SOULS, 293, 295-298) and sim.lisp (DEAL-DAMAGE's
//! Soul Break queue, SETTLE-KONPAKU: 43, 44, 45, 47), same values; and checks of combat.lisp's / gauges.lisp's writers no trace reaches
//! yet (every trace's first hit stops at a kit hook until Tasks 11-12): SP-ATK-HIT!, GAIN-GAUGES' split, DELAY-HIT's hazard.
use duel_data::Data;
use duel_sim::combat::{deal_damage, delay_hit, Queue};
use duel_sim::components::{Character, Cls, Form, KitId, MoveId, Phase, State};
use duel_sim::ecs::Entity;
use duel_sim::gauges::{dealt_real, gain_gauges, sp_atk_hit};
use duel_sim::round::settle_konpaku;
use duel_sim::rules::broken_souls;
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}

/// sim.lisp T-PAIR (spawned twice: the handles of a match after the title's pair, generation 1, as the traces print them).
fn t_pair(ka: Character, kb: Character) -> (Match, Entity, Entity) {
    let mut m = Match::new(data());
    m.picks = [ka, kb];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    duel_sim::flow::spawn_pair(&mut m, true, true);
    m.log_on = true;
    let (a, b) = (m.p1, m.p2);
    (m, a, b)
}

fn kit_move_id(m: &Match, ch: &str, form: &str, name: &str) -> MoveId {
    let kit = duel_sim::kit::find_kit(m.data, ch, form);
    duel_sim::fighter::id_of(m, duel_sim::kit::kit_move(m.data, kit, name).unwrap())
}

fn q<T: Copy, const N: usize>(xs: &[T]) -> Queue<T, N> {
    let mut out = Queue::default();
    for &x in xs {
        out.push(x);
    }
    out
}

fn v<T: Copy, const N: usize>(x: &Queue<T, N>) -> Vec<T> {
    x.iter().collect()
}

/// core.lisp 293, 295-298: BROKEN-SOULS — the order queued, a Kikon's victim without a Soul Break on top, the queues untouched. (The
/// Lisp's lists are pushed, newest first; the port's queues hold the order queued, so each list here is the Lisp's reversed.)
#[test]
fn broken_souls_core_lisp() {
    type K = (char, char, &'static str);
    let vic = |k: &K| k.1;
    let (kq0, sq0): (Queue<K, 2>, Queue<(char, char), 2>) = (q(&[]), q(&[]));
    let (kk, sb) = broken_souls(&kq0, &sq0, vic);
    assert!(kk.is_empty() && sb.is_empty()); // 293
    let kq: Queue<K, 2> = q(&[('a', 'b', "m1"), ('x', 'y', "m2")]);
    let sq: Queue<(char, char), 2> = q(&[('a', 'b'), ('b', 'a')]);
    let (kk, sb) = broken_souls(&kq, &sq0, vic);
    assert_eq!((v(&kk), v(&sb)), (vec![('a', 'b', "m1"), ('x', 'y', "m2")], vec![])); // 295
    let (kk, sb) = broken_souls(&kq0, &sq, vic);
    assert_eq!((v(&kk), v(&sb)), (vec![], vec![('a', 'b'), ('b', 'a')])); // 296 (a lethal trade: both, P1's first)
    let (kk, sb) = broken_souls(&q(&[('a', 'b', "m1")]), &sq, vic);
    assert_eq!((v(&kk), v(&sb)), (vec![('a', 'b', "m1")], vec![('b', 'a')])); // 297 (:b took the Kikon)
    assert_eq!((v(&kq), v(&sq)), (vec![('a', 'b', "m1"), ('x', 'y', "m2")], vec![('a', 'b'), ('b', 'a')])); // 298
}

/// sim.lisp 43, 44, 45, 47: DEAL-DAMAGE to 0 Reishi queues the Soul Break (and returns T); the dealt count (no grey: no binder);
/// SETTLE-KONPAKU of a Kikon taking his last Konpaku is the K.O.
#[test]
fn deal_damage_queues_the_soul_break() {
    let (mut m, a, b) = t_pair(Character::Ichigo, Character::Kenpachi);
    m.gauges.get_mut(a).unwrap().reishi = 5;
    assert!(deal_damage(&mut m, b, a, 7, 1)); // 43
    assert_eq!(m.soul_breaks.iter().collect::<Vec<_>>(), [(b, a)]); // 44
    let gb = m.gauges.get(b).unwrap();
    assert!(gb.dealt == 7 && dealt_real(&m, b) == 7 && gb.grey == 0); // 45
    assert_eq!(m.gauges.get(a).unwrap().reishi, 0);
    assert!(deal_damage(&mut m, b, a, 1, 1) && m.soul_breaks.len() == 1); // T again, queued once per victim
    m.gauges.get_mut(a).unwrap().konpaku = 2;
    m.fighter.get_mut(b).unwrap().kikon_n = 3;
    assert!(settle_konpaku(&mut m, b, a, false)); // 47
    let ga = m.gauges.get(a).unwrap();
    assert_eq!((ga.konpaku, ga.reishi, m.gauges.get(b).unwrap().kikons), (0, ga.reishi_max, 1));
    assert_eq!(m.log.last().map(|l| l.split_once("] ").unwrap().1), Some("P2 KIKON on P1: -2 konpaku, 0 left (BASE)"));
    assert_eq!(m.unported, None);
}

/// SP-ATK-HIT!: a J's damaging window gives `*sp-gain-j*` through PAY-GAUGES and logs `SP hit gain`; an NS gives nothing.
#[test]
fn sp_atk_hit_pays_a_j() {
    let (mut m, a, _) = t_pair(Character::Kenpachi, Character::Kenpachi);
    let k = m.knobs.clone();
    m.gauges.get_mut(a).unwrap().fs = 100.0;
    m.fighter.get_mut(a).unwrap().cls = Some(Cls::Na);
    sp_atk_hit(&mut m, a);
    let fs = m.gauges.get(a).unwrap().fs;
    assert_eq!(fs, 100.0 + k.sp_gain_j);
    assert_eq!(m.log.last().map(|l| l.split_once("] ").unwrap().1.to_string()), Some(format!("P1 SP hit gain {:.1} (fs {:.1})", k.sp_gain_j, fs)));
    let n = m.log.len();
    m.fighter.get_mut(a).unwrap().cls = Some(Cls::Ns);
    sp_atk_hit(&mut m, a);
    assert_eq!((m.gauges.get(a).unwrap().fs, m.log.len()), (fs, n));
}

/// GAIN-GAUGES: the dealer's Fighting Spirit by HIT-GAINS (dealt) into the awakening gauge, his SUBLIMATION by SUB-ATTACK-GAIN once the
/// gauge is full; the victim's flash-step and awakening by what he took. The siphoned split (xs 0, the gain to the siphon) needs a
/// binder (SIPHON-OF is NIL until Hisagi's bind, M4): checked on HIT-GAINS itself.
#[test]
fn gain_gauges_split() {
    let (mut m, a, b) = t_pair(Character::Kenpachi, Character::Ichigo);
    let k = m.knobs.clone();
    m.gauges.get_mut(b).unwrap().fs = 0.0;
    gain_gauges(&mut m, a, 100, 0, 1);
    gain_gauges(&mut m, b, 0, 100, 1);
    let (ga, gb) = (m.gauges.get(a).unwrap().clone(), m.gauges.get(b).unwrap().clone());
    assert_eq!((ga.awaken, ga.sub), (duel_sim::rules::awakening_gain(&k, 100, 0, 0), 0.0));
    assert_eq!(gb.awaken, duel_sim::rules::awakening_gain(&k, 0, 100, 0));
    assert_eq!(gb.fs, duel_sim::rules::combo_gain_mult(&k, 1) * 100.0 * k.fs_taken);
    m.gauges.get_mut(a).unwrap().awaken = k.awaken_max; // full: the attacking share goes to SUBLIMATION
    gain_gauges(&mut m, a, 100, 0, 1);
    let ga = m.gauges.get(a).unwrap();
    assert_eq!((ga.awaken, ga.sub), (k.awaken_max, duel_sim::rules::sub_attack_gain(&k, 100, 0, 1.0) * k.sub_gain));
    let (fs, aw, sfs) = duel_sim::rules::hit_gains(&k, 0, 100, true, 1.0, 1);
    assert_eq!((fs, aw), (0.0, 0.0)); // siphoned: nothing for him,
    assert_eq!(sfs, duel_sim::rules::combo_gain_mult(&k, 1) * 100.0 * k.fs_taken); // his flash-step to the siphon
}

/// DELAY-HIT: the victim held in a stagger LATER + *DELAY-HIT-HOLD* frames, and its :fx hazard exactly as cvc-kk-s1 prints it on the
/// step 千切 (KE-KR-SP) hit (trace line 45523): its defaults (SP T: spawned in an SP; size 0.5, life LATER + 1, no class) and the data.
#[test]
fn delay_hit_hazard_as_traced() {
    let (mut m, a, b) = t_pair(Character::Kenpachi, Character::Kenpachi);
    let sp = kit_move_id(&m, "kenpachi", "bankai", "ke-kr-sp");
    let f = m.fighter.get_mut(b).unwrap();
    (f.kit, f.form, f.state, f.mv, f.phase) =
        (Some(KitId { character: Character::Kenpachi, form: Form::Bankai }), Form::Bankai, State::Move, Some(sp), Some(Phase::Main));
    let (sx, sz) = (f32::from_bits(0x409A309B), f32::from_bits(0xC0B7B5AD));
    delay_hit(&mut m, b, a, 224, 6, Phase::Knockdown, 0, sx, sz, 0.0, 28, sp, false);
    let fa = m.fighter.get(a).unwrap();
    assert_eq!((fa.state, fa.phase, fa.stun), (State::Stun, Some(Phase::Stagger), 28 + m.knobs.delay_hit_hold));
    let line = duel_sim::hashline::bits_line(&m);
    assert_eq!(
        line.split_once(" |").unwrap().1,
        " :FX :P2 409A309B 00000000 C0B7B5AD 409A309B C0B7B5AD 00000000 00000000 3F000000 0 29 28 0 0 NIL NIL DELAY-HIT-HOOK \
         (256,224,6,:KNOCKDOWN,0,409A309B,C0B7B5AD,00000000,#m::KE-KR-SP,NIL) T NIL NIL 00000000 3F800000 -1 NIL"
    );
}

/// HIT-SYSTEM end to end on a hit no trace finishes before Tasks 11-12 (every kit's hit calls a hook: here Kenpachi's :armor /
/// :dmg-mult are taken out of a copy of the data): J1's window collected, judged :hit, APPLY-HIT's damage (HIT-DAMAGE of the kit's
/// mods), the flinch, the gauges, the SP hit gain, the hitstop, the window's bit, the opener's pull, the log lines in order.
#[test]
fn hit_system_lands_a_j1() {
    let mut d = Data::embedded();
    d.kits.kits.get_mut("kenpachi").unwrap().get_mut("base").unwrap().hooks.clear();
    let d: &'static Data = Box::leak(Box::new(d));
    let mut m = Match::new(d);
    m.picks = [Character::Kenpachi, Character::Kenpachi];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    m.log_on = true;
    let (a, b) = (m.p1, m.p2);
    m.transform.get_mut(a).unwrap().pos = [0.0, 0.0, 0.0];
    m.transform.get_mut(b).unwrap().pos = [1.5, 0.0, 0.0];
    duel_sim::cine::face_each_other(&mut m, a, b, None);
    let j1 = kit_move_id(&m, "kenpachi", "base", "ke-z-j1");
    duel_sim::fighter::start_move(&mut m, a, j1, None);
    m.fighter.get_mut(a).unwrap().sf = 9; // its window [9, 12)
    m.gauges.get_mut(a).unwrap().fs = 100.0;
    let fs0 = 100.0;
    m.log.clear();
    duel_sim::combat::hit_system(&mut m);
    assert_eq!(m.unported, None);
    let k = &m.knobs;
    let kit = duel_sim::kit::find_kit(d, "kenpachi", "base");
    let atk = duel_sim::kit::kit_atk_mods(k, kit, 0, duel_sim::rules::hit_px(k, 1.0, 0.0, 1.0, 1.0), None);
    let dmg = duel_sim::rules::hit_damage(k, 35, atk, duel_sim::kit::kit_def_mods(kit), 1, false, false);
    let stun = duel_sim::rules::hitstun(k, "flinch", false);
    let log: Vec<&str> = m.log.iter().map(|l| l.split_once("] ").unwrap().1).collect();
    let fs1 = fs0 + k.sp_gain_j;
    assert_eq!(log[..3], [
        format!("P1 KE-Z-J1 -> P2 HIT 35"),
        format!("P1 dealt {dmg}: flinch stun {stun}"),
        format!("P1 SP hit gain {:.1} (fs {fs1:.1})", k.sp_gain_j),
    ]);
    let (fa, fb, gb) = (m.fighter.get(a).unwrap(), m.fighter.get(b).unwrap(), m.gauges.get(b).unwrap());
    assert_eq!((fb.state, fb.phase, fb.stun, fb.combo_hits), (State::Stun, Some(Phase::Flinch), stun, 1));
    assert_eq!((gb.reishi, gb.taken_melee, m.gauges.get(a).unwrap().dealt), (gb.reishi_max - dmg, dmg, dmg));
    assert_eq!((fa.contact, fa.hits, fa.land_sf), (Some(duel_sim::components::Contact::Hit), 1, 9));
    assert_eq!(m.time.hitstop, duel_sim::cl::round_f32(4.0 * m.time.hitstop_mult));
    assert!(m.motion.get(a).unwrap().kb_left > 0); // J1, the string's opener: he closes in (*STRING-PULL-TO*)
    assert!(m.pending.is_empty() && m.kikons.is_empty() && m.soul_breaks.is_empty());
}
