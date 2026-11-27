//! port: duel/lisp/main.lisp SLOW-DRAW-BEGIN / SLOW-DRAW-END (91-121) — while the sim is slowed (not in a cinematic) each fighter and
//! hazard is drawn between its last two sim frames (SLOW-SNAPSHOT's `*slow-was*` and now) by `*slow-acc*`, each fighter's clip one sim
//! frame's share back in time; everything is put back after the frame's draw. The Lisp writes the drawn places into the sim's
//! slots and back; here they are an overlay (`SlowDraw.drawn`) the drawer reads through `Scene::drawn_pos` / `drawn_yaw`, so the
//! match is never written. The clips are the Scene's own and are moved and put back as in the Lisp.
use crate::scene::Scene;
use duel_sim::cl::{max_f32, min_f32};
use duel_sim::ecs::Entity;
use duel_sim::math::angle_wrap;
use duel_sim::state::Match;

/// `*slow-now*` (entity -> x y z yaw clip-time blend the frame drew over, made once per entity), `*slow-drawn*`, and the drawn
/// places (x y z yaw) while drawn.
#[derive(Clone, Debug, Default)]
pub struct SlowDraw {
    pub now: Vec<(Entity, [f32; 6])>,
    pub drawn: bool,
    pub at: Vec<(Entity, [f32; 4])>,
}

impl SlowDraw {
    pub fn with_reserve() -> SlowDraw {
        let n = duel_sim::consts::MAX_ENTITIES;
        SlowDraw { now: Vec::with_capacity(n), drawn: false, at: Vec::with_capacity(n) }
    }
    /// port: main.lisp SLOW-KEEP on `*slow-now*`: E's vector (made once).
    fn keep(&mut self, e: Entity) -> &mut [f32; 6] {
        let i = match self.now.iter().position(|n| n.0 == e) {
            Some(i) => i,
            None => {
                self.now.push((e, [0.0; 6]));
                self.now.len() - 1
            }
        };
        &mut self.now[i].1
    }
}

/// port: main.lisp SLOW-MIX — slot I's drawn value from the kept W toward NOW by A (the yaw, slot 3, the short way).
fn slow_mix(w: &[f32; 4], i: usize, now: f32, a: f32) -> f32 {
    w[i] + a * if i == 3 { angle_wrap(now - w[i]) } else { now - w[i] }
}

/// port: main.lisp SLOW-DRAW-BEGIN.
pub fn begin(sc: &mut Scene, m: &Match) {
    sc.slow.drawn = false;
    sc.slow.at.clear();
    if !(duel_sim::flow::sim_running_p(m) && m.cine.is_none() && m.time.slowmo_scale(false) < 1.0) {
        return;
    }
    let a = min_f32(1.0, max_f32(0.0, m.slow_acc));
    let back = (1.0 - a) * (1.0 / 60.0);
    for e in [m.p1, m.p2] {
        let Some(&(_, w)) = sc.slow_was.iter().find(|w| w.0 == e) else { continue };
        let Some(t) = m.transform.get(e) else { continue };
        let (p, yaw) = (t.pos, t.yaw);
        let at = [slow_mix(&w, 0, p[0], a), slow_mix(&w, 1, p[1], a), slow_mix(&w, 2, p[2], a), slow_mix(&w, 3, yaw, a)];
        let Some(model) = sc.models.iter_mut().find(|md| md.e == e) else { continue };
        let an = &mut model.anim;
        *sc.slow.keep(e) = [p[0], p[1], p[2], yaw, an.time, an.blend];
        an.time -= back * an.speed;
        if an.blend > 0.0 {
            an.blend = min_f32(an.blend_dur, an.blend + back);
        }
        sc.slow.at.push((e, at));
    }
    for (h, hz) in m.hazard.iter() {
        let Some(&(_, w)) = sc.slow_was.iter().find(|w| w.0 == h) else { continue };
        let (x, y, z, yaw) = (hz.x, hz.y, hz.z, hz.yaw);
        *sc.slow.keep(h) = [x, y, z, yaw, 0.0, 0.0];
        sc.slow.at.push((h, [slow_mix(&w, 0, x, a), slow_mix(&w, 1, y, a), slow_mix(&w, 2, z, a), slow_mix(&w, 3, yaw, a)]));
    }
    sc.slow.drawn = true;
}

/// port: main.lisp SLOW-DRAW-END — the clips put back (the places were only an overlay).
pub fn end(sc: &mut Scene, m: &Match) {
    if !sc.slow.drawn {
        return;
    }
    for e in [m.p1, m.p2] {
        let Some(&(_, n)) = sc.slow.now.iter().find(|n| n.0 == e) else { continue };
        if !sc.slow_was.iter().any(|w| w.0 == e) {
            continue;
        }
        if let Some(model) = sc.models.iter_mut().find(|md| md.e == e) {
            (model.anim.time, model.anim.blend) = (n[4], n[5]);
        }
    }
    sc.slow.at.clear();
    sc.slow.drawn = false;
}
