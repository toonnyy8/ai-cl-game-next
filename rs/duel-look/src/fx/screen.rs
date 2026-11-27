//! port: duel/lisp/cinema.lisp's screen punctuation that the fight's events start (IMPACT-FRAME, FOCUS-LINES, UI-FLASH, BACK-RIM,
//! SCREEN-FX-UPDATE, SCREEN-FX-CLEAR) and engine/lisp/fx.lisp SHAKE. `*screen-fx*` is `DrawState.screen_fx`.
use crate::draw::DrawState;
use crate::scene::SoundReq;

/// `*impact-presets*` (cinema.lisp, from tuning.json): kind -> GRADE-IMPACT's mode and its 10 parameters.
pub struct Presets(Vec<(String, i32, [f32; 10])>);

impl Presets {
    pub fn new(d: &duel_data::Data) -> Presets {
        let rows = d.tuning["*IMPACT-PRESETS*"].as_array().expect("tuning *IMPACT-PRESETS*");
        Presets(
            rows.iter()
                .map(|r| {
                    let r = r.as_array().unwrap();
                    let f = |v: &duel_data::tuning::Value| v.as_f64().unwrap() as f32;
                    // GRADE-IMPACT's keyword defaults: threshold 0.4, keep-sat 0.45, keep-hue 10, keep-hue-2 = keep-hue, ink, paper
                    let (mut th, mut ks, mut kh, mut kh2) = (0.4, 0.45, 10.0, None);
                    let (mut ink, mut paper) = ([0.031f32, 0.031, 0.047], [1.0f32, 1.0, 1.0]);
                    for kv in r[2..].chunks(2) {
                        match kv[0].as_str().unwrap() {
                            "threshold" => th = f(&kv[1]),
                            "keep-sat" => ks = f(&kv[1]),
                            "keep-hue" => kh = f(&kv[1]),
                            "keep-hue-2" => kh2 = Some(f(&kv[1])),
                            "ink" => ink = [0, 1, 2].map(|i| f(&kv[1][i])),
                            "paper" => paper = [0, 1, 2].map(|i| f(&kv[1][i])),
                            k => panic!("*IMPACT-PRESETS* keyword {k}"),
                        }
                    }
                    let p = [th, ks, kh, ink[0], ink[1], ink[2], paper[0], paper[1], paper[2], kh2.unwrap_or(kh)];
                    (r[0].as_str().unwrap().to_string(), r[1].as_i64().unwrap() as i32, p)
                })
                .collect(),
        )
    }
}

/// port: cinema.lisp IMPACT-FRAME — the preset KIND's grade for FRAMES 60 Hz frames.
pub fn impact_frame(d: &mut DrawState, kind: &str, frames: f32) {
    let (_, mode, p) = d.presets.0.iter().find(|r| r.0 == kind).unwrap_or_else(|| panic!("no impact preset {kind}"));
    d.post.grade_impact = *mode;
    d.post.impact_params = *p;
    d.screen_fx[0] = frames / 60.0;
}

/// port: cinema.lisp FOCUS-LINES — ink focus lines for FRAMES 60 Hz frames. task 8: the centre on a world point (WORLD-TO-SCREEN)
/// is the canvas's; it stays the screen centre (-1) here.
pub fn focus_lines(d: &mut DrawState, frames: f32) {
    (d.screen_fx[1], d.screen_fx[4], d.screen_fx[5]) = (frames / 60.0, -1.0, -1.0);
}

/// port: cinema.lisp BACK-RIM — both fighters silhouetted with a hard back-rim for FRAMES.
pub fn back_rim(d: &mut DrawState, frames: f32) {
    d.screen_fx[3] = frames / 60.0;
    d.env.toon_threshold = 1.5;
    d.env.cin_rim = [0.91, 0.93, 0.96];
}

/// port: cinema.lisp BACK-RIM-END.
fn back_rim_end(d: &mut DrawState) {
    d.env.toon_threshold = 0.5;
    d.env.cin_rim = [0.0; 3];
}

/// port: cinema.lisp SCREEN-FX-UPDATE — run the punctuation down by DT effect seconds; end what ran out (the silence's end is a
/// sound request). task 8: a cinematic's base grade (`*cine-grade*`) coming back.
pub fn screen_fx_update(d: &mut DrawState, sounds: &mut Vec<SoundReq>, dt: f32) {
    let f = &mut d.screen_fx;
    let mut run = |i: usize| {
        let was = f[i];
        f[i] = duel_sim::cl::max_f32(0.0, was - dt);
        was > 0.0 && f[i] <= 0.0
    };
    let (g, _, _, _, s, r) = (run(0), run(1), run(6), run(7), run(2), run(3));
    if g {
        d.post.grade_impact(0);
    }
    if s {
        crate::scene::push_sound(sounds, SoundReq::SilenceEnd);
    }
    if r {
        back_rim_end(d);
    }
}

/// port: cinema.lisp SCREEN-FX-CLEAR.
pub fn screen_fx_clear(d: &mut DrawState, sounds: &mut Vec<SoundReq>) {
    if d.screen_fx[2] > 0.0 {
        crate::scene::push_sound(sounds, SoundReq::SilenceEnd);
    }
    d.screen_fx = [0.0; 8];
    d.post.grade_impact(0);
    back_rim_end(d);
}

/// port: engine/lisp/fx.lisp SHAKE — AMP metres decaying over DUR s; the larger amplitude wins.
pub fn shake(d: &mut DrawState, amp: f32, dur: f32) {
    let (s, amp) = (&mut d.cam.shake, amp * d.knobs.shake_mult);
    let cur = if s[1] > 0.0 { s[0] * (s[2] / s[1]) } else { 0.0 };
    if amp >= cur {
        (s[0], s[1], s[2]) = (amp, dur, dur);
    }
}
