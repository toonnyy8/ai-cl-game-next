//! port: engine/lisp/anim.lisp — clip sampling and the per-entity player with its crossfade; and the kit readers that pick which
//! clip a fighter plays (duel/lisp/kit.lisp KIT-MOVE-CLIP, duel/lisp/fighter.lisp FIGHTER-STANCE-CLIP). Clips come from duel-data
//! (built by DEFCLIP / DEFSTRIKE / DEFCLIP-MIRROR in the image); nothing here builds one.
use duel_data::Clip;
use duel_sim::math::f_max;

/// +POSE-N+: joint j at [3j] flex, [3j+1] twist, [3j+2] side; [63..66] root r u f, [66] root yaw, [67] root pitch.
pub const POSE_N: usize = 68;
/// +ROOT+.
pub const ROOT: usize = 63;
pub type Pose = [f32; POSE_N];

/// port: engine/lisp/anim.lisp CLIP-SAMPLE! — CLIP at T seconds (a loop wraps, a one-shot clamps) into OUT. KEY_EASE is *KEY-EASE*:
/// 0 smoothstep between keys (the engine default, the host tests' load), else ease-out cubic (the game's 1); a :snap key is linear.
pub fn sample(clip: &Clip, t: f32, key_ease: u8, out: &mut Pose) {
    let times = &clip.times;
    let n = times.len();
    let dur = clip.dur;
    let mut tm = t;
    if clip.looping {
        tm = duel_sim::math::f_mod(tm, dur);
        if tm < 0.0 {
            tm += dur;
        }
    }
    if n == 1 || tm <= times[0] {
        out.copy_from_slice(&clip.poses[0][..POSE_N]);
    } else if tm >= times[n - 1] {
        out.copy_from_slice(&clip.poses[n - 1][..POSE_N]);
    } else {
        let mut i = 0;
        while i + 2 < n && tm >= times[i + 1] {
            i += 1;
        }
        let (t0, t1) = (times[i], times[i + 1]);
        let u = (tm - t0) / f_max(1e-5, t1 - t0);
        let w = if clip.snaps[i + 1] > 0.5 {
            u
        } else if key_ease > 0 {
            1.0 - (1.0 - u) * (1.0 - u) * (1.0 - u)
        } else {
            u * u * (3.0 - 2.0 * u)
        };
        let (a, b) = (&clip.poses[i], &clip.poses[i + 1]);
        for c in 0..POSE_N {
            out[c] = a[c] + w * (b[c] - a[c]);
        }
    }
}

/// port: engine/lisp/package.lisp F-WRAP — an angle into [-pi, pi) with the C literals of its c-inline (not ANGLE-WRAP).
#[allow(clippy::approx_constant, clippy::excessive_precision)] // (the C text's literals, as written)
pub fn f_wrap(a: f32) -> f32 {
    a - 6.2831853f32 * ((a + 3.14159265f32) * 0.15915494f32).floor()
}

/// port: engine/lisp/anim.lisp DEFSTRUCT ANIM — a model's clip player: the clip, its time and speed, the crossfade left and its
/// length (seconds), the pose faded from, the pose out, a scratch pose.
#[derive(Clone, Debug)]
pub struct Anim<'d> {
    pub clip: Option<&'d Clip>,
    pub time: f32,
    pub speed: f32,
    pub blend: f32,
    pub blend_dur: f32,
    pub from: Pose,
    pub pose: Pose,
    pub tmp: Pose,
}

impl Default for Anim<'_> {
    fn default() -> Self {
        Anim { clip: None, time: 0.0, speed: 1.0, blend: 0.0, blend_dur: 0.0, from: [0.0; POSE_N], pose: [0.0; POSE_N], tmp: [0.0; POSE_N] }
    }
}

impl<'d> Anim<'d> {
    /// port: engine/lisp/anim.lisp ANIM-PLAY — start CLIP with a crossfade of BLEND frames (60 Hz; 0 = snap) from the current pose
    /// (its root yaw and pitch wrapped, so a spun pose fades the short way). RESTART false keeps a clip already playing; the speed
    /// is set either way. (The Lisp's keyword defaults: blend 4, speed 1, time 0, restart T.)
    pub fn play(&mut self, clip: &'d Clip, blend: f32, speed: f32, time: f32, restart: bool) {
        if !(!restart && self.clip.is_some_and(|c| std::ptr::eq(c, clip))) {
            self.from = self.pose;
            self.from[ROOT + 3] = f_wrap(self.from[ROOT + 3]);
            self.from[ROOT + 4] = f_wrap(self.from[ROOT + 4]);
            self.clip = Some(clip);
            self.time = time;
            self.blend_dur = blend / 60.0;
            self.blend = blend / 60.0;
        }
        self.speed = speed;
    }

    /// port: engine/lisp/anim.lisp ANIM-ADVANCE — the time by DT x speed, the crossfade down by DT (a +0 blend stays +0).
    pub fn advance(&mut self, dt: f32) {
        self.time += dt * self.speed;
        let bl = self.blend;
        if !(bl == 0.0 && dt > 0.0 && !bl.is_sign_negative()) {
            self.blend = f_max(0.0, bl - dt);
        }
    }

    /// port: engine/lisp/anim.lisp ANIM-EVAL — the current clip sampled (KEY_EASE as SAMPLE), smoothstep-faded from FROM while
    /// the crossfade runs, into `pose`. No clip: the pose stays as it is.
    pub fn eval(&mut self, key_ease: u8) -> &Pose {
        let (bl, bd) = (self.blend, self.blend_dur);
        if let Some(clip) = self.clip {
            sample(clip, self.time, key_ease, &mut self.tmp);
            if bl > 0.0 && bd > 0.0 {
                let u = 1.0 - bl / bd;
                let w = u * u * (3.0 - 2.0 * u);
                for c in 0..POSE_N {
                    let a = self.from[c];
                    self.pose[c] = a + w * (self.tmp[c] - a);
                }
            } else {
                self.pose = self.tmp;
            }
        }
        &self.pose
    }
}

// (the clip choices are pure kit readers the sim's look sites use: duel-sim owns them)
pub use duel_sim::kit::{fighter_stance_clip, kit_move_clip};
