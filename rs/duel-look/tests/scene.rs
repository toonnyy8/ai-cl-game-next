//! `Scene` as the sim's per-step sink (docs/bevy/M3A_NOTES.md §4): a CPU rollout leaves it and the cosmetic RNG alone (Review Focus 1),
//! and its clip players are the same per sim step whatever the rendered rate (Review Focus 3). Both fail without `$ORACLE` (the
//! traces' S lines, the draw key's fixed inputs).
use duel_look::{Scene, SceneInputs};
use duel_sim::components::Flow;
use duel_sim::cpu::Search;
use duel_sim::flow::{self, InRollout, NoInput};
use duel_sim::hashline::state_hash_line;
use duel_sim::look::LookSink;
use duel_sim::state::Match;
use duel_sim::time::STEP;

fn oracle() -> String {
    std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into())
}

fn data() -> &'static duel_data::Data {
    static D: std::sync::OnceLock<&'static duel_data::Data> = std::sync::OnceLock::new();
    D.get_or_init(|| Box::leak(Box::new(duel_data::Data::embedded())))
}

fn s_line(name: &str) -> Vec<i64> {
    let path = format!("{}/traces/{name}.trace", oracle());
    let f = std::fs::File::open(&path).unwrap_or_else(|e| panic!("{path}: {e} (set ORACLE)"));
    std::io::BufRead::lines(std::io::BufReader::new(f))
        .map(Result::unwrap)
        .find_map(|l| l.strip_prefix("S cmds ").map(|r| r.split(' ').map(|c| c.parse().unwrap()).collect()))
        .expect("a cmds trace")
}

/// The draw key's fixed inputs (INDEX.json: its first scene's viewport, `fixed_inputs.read_from_image`).
fn key_inputs() -> SceneInputs {
    let p = format!("{}/draw/INDEX.json", oracle());
    let j: serde_json::Value = serde_json::from_str(&std::fs::read_to_string(&p).unwrap_or_else(|e| panic!("{p}: {e}"))).unwrap();
    let vp = &j["scenes"][0]["viewport"];
    let read = j["fixed_inputs"]["read_from_image"][0].as_str().unwrap();
    let w: Vec<&str> = read.split(' ').collect(); // "render-scale 1.0 pixel-lights 8 scene-scale-cap 1.0 msaa 1 coarse NIL one-hand NIL"
    let val = |k: &str| w[w.iter().position(|x| *x == k).unwrap() + 1];
    SceneInputs {
        width: vp[0].as_u64().unwrap() as u32,
        height: vp[1].as_u64().unwrap() as u32,
        density: vp[2].as_f64().unwrap() as f32,
        msaa: val("msaa").parse().unwrap(),
        render_scale: val("render-scale").parse().unwrap(),
        pixel_lights: val("pixel-lights").parse().unwrap(),
        coarse: val("coarse") != "NIL",
        scene_scale_cap: val("scene-scale-cap").parse().unwrap(),
    }
}

/// Everything the Scene keeps, bit for bit: each model's slots and clip player (its clip by address), SLOW-SNAPSHOT's places, the
/// cinematic time scale, the cosmetic RNG's state.
fn digest(sc: &Scene) -> String {
    let mut out = String::new();
    for m in &sc.models {
        let a = &m.anim;
        let clip = a.clip.map_or("-", |c| sc.data.clips.iter().find(|(_, x)| std::ptr::eq(*x, c)).unwrap().0.as_str());
        let bits = |p: &[f32]| p.iter().map(|x| x.to_bits() as u64).fold(0u64, |h, b| h.wrapping_mul(1_000_003) ^ b);
        out += &format!(
            "{} {} {} {:?} {} {:?} {:?} clip {clip} t {:08x} v {:08x} b {:08x}/{:08x} pose {:x} from {:x};",
            m.e.0, m.body, m.weapon, m.hide, m.alpha.to_bits(), m.rim, m.rim_saved, a.time.to_bits(), a.speed.to_bits(),
            a.blend.to_bits(), a.blend_dur.to_bits(), bits(&a.pose), bits(&a.from)
        );
    }
    for (e, w) in &sc.slow_was {
        out += &format!("w{} {:?};", e.0, w.map(f32::to_bits));
    }
    out + &format!("k {:08x} rng {:08x}", sc.cine_time_scale.to_bits(), sc.cos.state())
}

/// A match from trace NAME's S line (a gate run: turbo, 120 steps a frame), turbo turned off after its commands' frame so each
/// frame runs the steps its dt owes.
fn start(name: &str, look: &mut dyn LookSink) -> (Match, Search) {
    let mut m = Match::new(data());
    flow::go_title(&mut m);
    m.cmds.extend(s_line(name));
    let mut s = Search::new();
    flow::frame_headless(&mut m, &mut s, &mut NoInput, look);
    m.turbo = false;
    (m, s)
}

/// Review Focus 1 (as tools/simgate/fulltest.lisp for the Lisp): cvc-ki-s1 (turbo off after its commands) run twice with a `Scene` sink, the second time with an
/// extra rollout of the oldest CPU job after every frame (from its own snapshot, on the scratch match, as MC-FULL-ROLL plays one),
/// through the first 3,000 frames: the Scene, its cosmetic RNG and the sim's state hash equal frame for frame, and the live queue is
/// the same after each extra rollout. A rollout's match pushes nothing (`Match::look`), its SIM-STEP-LEAN sinks into `NoLook`, and the
/// live Scene is never handed to it.
#[test]
fn rollout_leaves_scene_and_cosrng() {
    let d = data();
    let (mut ka, mut kb) = (Scene::new(d, key_inputs()), Scene::new(d, key_inputs()));
    let ((mut a, mut sa), (mut b, mut sb)) = (start("cvc-ki-s1", &mut ka), start("cvc-ki-s1", &mut kb));
    let mut extra = 0;
    for f in 0..3000 {
        flow::frame_headless(&mut a, &mut sa, &mut NoInput, &mut ka);
        flow::frame_headless(&mut b, &mut sb, &mut NoInput, &mut kb);
        if b.flow == Flow::Battle && !sb.mc_jobs.is_empty() && sb.mc_jobs[0].snap.is_some() {
            let (looks, before) = (b.looks.clone(), digest(&kb));
            let j = &sb.mc_jobs[0];
            let (e, dif, rng) = (j.e, j.dif, j.rng);
            let snap = sb.mc_jobs[0].snap.take().unwrap();
            let (mut sc, o) = duel_sim::cpu::mcts::rollout_start(&mut sb, &snap.0, rng, e, dif);
            sb.mc_jobs[0].snap = Some(snap);
            duel_sim::cpu::mcts::mc_full_rollout(&mut sc.0, &mut sb, &mut InRollout(&mut NoInput), e, o, 60, dif, true);
            assert!(sc.0.looks.v.is_empty(), "frame {f}: the rollout's match queued {:?}", sc.0.looks.v.first());
            duel_sim::cpu::mcts::rollout_end(&mut sb, sc, b.match_tick);
            assert_eq!((b.looks.clone(), digest(&kb)), (looks, before), "frame {f}: the extra rollout touched the looks");
            extra += 1;
        }
        assert_eq!(digest(&ka), digest(&kb), "frame {f}");
        assert_eq!(state_hash_line(&a), state_hash_line(&b), "frame {f}");
    }
    assert!(extra > 0 && sa.mc_stats[1] > 0, "no rollout ran: {extra} extra, {} in the match", sa.mc_stats[1]);
    // (not vacuous: the sink drove both fighters' clip players)
    assert_eq!(ka.models.len(), 2);
    assert!(ka.models.iter().all(|m| m.anim.clip.is_some() && m.anim.time > 0.0), "{}", digest(&ka));
}

/// Review Focus 3: cvc-ki-s1 (turbo off after its commands) rendered at 60, 120 and 30 Hz (`flow::frame` with dt = 1/60, 1/120 (a step every other frame), 1/30 (two
/// steps a frame; its frame pass included); CINE-DRAW unless turbo, `frame_end`, as `frame_headless` orders them): the Scene's clip players and
/// the sim's state hash equal at the same battle ticks, read inside the step's sink. The ticks are before the match's first cinematic
/// (a Kikon's DURING forms move actors once per rendered frame: DIVERGENCES §1, Task 10's check).
#[test]
fn frame_rate_120_and_30() {
    struct Probe<'d> {
        scene: Scene<'d>,
        at: &'static [i64],
        got: Vec<(i64, String, String)>,
        cine: bool,
    }
    impl LookSink for Probe<'_> {
        fn step(&mut self, m: &mut Match) {
            self.scene.step(m);
            self.cine |= m.flow == Flow::Battle && m.cine.is_some();
            if m.flow == Flow::Battle && self.at.contains(&m.match_tick) && !self.got.iter().any(|g| g.0 == m.match_tick) {
                self.got.push((m.match_tick, digest(&self.scene), state_hash_line(m)));
            }
        }
        fn frame(&mut self, m: &mut Match) {
            self.scene.frame(m);
        }
    }
    const AT: &[i64] = &[1, 300, 600, 900, 1200];
    let run = |dt: f32| {
        let mut p = Probe { scene: Scene::new(data(), key_inputs()), at: AT, got: vec![], cine: false };
        let (mut m, mut s) = start("cvc-ki-s1", &mut p);
        while p.got.len() < AT.len() {
            assert!(flow::frame(&mut m, &mut s, &mut NoInput, &mut p, dt), "{:?}", m.unported);
            if !m.turbo {
                duel_sim::cine::cine_draw(&mut m);
            }
            flow::frame_end(&mut m, &mut s);
        }
        assert!(!p.cine, "a cinematic before tick {}", AT[AT.len() - 1]);
        assert!(p.scene.models.len() == 2 && p.scene.models.iter().all(|x| x.anim.clip.is_some()));
        p.got
    };
    let r60 = run(STEP);
    assert_eq!(r60.iter().map(|g| g.0).collect::<Vec<_>>(), AT);
    assert_eq!(run(0.5 * STEP), r60, "120 Hz");
    assert_eq!(run(2.0 * STEP), r60, "30 Hz");
}
