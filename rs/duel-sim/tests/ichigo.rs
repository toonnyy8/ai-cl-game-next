//! Task 12: checks of Ichigo's hooks, hazards and cinematics on paths the eleven Ichigo traces do not reach (JUJISHO's cut, ZANZO's
//! echo, O's charge and burst, KESSA's catch and :ok, 血鎖's reel-in, the Shikai's stance branch, NUKI-GIRI's dash and KAGE-RENZAN's
//! cut), each against the native sim (build/simgate/duel.fas run by host ECL: the same setup, the values printed as bits), and his pure
//! rules. The traced paths (the NS3 clones, their replays and hits, the vanish, the waves, the seven cinematics) are proved by the
//! traces' bit-exact replay.
use duel_data::Data;
use duel_sim::components::{Button, Character, Form, HazardKind, Num, Phase, State, Sym};
use duel_sim::ecs::Entity;
use duel_sim::ichigo::clones::*;
use duel_sim::ichigo::hooks::*;
use duel_sim::state::Match;
use std::sync::OnceLock;

fn data() -> &'static Data {
    static D: OnceLock<Data> = OnceLock::new();
    D.get_or_init(Data::embedded)
}

/// The ECL harness's PAIR: C1 vs C2 at (-1.1 0.3) / (1.3 -0.2), facing, the log on; P1 in FORM.
fn pair(c1: Character, c2: Character, form: Form) -> (Match, Entity, Entity) {
    let mut m = Match::new(data());
    m.picks = [c1, c2];
    duel_sim::flow::spawn_pair(&mut m, true, true);
    m.log_on = true;
    let (a, b) = (m.p1, m.p2);
    m.transform.get_mut(a).unwrap().pos = [-1.1, 0.0, 0.3];
    m.transform.get_mut(b).unwrap().pos = [1.3, 0.0, -0.2];
    duel_sim::cine::face_each_other(&mut m, a, b, None);
    if form != Form::Base {
        assert!(duel_sim::gauges::set_form(&mut m, a, form));
    }
    ic(&mut m, a);
    m.log.clear();
    (m, a, b)
}

fn start(m: &mut Match, e: Entity, name: &str) {
    let kit = duel_sim::fighter::kit_of(m, e);
    let id = duel_sim::fighter::id_of(m, duel_sim::kit::kit_move(m.data, kit, name).unwrap());
    duel_sim::fighter::start_move(m, e, id, None);
}

/// (kind, x, z, yaw bits, life, size bits, hw (dmg, guard), look) of every hazard, in entity order.
type HzRow = (HazardKind, [u32; 3], i64, u32, Option<(i64, Option<Num>)>, Option<&'static str>);
fn hzs(m: &Match) -> Vec<HzRow> {
    m.hazard
        .iter()
        .map(|(_, h)| {
            (h.kind.unwrap(), [h.x.to_bits(), h.z.to_bits(), h.yaw.to_bits()], h.life, h.size.to_bits(), h.hw.as_ref().map(|w| (w.dmg, w.guard)), h.look.map(|l| l.0))
        })
        .collect()
}

fn tail(m: &Match) -> Vec<String> {
    m.log.iter().map(|l| l.split_once("] ").unwrap().1.to_string()).collect()
}

/// ICHIGO-JUJI's waves (life round(60 * 12 / 14) = 51, half-width 1.8, 150 / guard 22, :blade, class NS) and ICHIGO-CUT: P1's cross
/// wave cuts P2's (ECL: `P1 cuts WAVE`, one wave left, P1's).
#[test]
fn juji_waves_and_the_cut() {
    let (mut m, a, b) = pair(Character::Ichigo, Character::Ichigo, Form::Base);
    start(&mut m, a, "ic-n2c");
    start(&mut m, b, "ic-n2c");
    let look = Sym("ICHIGO-JUJI-LOOK");
    wave(&mut m, a, look);
    wave(&mut m, b, look);
    let w = |x, z, yaw| (HazardKind::Wave, [x, z, yaw], 51, 0x3FE66666, Some((150, Some(Num::I(22)))), Some("ICHIGO-JUJI-LOOK"));
    assert_eq!(hzs(&m), [w(0xBDF7D920, 0x3DC4B3A0, 0xBFAEC575), w(0x3EA45CAC, 0x3B8192A0, 0x3FE35A40)]);
    assert!(m.hazard.iter().all(|(_, h)| h.cls == Some(duel_sim::components::Cls::Ns) && h.hw.as_ref().unwrap().flags == [Sym(":BLADE")]));
    m.log.clear();
    cut(&mut m, a);
    assert_eq!(tail(&m), ["P1 cuts WAVE"]);
    assert_eq!(hzs(&m), [w(0xBDF7D920, 0x3DC4B3A0, 0xBFAEC575)]);
}

/// ZANZO (a 360-frame look timer) and ECHO-WATCH: J1 starts → its echo (ICE sf -10); 18 steps of ICHIGO-ECHO-HZ later it strikes J1's
/// window where he stood 10 steps ago (the ring's zeros here) at x0.5: dmg 15, guard 4.0, :sp T, classless, 3 frames.
#[test]
fn zanzo_echo_strikes_behind() {
    let (mut m, a, _) = pair(Character::Ichigo, Character::Kenpachi, Form::Kessa);
    hist_push(&mut m, a);
    zanzo_on(&mut m, a);
    start(&mut m, a, "ic-k-j1");
    echo_watch(&mut m, a);
    for _ in 0..18 {
        let echoes: Vec<Entity> =
            m.hazard.iter().filter(|(_, h)| h.hook.is_some_and(|s| s.0 == "ICHIGO-ECHO-HZ")).map(|(e, _)| e).collect();
        for h in echoes {
            duel_sim::hazards::hazard_step(&mut m, h);
        }
    }
    assert_eq!(tail(&m), ["P1 ZANZO", "P1 move IC-K-J1"]);
    let z = hzs(&m);
    assert_eq!(z[0], (HazardKind::Fx, [0xBF8CCCCD, 0x3E99999A, 0], 360, 0x3F800000, None, Some("ICHIGO-ZANZO-LOOK")));
    assert_eq!(z[1], (HazardKind::Fx, [0, 0, 0], 99999, 0x3F000000, None, Some("ICHIGO-ECHO-LOOK")));
    assert_eq!(z[2], (HazardKind::IcHit, [0, 0, 0], 3, 0x3F000000, Some((15, Some(Num::F(4.0)))), None));
    let s = m.hazard.iter().nth(2).unwrap().1;
    assert_eq!((s.sp, s.cls, &s.data), (true, None, &duel_sim::components::HzData::Kw(Sym(":ECHO"))));
    assert!(!ok(&m, a, "sp2") && ok(&m, a, "q")); // (SP2 refused while ZANZO runs)
}

/// NS3's two clones (at his sides, ICHIGO-NS-SLOT), KIKON-WORTH 3, ICHIGO-O-PRESS (both charge; worth 3, +60), and the charge's step
/// with no rush running: each runs at him and bursts (two ICHIGO-BURST-LOOKs where they reached), the clones gone.
#[test]
fn o_press_charges_and_bursts() {
    let (mut m, a, _) = pair(Character::Ichigo, Character::Kenpachi, Form::Kessa);
    ns_clone(&mut m, a, 1, Src::NsA);
    ns_clone(&mut m, a, -1, Src::NsB);
    let c = |x, z, yaw| (HazardKind::Fx, [x, z, yaw], 99999, 0x3F000000, None, Some("ICHIGO-CLONE-LOOK"));
    assert_eq!(hzs(&m), [c(0xBEC5B6C7, 0x3FA32FF7, 0xBF5A253A), c(0xBF55B95A, 0xBF60FCAE, 0xBFF0784D)]);
    assert_eq!(kikon_worth(&mut m, a), 3);
    o_press(&mut m, a);
    let f = m.fighter.get(a).unwrap();
    assert_eq!((f.kikon_n, f.dmg_bonus), (3, 60));
    duel_sim::hazards::hazard_system(&mut m);
    let b = |x, z| (HazardKind::Fx, [x, z, 0], 16, 0x3F800000, None, Some("ICHIGO-BURST-LOOK"));
    assert_eq!(hzs(&m), [b(0xBE4C5424, 0xBF2D44E9), b(0x3DECCF54, 0x3F5602D2)]);
    assert_eq!(tail(&m), ["P1 CLONE NS-A 1", "P1 CLONE NS-B 2", "P1 KAGE-UCHI clones 2 konpaku 3"]);
}

/// ICHIGO-CATCH: guard gauge 50 → 70, the staggered attacker held 40, hitstop 12, slow motion 0.4 for 0.3 s; ICHIGO-OK's parry price.
#[test]
fn catch_and_parry_price() {
    let (mut m, a, b) = pair(Character::Ichigo, Character::Kenpachi, Form::Kessa);
    m.gauges.get_mut(a).unwrap().gg = 50.0;
    let f = m.fighter.get_mut(b).unwrap();
    (f.state, f.stun) = (State::Stun, 32);
    catch(&mut m, a, b);
    assert_eq!((m.gauges.get(a).unwrap().gg, m.fighter.get(b).unwrap().stun, m.time.hitstop), (70.0, 40, 12));
    assert_eq!(m.time.slowmo[..3], [0.4, 0.3, 0.0]);
    assert_eq!(tail(&m), ["P1 PARRY CATCH gg 70"]);
    assert!(ok(&m, a, "sig"));
    m.gauges.get_mut(a).unwrap().gg = 9.0;
    assert!(!ok(&m, a, "sig"));
}

/// 血鎖's reel-in (the step-mode form on frames 89-99: 7 - 0.4 (cf - 88) m) at cf 95 and after it (cf 120: 2.6 m, its last).
#[test]
fn chain_kikon_reels_in() {
    use duel_sim::cine::{cine_step, start_cine, CineName};
    use duel_sim::ichigo::cine::IcCine;
    let (mut m, a, b) = pair(Character::Ichigo, Character::Kenpachi, Form::Kessa);
    start_cine(&mut m, CineName::Ichigo(IcCine::ChainKikon), a, b, None);
    let run_to = |m: &mut Match, cf| {
        while m.cine.as_ref().is_some_and(|c| c.cf < cf) {
            cine_step(m);
        }
    };
    let p = |m: &Match| {
        let t = m.transform.get(a).unwrap();
        [t.pos[0].to_bits(), t.pos[2].to_bits(), t.yaw.to_bits()]
    };
    run_to(&mut m, 95);
    assert_eq!(p(&m), [0xC033F32F, 0x3F28176F, 0xBFAEC576]);
    run_to(&mut m, 120);
    assert_eq!(p(&m)[..2], [0xBF9F679A, 0x3EA91A92]);
    assert!(IcCine::from_lisp("IC-KESSA-KIKON-CINE").is_some_and(|c| c.frames() == 192));
}

/// TSUKI-STEP: a human's J press (unmodified) at the stance's f6 starts RANGETSU (its :tsuki-j string), the press consumed; the turn
/// toward him as ECL's (whose CPU seat took the brain's branch, ICHIGO-AI-STANCE, to the same move).
#[test]
fn stance_j_branch() {
    let (mut m, a, _) = pair(Character::Ichigo, Character::Kenpachi, Form::Base);
    m.fighter.get_mut(a).unwrap().has_brain = false;
    start(&mut m, a, "ic-tsuki");
    m.fighter.get_mut(a).unwrap().sf = 6;
    m.pilot.get_mut(a).unwrap().vpad.stamp(Button::Quick as usize, false);
    tick(&mut m, a);
    let f = m.fighter.get(a).unwrap();
    assert_eq!((m.data.moves[f.mv.unwrap().0 as usize].name.as_str(), m.transform.get(a).unwrap().yaw.to_bits()), ("ic-tsuki-j", 0xBFAEC575));
    assert!(!m.ics.get(a).unwrap().dashed && !m.pilot.get(a).unwrap().vpad.pressed(Button::Quick as usize, None));
}

/// ICHIGO-HASTE-DASH (0.8 m past him over 12 frames, his facing from the fused sincosf) and KAGE-RENZAN's third cut (IC-K-RZ-B's window
/// at x1: 25 / guard 8.0, classless, his place, facing the opponent; the slash look on him, data 3).
#[test]
fn haste_dash_and_renzan() {
    let (mut m, a, _) = pair(Character::Ichigo, Character::Kenpachi, Form::Kessa);
    start(&mut m, a, "ic-k-j1");
    haste_dash(&mut m, a);
    let mo = m.motion.get(a).unwrap();
    assert_eq!((mo.kb[0].to_bits(), mo.kb[2].to_bits(), mo.kb_left), (0x3D85A9D9, 0xBC5EC5C1, 12));
    renzan(&mut m, a, "ic-k-rz-b", 3);
    let z = hzs(&m);
    assert_eq!(z[0], (HazardKind::IcHit, [0xBF8CCCCD, 0x3E99999A, 0xBFAEC575], 3, 0x3F000000, Some((25, Some(Num::F(8.0)))), None));
    assert_eq!(z[1], (HazardKind::Fx, [0x3FA66666, 0xBE4CCCCD, 0], 9, 0x3F800000, None, Some("ICHIGO-RENZAN-LOOK")));
    assert_eq!(m.hazard.iter().nth(1).unwrap().1.data, duel_sim::components::HzData::Int(3));
}

/// The pure rules (ichigo.lisp 389-405): CLONE-KONPAKU, CLONE-AFTER-STRING, CLONE-VANISH-P, CLONE-EVICT, ECHO-HITWIN.
#[test]
fn pure_rules() {
    use duel_sim::rules::Res;
    assert_eq!([-1, 0, 1, 2, 3, 9].map(clone_konpaku), [2, 2, 2, 3, 4, 4]);
    assert_eq!(
        [clone_after_string(true, 50), clone_after_string(false, 0), clone_after_string(false, 1)],
        [IccState::Fade, IccState::Fade, IccState::Idle]
    );
    assert!(clone_vanish_p(Some(Res::Hit)) && clone_vanish_p(Some(Res::Counter)) && !clone_vanish_p(Some(Res::Blocked)));
    assert!(!clone_vanish_p(None));
    assert_eq!((clone_evict(&[5, 3], 3), clone_evict(&[5, 3, 4], 3), clone_evict(&[3, 2, 2], 3)), (None, Some(1), Some(1)));
    let hw = &duel_sim::kit::find_move(data(), "ic-k-as1").unwrap().hits[0]; // (14, guard 22, :ranged)
    let w = echo_hitwin(hw, 0.7);
    assert_eq!((w.dmg, w.guard, w.react, w.flags.clone()), (10, Some(Num::F(0.7 * 22.0)), Phase::Flinch, vec![Sym(":BLADE"), Sym(":RANGED")]));
    assert_eq!(echo_hitwin(hw, 0.01).dmg, 1); // (at least 1)
}
