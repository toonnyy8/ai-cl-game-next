//! The look queue (docs/bevy/M3A_NOTES.md §4): what the sim tells the looks, per step, and that a rollout tells nothing. The checks
//! that need the look side's `Scene` are in rs/duel-look/tests/scene.rs; the 0-allocation one in rs/duel-tools (its counting
//! allocator).
use duel_sim::components::Flow;
use duel_sim::cpu::Search;
use duel_sim::flow::{self, NoInput};
use duel_sim::look::{Event, LookEvent, LookSink};
use duel_sim::state::Match;

fn data() -> &'static duel_data::Data {
    Box::leak(Box::new(duel_data::Data::embedded()))
}

/// The S line's commands of answer-key trace NAME (`$ORACLE/traces`); fails without the key.
fn s_line(name: &str) -> Vec<i64> {
    let dir = std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into());
    let path = format!("{dir}/traces/{name}.trace");
    let f = std::fs::File::open(&path).unwrap_or_else(|e| panic!("{path}: {e} (set ORACLE)"));
    std::io::BufRead::lines(std::io::BufReader::new(f))
        .map(Result::unwrap)
        .find_map(|l| l.strip_prefix("S cmds ").map(|r| r.split(' ').map(|c| c.parse().unwrap()).collect()))
        .expect("a cmds trace")
}

/// An event's kind: the variant's name (an EMIT's as `!Name`).
fn kind(ev: &LookEvent) -> String {
    let word = |s: String| s.split(|c: char| !c.is_alphanumeric()).next().unwrap().to_string();
    match ev {
        LookEvent::Emit(e) => format!("!{}", word(format!("{e:?}"))),
        LookEvent::Clip { e, clip, blend, .. } => format!("Clip {} {clip} {blend}", e.0),
        _ => word(format!("{ev:?}")),
    }
}

/// One step: (match tick, flow, the kinds the step's sink drained, the combat log lines of the step).
type Step = (i64, Flow, Vec<String>, Vec<String>);

#[derive(Default)]
struct Rec {
    steps: Vec<Step>,
}
impl LookSink for Rec {
    fn step(&mut self, m: &mut Match) {
        let kinds = m.looks.drain().map(|e| kind(&e)).collect();
        self.steps.push((m.match_tick, m.flow, kinds, std::mem::take(&mut m.log)));
    }
}

/// cvc-ki-s1 (Kenpachi P1 vs Ichigo P2, both CPUs thinking) run live from its S line until its K.O.: the per-step kinds at three
/// steps equal what the Lisp's calls in that step make, read off the sources (fighter.lisp, combat.lisp, round.lisp, cinema.lisp):
/// - a move start (tick 49: P2's IC-J1), a hit (tick 165: P1's KE-Z-AS1), the K.O. (tick 20918: KO-CINE starts), each commented
///   below with the calls it comes from. The K.O. is past the brief's 600 ticks: the match runs to tick 20918, so the test runs it to its end.
///
/// `LOOK_DUMP=a-b` prints the steps of battle ticks a..b (to re-derive the expectations).
#[test]
fn queue_order_matches_sites() {
    let mut m = Match::new(data());
    flow::go_title(&mut m);
    m.cmds.extend(s_line("cvc-ki-s1"));
    let (s, mut rec) = (&mut Search::new(), Rec::default());
    for _ in 0..200_000 {
        assert!(flow::frame_headless(&mut m, s, &mut NoInput, &mut rec), "{:?}", m.unported);
        m.log_on = true;
        if m.flow == Flow::Results {
            break;
        }
    }
    assert_eq!(m.flow, Flow::Results);
    if let Ok(r) = std::env::var("LOOK_DUMP") {
        let (a, b) = r.split_once('-').map(|(a, b)| (a.parse::<i64>().unwrap(), b.parse::<i64>().unwrap())).unwrap();
        for (t, f, k, l) in &rec.steps {
            if (a..=b).contains(t) && *f != Flow::Intro {
                println!("{t} {f} {k:?} {l:?}");
            }
        }
    }
    let at = |pred: &dyn Fn(&Step) -> bool| rec.steps.iter().find(|s| pred(s)).expect("the step");
    // the first move: P1's (Kenpachi), no hitstop, nothing else this step
    let mv = at(&|(_, f, _, l)| *f == Flow::Battle && l.iter().any(|l| l.contains(" move ")));
    // (SLOW-SNAPSHOT's start and its two fighters; P1 (Kenpachi, slot 0) backs off: NEUTRAL-WALK!'s :sh-walk-b, blend 6, every step;
    // P2's START-MOVE: IC-J1's :clip :ic-na1 at its :blend 0; each FIGHTER-STEP's ANIM-ADVANCE)
    assert_eq!(
        (mv.0, mv.2.as_slice()),
        (49, ["SlowSnapshot", "SlowKeep", "SlowKeep", "Clip 256 sh-walk-b 6", "AnimAdvance", "Clip 257 ic-na1 0", "AnimAdvance"].map(String::from).as_slice()),
        "move start: {:?}",
        mv.3
    );
    // the first hit dealt
    let hit = at(&|(_, f, _, l)| *f == Flow::Battle && l.iter().any(|l| l.contains(" dealt ")));
    // (P1's KE-Z-AS1, a pre-roll (an AS out of a cancel): its clip speed back on its hit pose (S 16), :swing on its window's first
    // frame (16), ANIM-ADVANCE; P2 in IC-J1's recovery: RECOVERY-PACE, ANIM-ADVANCE; HIT-SYSTEM: EMIT :hit after its hitstop, then
    // SET-REACTION's knockdown into the air (:sh-launch, blend 2; no :launch: a knockdown), then CORE-BREAK!'s :sp-break)
    assert_eq!(
        (hit.0, hit.2.as_slice()),
        (165, ["SlowSnapshot", "SlowKeep", "SlowKeep", "AnimSpeed", "!Swing", "AnimAdvance", "RecoveryPace", "AnimAdvance", "!Hit", "Clip 257 sh-launch 2", "!SpBreak"].map(String::from).as_slice()),
        "hit: {:?}",
        hit.3
    );
    // the K.O. (tick 20918): the last soul's cinematic's last frame (CINE-STEP: its look forms, both actors' clips advance), its end
    // (END-CINE's, CINE-END's looks, the actors' REFRESH-LOOK), then its AFTER, MATCH-OVER, starts KO-CINE (START-CINE, CINE-BEGIN,
    // frame 0's look forms)
    let ko = at(&|(_, f, k, _)| *f == Flow::Finish && k.iter().any(|k| k == "CineStart"));
    assert_eq!(
        ko.2,
        ["CineAt", "CineActorStep", "CineActorStep", "CineStop", "CineEndLook", "RefreshLook", "RefreshLook", "CineStart", "CineBegin", "CineAt"],
        "K.O. at tick {}: {:?}",
        ko.0,
        ko.3
    );
}

/// A rollout's match pushes nothing (`*in-rollout*`: no feedback in SIM-STEP-LEAN, its looks never happen), while the same steps on
/// the live match do: 40 steps of cvc-ki-s1's battle on a copy, once as the live match, once in a rollout.
#[test]
fn rollout_pushes_nothing() {
    struct Count(usize);
    impl LookSink for Count {
        fn step(&mut self, m: &mut Match) {
            self.0 += m.looks.drain().count();
        }
    }
    let mut m = Match::new(data());
    flow::go_title(&mut m);
    m.cmds.extend(s_line("cvc-ki-s1"));
    let s = &mut Search::new();
    while !(m.flow == Flow::Battle && m.match_tick >= 200) {
        flow::frame_headless(&mut m, s, &mut NoInput, &mut duel_sim::look::NoLook);
    }
    for (rollout, want_some) in [(false, true), (true, false)] {
        let mut r = m.clone();
        r.looks.v.reserve(duel_sim::look::LOOK_RESERVE);
        r.in_rollout = rollout;
        let mut c = Count(0);
        for _ in 0..40 {
            flow::sim_step(&mut r, &mut Search::new(), &mut NoInput, &mut c);
        }
        assert_eq!(c.0 > 0, want_some, "in_rollout {rollout}: {} looks", c.0);
    }
    // and a rollout's own steps leave the queue empty
    let mut r = m.clone();
    duel_sim::cpu::mcts::with_rollout(&mut r, true);
    r.look(LookEvent::Emit(Event::Reset));
    assert!(r.looks.v.is_empty());
}
