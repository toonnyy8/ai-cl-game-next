//! The per-step lines of the answer key: H (duel/lisp/gate.lisp STATE-HASH-LINE) and B (tools/port/oracle/trace.lisp
//! TR-B-LINE / TR-B-ENC). B values: single-float 8 hex digits of its bits, double 16, integer decimal, T / NIL, a keyword
//! `:NAME`, a string `"…"` (spaces as `_`), a move `#m::NAME`, a kit `#k::CHAR/:FORM`, a struct `#TYPE{a,b}`, a list `(a,b)`,
//! a vector `[a,b]`, a kit component the fighter lacks `:ABSENT`, a handle its raw integer, a hazard owner `:P1` / `:P2`.
use crate::cl::round_f32;
use crate::components::*;
use crate::ecs::Entity;
use crate::state::Match;
use duel_data::Data;
use std::fmt::Write;

/// One B value (TR-B-ENC), written without spaces.
pub trait Enc {
    fn enc(&self, d: &Data, s: &mut String);
}

impl Enc for f32 {
    fn enc(&self, _: &Data, s: &mut String) {
        write!(s, "{:08X}", self.to_bits()).unwrap();
    }
}
impl Enc for f64 {
    fn enc(&self, _: &Data, s: &mut String) {
        write!(s, "{:016X}", self.to_bits()).unwrap();
    }
}
impl Enc for i64 {
    fn enc(&self, _: &Data, s: &mut String) {
        write!(s, "{self}").unwrap();
    }
}
impl Enc for crate::cl::Num {
    fn enc(&self, d: &Data, s: &mut String) {
        match self {
            crate::cl::Num::I(n) => n.enc(d, s),
            crate::cl::Num::F(x) => x.enc(d, s),
        }
    }
}
impl Enc for bool {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push_str(if *self { "T" } else { "NIL" });
    }
}
impl<T: Enc> Enc for Option<T> {
    fn enc(&self, d: &Data, s: &mut String) {
        match self {
            Some(v) => v.enc(d, s),
            None => s.push_str("NIL"),
        }
    }
}
fn seq<'a, T: Enc + 'a>(
    it: impl IntoIterator<Item = &'a T>,
    open: char,
    close: char,
    d: &Data,
    s: &mut String,
) {
    s.push(open);
    for (i, v) in it.into_iter().enumerate() {
        if i > 0 {
            s.push(',');
        }
        v.enc(d, s);
    }
    s.push(close);
}
/// A Lisp vector.
impl<T: Enc, const N: usize> Enc for [T; N] {
    fn enc(&self, d: &Data, s: &mut String) {
        seq(self, '[', ']', d, s);
    }
}
/// A Lisp list (empty = NIL).
impl<T: Enc> Enc for Vec<T> {
    fn enc(&self, d: &Data, s: &mut String) {
        if self.is_empty() {
            s.push_str("NIL")
        } else {
            seq(self, '(', ')', d, s)
        }
    }
}
/// A Lisp list held inline (`Few`), printed as `Vec`'s.
impl<T: Enc + Copy + Default, const N: usize> Enc for crate::components::Few<T, N> {
    fn enc(&self, d: &Data, s: &mut String) {
        if self.is_empty() {
            s.push_str("NIL")
        } else {
            seq(self.iter(), '(', ')', d, s)
        }
    }
}
impl Enc for Entity {
    fn enc(&self, d: &Data, s: &mut String) {
        if *self == Entity::NIL {
            s.push_str("NIL")
        } else {
            (self.0 as i64).enc(d, s)
        }
    }
}
impl Enc for MoveId {
    fn enc(&self, d: &Data, s: &mut String) {
        s.push_str("#m::");
        s.push_str(&d.moves[self.0 as usize].name.to_uppercase());
    }
}
impl Enc for KitId {
    fn enc(&self, _: &Data, s: &mut String) {
        write!(s, "#k::{}/:{}", self.character, self.form).unwrap();
    }
}
impl Enc for Sym {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push_str(self.0);
    }
}
impl Enc for Str {
    fn enc(&self, _: &Data, s: &mut String) {
        s.push('"');
        s.push_str(&self.0.replace(' ', "_"));
        s.push('"');
    }
}
impl Enc for Num {
    fn enc(&self, d: &Data, s: &mut String) {
        match self {
            Num::I(i) => i.enc(d, s),
            Num::F(f) => f.enc(d, s),
        }
    }
}
macro_rules! enc_kw {
    ($($t:ty),*) => {$(
        impl Enc for $t {
            fn enc(&self, _: &Data, s: &mut String) { s.push(':'); s.push_str(self.name()); }
        }
    )*};
}
enc_kw!(
    State, Phase, Cls, Form, Character, HazardKind, Contact, Queued, Burst, Button, Flow, Difficulty
);

/// The slots of a struct in order, comma-separated.
macro_rules! slots {
    ($d:expr, $s:expr, $o:expr; $($f:ident),* $(,)?) => {{
        #[allow(unused_assignments)]
        let mut i = 0;
        $( if i > 0 { $s.push(','); } i += 1; $o.$f.enc($d, $s); )*
    }};
}

impl Enc for KikonUndo {
    fn enc(&self, d: &Data, s: &mut String) {
        s.push('(');
        slots!(d, s, self; def, react, stun, sx, sz, kb, wave, kreact, kstun);
        s.push(')');
    }
}
impl Enc for HitWin {
    fn enc(&self, d: &Data, s: &mut String) {
        s.push_str("#HITWIN{");
        slots!(d, s, self; from, to, dmg, vols, react, kb, hs, chip, stun, guard, seg, min, steal, flags);
        s.push('}');
    }
}
/// HAZARD-DATA (an ICC is the match's shared struct: `m.iccs`).
fn enc_hz_data(m: &Match, v: &HzData, s: &mut String) {
    let d = m.data;
    match v {
        HzData::Icc(i) => {
            let c = &m.iccs[*i];
            s.push_str("#ICC{:");
            s.push_str(c.state.name());
            s.push(',');
            c.born.enc(d, s);
            s.push(',');
            c.life.enc(d, s);
            s.push(',');
            c.fade.enc(d, s);
            s.push(',');
            match c.src {
                Some(x) => {
                    s.push(':');
                    s.push_str(x.name());
                }
                None => s.push_str("NIL"),
            }
            s.push(',');
            c.link.enc(d, s);
            s.push(',');
            c.mv.enc(d, s);
            s.push(',');
            c.sf.enc(d, s);
            s.push(',');
            let q: Vec<Sym> = c.queued.iter().map(|w| Sym(if *w == crate::ichigo::clones::Weight::Q { ":Q" } else { ":F" })).collect();
            q.enc(d, s);
            s.push(',');
            c.hit.enc(d, s);
            s.push(',');
            c.touched.enc(d, s);
            s.push(',');
            if c.rq.is_empty() {
                s.push_str("NIL");
            } else {
                s.push('(');
                for (k, (t, mv, x)) in c.rq.iter().enumerate() {
                    if k > 0 {
                        s.push(',');
                    }
                    s.push('(');
                    t.enc(d, s);
                    s.push(',');
                    mv.enc(d, s);
                    s.push(',');
                    x.enc(d, s);
                    s.push(')');
                }
                s.push(')');
            }
            s.push(',');
            c.rmult.enc(d, s);
            s.push(',');
            c.rt.enc(d, s);
            s.push(',');
            c.sscale.enc(d, s);
            s.push('}');
        }
        _ => v.enc(d, s),
    }
}

impl Enc for HzData {
    fn enc(&self, d: &Data, s: &mut String) {
        match self {
            HzData::Nil => s.push_str("NIL"),
            HzData::Icc(_) => unreachable!("an ICC is encoded with its match (enc_hz_data)"),
            HzData::Ice { mv, sf, end } => {
                s.push_str("#ICE{");
                mv.enc(d, s);
                s.push(',');
                sf.enc(d, s);
                s.push(',');
                end.enc(d, s);
                s.push('}');
            }
            HzData::Kw(k) => k.enc(d, s),
            HzData::Int(n) => n.enc(d, s),
            HzData::DelayHit { def, dmg, n, react, stun, sx, sz, kb, mv, red } => {
                let vs: [&dyn Enc; 10] = [def, dmg, n, react, stun, sx, sz, kb, mv, red];
                s.push('(');
                for (i, v) in vs.iter().enumerate() {
                    if i > 0 {
                        s.push(',');
                    }
                    v.enc(d, s);
                }
                s.push(')');
            }
        }
    }
}

/// Space-separated fields (each preceded by a space).
macro_rules! fields {
    ($d:expr, $s:expr, $o:expr; $($f:ident),* $(,)?) => {{ $( $s.push(' '); $o.$f.enc($d, $s); )* }};
}

fn each<T: Enc>(d: &Data, s: &mut String, vs: &[T]) {
    for v in vs {
        s.push(' ');
        v.enc(d, s);
    }
}

fn absent(s: &mut String, n: usize) {
    for _ in 0..n {
        s.push_str(" :ABSENT");
    }
}

fn side_fields(m: &Match, e: Entity, s: &mut String) {
    let d = m.data;
    let t = m
        .transform
        .get(e)
        .expect("B line: a fighter without TRANSFORM");
    let mo = m.motion.get(e).expect("B line: a fighter without MOTION");
    each(d, s, &t.pos);
    fields!(d, s, t; yaw);
    each(d, s, &mo.vel);
    each(d, s, &mo.kb);
    fields!(d, s, mo; kb_left, grounded);
    match m.fighter.get(e) {
        Some(f) => {
            fields!(d, s, f; side, opp, character, form, kit, state, sf, phase, mv, button, hold, follow, armor_left,
            kikon_n, cd, hits, contact, hz_hit, queued, chained, land_sf, dmg_bonus, crush, stun, glock, freeze, lock,
            freeze_next, lock_next, hoho_lock, hoho_from, hoho_cls, hoho_presses, hoho_mult, hoho_left, hoho_hold, guard_t,
            state_t, ward_until, stored, charge, perfect, end_chase, gc_left, guard_exit, cls, cls_t, dead_mv, dead_t, pre,
            presses, ptr, sp_ptr, tmp, csa, sw, as_done, sp_held, bk_out, charge_mult, sp_paid, sp_cost, sp_back, sp_gain_t,
            xch, xch_done, clash_t, clash_n, lv_cap, lv_got, kikon_lock, kikon_undo, burst, chain, invuln, ox, oz, dist,
            run_yaw, combo_hits, combo_launches, combo_air, combo_from, combo_dmg, callout, callout_t)
        }
        None => absent(s, 86),
    }
    match m.gauges.get(e) {
        Some(g) => {
            fields!(d, s, g; reishi, reishi_max, konpaku, fs, fs_idle, burst, burst_t, burn, awake_regen, awake_t, gg,
            gg_idle, guardless, awaken, awakened, aw_full, sub, sub_s, drive, evolution, meter, meter_idle, form_left,
            burn_step, taken_melee, taken_ranged, stun, stun_idle, dealt, kikons, perfects, best_combo, grey, evo_t)
        }
        None => absent(s, 34),
    }
    match m.ics.get(e) {
        Some(c) => {
            fields!(d, s, c; dashed, o_live, seen, seen_main, rseen, hist, hist_i, rim, rim_saved, parry_sf, bs_key,
            bs_at, o_at, o_n, acc_mv, acc_sf, acc_hit, acc_kikons)
        }
        None => absent(s, 18),
    }
    // ponytail: Hisagi's HSS (28 slots) and Yamamoto's YSS (9) are out of M1's gate (decision 1): always absent here.
    absent(s, 28 + 9);
}

/// The B line now (`B …`, the full text; the recorder's `B =` shorthand is the reader's business).
pub fn bits_line(m: &Match) -> String {
    let d = m.data;
    let mut s = String::with_capacity(4096);
    s.push('B');
    fields!(d, &mut s, m; timer);
    fields!(d, &mut s, m.time; hitstop);
    fields!(d, &mut s, m; slow_acc);
    each(d, &mut s, &m.time.slowmo);
    fields!(d, &mut s, m; flow);
    s.push(' ');
    m.cine.as_ref().map_or(-1, |c| c.cf).enc(d, &mut s);
    side_fields(m, m.p1, &mut s);
    side_fields(m, m.p2, &mut s);
    s.push_str(" |");
    for (_, h) in m.hazard.iter() {
        fields!(d, &mut s, h; kind);
        s.push(' ');
        match h.owner {
            o if o == m.p1 => s.push_str(":P1"),
            o if o == m.p2 => s.push_str(":P2"),
            o => o.enc(d, &mut s),
        }
        fields!(d, &mut s, h; x, y, z, px, pz, yaw, speed, size, age, life, delay, hits_left, rehit, hw, src, hook);
        s.push(' ');
        enc_hz_data(m, &h.data, &mut s);
        fields!(d, &mut s, h; sp, sp_mv, cls, sp_paid, sp_scale, sp_src, look);
    }
    s
}

/// port: gate.lisp STATE-HASH-LINE (without the `H ` the recorder adds).
pub fn state_hash_line(m: &Match) -> String {
    let mut s = format!("duel hash t={}", m.match_tick);
    let r100 = |x: f32| round_f32(100.0 * x);
    for e in [m.p1, m.p2] {
        let t = m.transform.get(e).expect("H line: TRANSFORM");
        let (f, g) = (
            m.fighter.get(e).expect("H line: FIGHTER"),
            m.gauges.get(e).expect("H line: GAUGES"),
        );
        let aw_full = crate::gauges::aw_full_p(&m.knobs, g);
        write!(
            s,
            " | {} {} {} {} {} {} r{} k{} f{} g{}{} w{}{} m{} n{} s{}",
            r100(t.pos[0]),
            r100(t.pos[1]),
            r100(t.pos[2]),
            r100(t.yaw),
            f.state,
            f.form,
            g.reishi,
            g.konpaku,
            round_f32(g.fs),
            round_f32(g.gg),
            if g.guardless { "!" } else { "" },
            round_f32(g.awaken),
            if aw_full { "^" } else { "" },
            round_f32(g.meter),
            f.kikon_n,
            round_f32(f.sp_paid)
        )
        .unwrap();
        if f.xch >= 0 {
            write!(s, " x{}{}", f.xch, if f.xch_done { "*" } else { "" }).unwrap();
        }
        // ponytail: the kit's :hash hook is Hisagi's only (out of M1's gate).
        write!(s, " p{}", f.ptr).unwrap();
    }
    let cd = |e: Entity| {
        m.fighter
            .get(e)
            .unwrap()
            .cd
            .iter()
            .map(|c| c.to_string())
            .collect::<Vec<_>>()
            .join(".")
    };
    write!(
        s,
        " | cd {} {} | haz {}",
        cd(m.p1),
        cd(m.p2),
        m.hazard.len()
    )
    .unwrap();
    s
}

#[cfg(test)]
pub(crate) mod tests {
    use super::*;
    use crate::consts::PI;
    use crate::vpad::Vpad;
    use std::io::BufRead;
    use std::sync::OnceLock;

    pub(crate) fn data() -> &'static Data {
        static D: OnceLock<Data> = OnceLock::new();
        D.get_or_init(Data::embedded)
    }
    pub(crate) fn new_match() -> Match {
        Match::new(data())
    }

    /// The first `H` and `B` lines and the `# B fields:` names of an answer-key trace (read line by line: traces are large).
    /// None (the test skips, with a note) when the answer key is absent: `ORACLE`, else this checkout's git-ignored build/oracle.
    fn trace_head(name: &str) -> Option<(String, String, Vec<String>)> {
        let dir = std::env::var("ORACLE").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../build/oracle").into());
        let path = format!("{dir}/traces/{name}.trace");
        let Ok(f) = std::fs::File::open(&path) else {
            eprintln!("skipped: no answer key at {path} (set ORACLE)");
            return None;
        };
        let (mut h, mut b, mut names) = (None, None, None);
        for l in std::io::BufReader::new(f).lines() {
            let l = l.unwrap();
            if let Some(n) = l.strip_prefix("# B fields: ") {
                names = Some(n.split(' ').map(String::from).collect());
            } else if let Some(x) = l.strip_prefix("H ") {
                h.get_or_insert(x.to_string());
            } else if l.starts_with("B ") && b.is_none() {
                b = Some(l);
            }
            if h.is_some() && b.is_some() && names.is_some() {
                break;
            }
        }
        Some((h.unwrap(), b.unwrap(), names.unwrap()))
    }

    /// cvc-ki-s1 step 1: Kenpachi (P1) and Ichigo (P2) at spawn, the intro's cinematic on its first frame.
    fn ki_step1() -> Match {
        let mut m = new_match();
        m.spawn();
        m.spawn();
        m.clear_entities(); // the title's fighters: this match's handles are generation 1 (opp 257 / 256)
        let (p1, p2) = (m.spawn(), m.spawn());
        for (e, side, ch, x, yaw) in [
            (p1, 0, Character::Kenpachi, -4.0, -PI / 2.0),
            (p2, 1, Character::Ichigo, 4.0, PI / 2.0),
        ] {
            m.transform.insert(
                e,
                Transform {
                    pos: [x, 0.0, 0.0],
                    yaw,
                },
            );
            m.motion.insert(e, Motion::default());
            let kit = Some(KitId {
                character: ch,
                form: Form::Base,
            });
            let opp = if e == p1 { p2 } else { p1 };
            m.fighter.insert(
                e,
                Fighter {
                    side,
                    opp,
                    character: Some(ch),
                    kit,
                    state: State::Cine,
                    ..Fighter::default()
                },
            );
            m.gauges.insert(e, Gauges::new(&m.knobs));
            m.pilot.insert(
                e,
                Pilot {
                    vpad: Vpad::duel(m.data, &m.knobs).unwrap(),
                    cam_relative: false,
                },
            );
        }
        (m.p1, m.p2) = (p1, p2);
        (m.match_tick, m.timer, m.flow, m.cine) =
            (1, 18000, Flow::Intro, Some(crate::cine::Cine { name: crate::cine::CineName::Intro, cf: 1, len: 300, a: p1, v: p2, hold: None, after: None, skip: false, line: [0.0; 4] }));
        m
    }

    #[test]
    fn hash_line_at_spawn() {
        let want = "duel hash t=1 | -400 0 0 -157 CINE BASE r1300 k9 f300 g100 w0 m0 n2 s0 p1 | 400 0 0 157 CINE BASE r1300 k9 f300 g100 w0 m0 n2 s0 p1 | cd 0.0.0.0.0.0.0 0.0.0.0.0.0.0 | haz 0";
        assert_eq!(state_hash_line(&ki_step1()), want);
        if let Some((h, _, _)) = trace_head("cvc-ki-s1") {
            assert_eq!(h, want);
        }
    }

    /// The whole first B line of cvc-ki-s1, byte for byte (every default of FIGHTER / GAUGES, :ABSENT kit components, the
    /// generation-1 handles), then a field count against the header with one hazard live.
    #[test]
    fn bits_line_field_count() {
        let Some((_, want, names)) = trace_head("cvc-ki-s1") else { return };
        let mut m = ki_step1();
        let got = bits_line(&m);
        let (w, g): (Vec<_>, Vec<_>) = (want.split(' ').collect(), got.split(' ').collect());
        if let Some(i) = (0..w.len().max(g.len())).find(|&i| w.get(i) != g.get(i)) {
            panic!(
                "B field {} ({}): want {:?} got {:?}",
                i,
                names.get(i.wrapping_sub(1)).map_or("", |s| s),
                w.get(i),
                g.get(i)
            );
        }
        let hz = m.spawn();
        m.hazard.insert(
            hz,
            Hazard {
                kind: Some(HazardKind::Wave),
                owner: m.p1,
                ..Hazard::default()
            },
        );
        assert_eq!(bits_line(&m).split(' ').count() - 1, names.len());
    }

    /// Encodings of the nested values, against tokens copied from the gate traces.
    #[test]
    fn nested_values_encode_as_the_trace() {
        let d = data();
        let enc = |v: &dyn Fn(&mut String)| {
            let mut s = String::new();
            v(&mut s);
            s
        };
        let ku = KikonUndo {
            def: Entity(257),
            react: Phase::Knockdown,
            stun: 0,
            sx: f32::from_bits(0xC02905CF),
            sz: f32::from_bits(0x4005C56C),
            kb: 0.0,
            wave: false,
            kreact: Some(Phase::Stagger),
            kstun: 43,
        };
        assert_eq!(
            enc(&|s| ku.enc(d, s)),
            "(257,:KNOCKDOWN,0,C02905CF,4005C56C,00000000,NIL,:STAGGER,43)"
        );
        let hw = HitWin {
            from: 0,
            to: 0,
            dmg: 150,
            vols: Few::new(),
            react: Phase::Knockdown,
            kb: 2.0,
            hs: 8,
            chip: None,
            stun: None,
            guard: Some(Num::I(22)),
            seg: None,
            min: None,
            steal: None,
            flags: [Sym(":BLADE")].into_iter().collect(),
        };
        assert_eq!(
            enc(&|s| hw.enc(d, s)),
            "#HITWIN{0,0,150,NIL,:KNOCKDOWN,40000000,8,NIL,NIL,22,NIL,NIL,NIL,(:BLADE)}"
        );
        let hw2 = HitWin {
            from: 8,
            to: 11,
            dmg: 18,
            react: Phase::Flinch,
            kb: 0.0,
            hs: 4,
            guard: Some(Num::F(f32::from_bits(0x40866666))),
            vols: [[0.0, 2.4, f32::from_bits(0x3F75BE0B), 0.2, 2.0, 0.0]].into_iter().collect(),
            flags: [Sym(":BLADE"), Sym(":RANGED")].into_iter().collect(),
            ..hw
        };
        assert_eq!(
            enc(&|s| hw2.enc(d, s)),
            "#HITWIN{8,11,18,([00000000,4019999A,3F75BE0B,3E4CCCCD,40000000,00000000]),:FLINCH,00000000,4,NIL,NIL,40866666,NIL,NIL,NIL,(:BLADE,:RANGED)}"
        );
        let mv = MoveId(d.moves.iter().position(|m| m.name == "ic-as1").unwrap() as u16);
        assert_eq!(enc(&|s| mv.enc(d, s)), "#m::IC-AS1");
        assert_eq!(
            enc(&|s| Str("KITTE MIRO YO").enc(d, s)),
            "\"KITTE_MIRO_YO\""
        );
        assert_eq!(
            enc(&|s| KitId {
                character: Character::Kenpachi,
                form: Form::Bankai2
            }
            .enc(d, s)),
            "#k::KENPACHI/:BANKAI-2"
        );
        assert_eq!(enc(&|s| (-0.0f32).enc(d, s)), "80000000");
    }

    /// Review Focus 3: `do-entities` order and visibility while entities come and go.
    #[test]
    fn iteration_sees_spawn_order_and_late_spawns() {
        let mut m = new_match();
        let hz = |m: &mut Match, life| {
            let e = m.spawn();
            m.hazard.insert(
                e,
                Hazard {
                    life,
                    ..Hazard::default()
                },
            );
            e
        };
        let (a, b, c, d) = (hz(&mut m, 0), hz(&mut m, 1), hz(&mut m, 2), hz(&mut m, 3));
        m.destroy(b); // slot 1 free; top stays 4
        let mut seen = vec![];
        let top = m.ents.top;
        for s in 0..top {
            let Some(e) = m.ents.at(s) else { continue };
            let Some(h) = m.hazard.get(e) else { continue };
            seen.push(h.life);
            if e == a {
                hz(&mut m, 10); // into slot 1, above the cursor: visited
                hz(&mut m, 11); // slot 4 >= top at loop start: not visited
                m.destroy(c); // ahead of the cursor: skipped
            }
        }
        assert_eq!(seen, [0, 10, 3]);
        assert_eq!(
            m.hazard.iter().map(|(_, h)| h.life).collect::<Vec<_>>(),
            [0, 10, 3, 11]
        ); // slot order
        assert!(!m.ents.alive(c) && m.ents.alive(d));
    }

    #[test]
    fn snapshot_restores_hash() {
        let mut m = ki_step1();
        let h0 = m.hash64();
        let snap = m.clone();
        m.fighter.get_mut(m.p1).unwrap().sf = 9;
        m.time.hitstop(4.0);
        let hz = m.spawn();
        m.hazard.insert(hz, Hazard::default());
        assert_ne!(m.hash64(), h0);
        m = snap;
        assert_eq!(m.hash64(), h0);
    }
}
