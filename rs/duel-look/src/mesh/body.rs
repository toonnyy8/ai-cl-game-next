//! port: engine/lisp/body.lisp BUILD-PARTS / BUILD-SOLID / BUILD-SHAPE / SHAPE-XFORM / SHAPE-INK-K / PAL-RGB and duel/lisp/body.lisp
//! GIRTH-SHAPE / GIRTH-SPEC / BUILD-BODY: a body's shape spec (bodies.json) into one mesh per joint for its untagged solid shapes,
//! one per (joint, tag) and per glow, and the ink hulls. The duel's toon look: no jitter, smooth spheres and cylinders
//! (body.lisp `(setf *part-jitter* 0.0 *part-smooth* t)`).
use super::meshgen::{hexc, hull, Mb, V3, XF};
use duel_data::{Body, Datum};
use duel_sim::cl::{max_f32, min_f32};
use duel_sim::math::deg;

/// One spec shape, parsed: KIND, its numbers, its options (keyword -> value) in order.
#[derive(Clone, Debug)]
struct Shape {
    kind: String,
    nums: Vec<f32>,
    opts: Vec<(String, Datum)>,
}

impl Shape {
    fn opt(&self, k: &str) -> Option<&Datum> {
        self.opts.iter().find(|o| o.0 == k).map(|o| &o.1)
    }
    fn opt_f(&self, k: &str) -> Option<f32> {
        self.opt(k).map(|d| d.as_f32().unwrap_or_else(|| panic!("shape option {k}: not a number")))
    }
    fn set_opt(&mut self, k: &str, v: Datum) {
        if let Some(o) = self.opts.iter_mut().find(|o| o.0 == k) {
            o.1 = v;
        }
    }
    fn tag(&self) -> Option<&str> {
        self.opt("tag").and_then(Datum::as_str)
    }
}

/// A spec entry's shape: solid, or (:glow e shape [tag]).
#[derive(Clone, Debug)]
enum Item {
    Solid(Shape),
    Glow { e: f32, shape: Shape, tag: Option<String> },
}

fn list(d: &Datum) -> &[Datum] {
    match d {
        Datum::List(v) => v,
        _ => panic!("body spec: a list expected, got {d:?}"),
    }
}

fn parse_shape(d: &[Datum]) -> Shape {
    let kind = d[0].as_str().expect("shape kind").to_string();
    let k = d[1..].iter().position(|x| matches!(x, Datum::Str(_))).map_or(d.len(), |i| i + 1);
    let nums = d[1..k].iter().map(|x| x.as_f32().expect("shape number")).collect();
    let opts = d[k..].chunks(2).map(|c| (c[0].as_str().expect("shape option").to_string(), c[1].clone())).collect();
    let s = Shape { kind, nums, opts };
    assert!(s.opt("squash").is_none(), "shape :squash: not ported (no Kenpachi / Ichigo shape has one)");
    s
}

fn parse_item(d: &[Datum]) -> Item {
    if d[0].as_str() == Some("glow") {
        Item::Glow {
            e: d[1].as_f32().expect("glow strength"),
            shape: parse_shape(list(&d[2])),
            tag: d.get(3).map(|t| t.as_str().expect("glow tag").to_string()),
        }
    } else {
        Item::Solid(parse_shape(d))
    }
}

/// port: duel/lisp/body.lisp GIRTH-SHAPE (size and :at scaled by S in the joint frame; radii by (sx + sz) / 2).
fn girth_shape(s: &Shape, (sx, sy, sz): (f32, f32, f32)) -> Shape {
    let mut o = s.clone();
    let r = 0.5 * (sx + sz);
    if let Some(at) = s.opt("at") {
        let a = list(at);
        let c = |i: usize| a.get(i).map_or(0.0, |x| x.as_f32().unwrap());
        o.set_opt("at", Datum::List(vec![Datum::F32(c(0) * sx), Datum::F32(c(1) * sy), Datum::F32(c(2) * sz)]));
    }
    if let Some(t) = s.opt_f("top") {
        o.set_opt("top", Datum::F32(r * t));
    }
    if let Some(t) = s.opt_f("stretch") {
        o.set_opt("stretch", Datum::F32(sy * t));
    }
    let n = &s.nums;
    o.nums = match s.kind.as_str() {
        "box" | "wedge" => vec![n[0] * sx, n[1] * sy, n[2] * sz],
        "bevel" => vec![sx * n[0], sy * n[1], sz * n[2], min_f32(min_f32(sx, sy), sz) * n[3]],
        "cyl" | "cone" => vec![r * n[0], sy * n[1]],
        "sphere" => vec![r * n[0]],
        k => panic!("girth: shape kind {k}"),
    };
    o
}

/// port: engine/lisp/body.lisp PAL-RGB: a palette key (the first row wins), #xRRGGBB or an rgb list.
fn pal_rgb(c: &Datum, palette: &[(String, i64)]) -> Option<V3> {
    match c {
        Datum::Str(k) => Some(hexc(palette.iter().find(|p| &p.0 == k).unwrap_or_else(|| panic!("no colour {k} in palette")).1)),
        Datum::Int(h) => Some(hexc(*h)),
        Datum::Null => None,
        d => panic!("colour {d:?}"),
    }
}

/// port: engine/lisp/body.lisp SHAPE-XFORM: AT (right up fwd) metres, ROT (yaw pitch roll) degrees.
/// ponytail: the Lisp's `(- f)` of an integer 0 is 0, of 0.0 is -0.0; here always -f (a -0.0 translation only changes a zero's sign).
fn shape_xform(s: &Shape) -> super::meshgen::M4 {
    let g = |k: &str, i: usize| s.opt(k).and_then(|d| list(d).get(i)).map_or(0.0, |x| x.as_f32().unwrap());
    super::meshgen::Xf { x: g("at", 0), y: g("at", 1), z: -g("at", 2), yaw: deg(g("rot", 0)), pitch: deg(g("rot", 1)), roll: deg(g("rot", 2)), ..XF }.m()
}

/// port: engine/lisp/body.lisp BUILD-SHAPE (girth x and z by W; COLOR overrides :c; smooth = *PART-SMOOTH* T).
fn build_shape(mb: &mut Mb, s: &Shape, palette: &[(String, i64)], w: f32, color: Option<V3>) {
    let col = color.or_else(|| s.opt("c").and_then(|c| pal_rgb(c, palette)));
    if let Some(c) = col {
        mb.color(c);
    }
    let seg = s.opt_f("seg").map_or(8, |x| x as usize);
    let n = &s.nums;
    mb.with(&shape_xform(s), |mb| match s.kind.as_str() {
        "box" => mb.box_(w * n[0], n[1], w * n[2]),
        "bevel" => mb.bevel_box(w * n[0], n[1], w * n[2], n[3]),
        "cyl" => mb.cylinder(w * n[0], n[1], seg, w * s.opt_f("top").unwrap_or(n[0]), true, None, true),
        "cone" => mb.cone(w * n[0], n[1], seg),
        "sphere" => mb.sphere(w * n[0], seg, 5, s.opt_f("stretch").unwrap_or(0.0), true),
        "wedge" => mb.wedge(w * n[0], n[1], w * n[2]),
        k => panic!("shape kind {k}"),
    });
}

/// port: engine/lisp/body.lisp SHAPE-INK-K: its :ink, else by the middle extent of its vertices (0 under 4 cm, 0.6 under 10 cm, 1).
fn shape_ink_k(s: &Shape, mb: &Mb, start: usize) -> f32 {
    if let Some(k) = s.opt_f("ink") {
        return k;
    }
    let (mut lo, mut hi) = ([1e9f32; 3], [-1e9f32; 3]);
    for v in mb.data[start..].as_chunks::<9>().0 {
        for i in 0..3 {
            lo[i] = min_f32(lo[i], v[i]);
            hi[i] = max_f32(hi[i], v[i]);
        }
    }
    let mut ext = [hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2]];
    ext.sort_by(|a, b| b.partial_cmp(a).unwrap());
    let mid = ext[1];
    if mid < 0.04 {
        0.0
    } else if mid < 0.1 {
        0.6
    } else {
        1.0
    }
}

/// An ink alist ((colour key . #xRRGGBB) ... (t . #xRRGGBB)): the hull colour of a shape by its raw :c key.
pub struct Ink(Vec<(Option<String>, i64)>);

impl Ink {
    /// From tuning.json's `*BODY-INK*` (`[["skin", 3808794], ..., [true, 1052696]]`).
    pub fn from_value(v: &duel_data::tuning::Value) -> Ink {
        Ink(v
            .as_array()
            .expect("ink: an alist")
            .iter()
            .map(|r| {
                let key = if r[0].as_bool() == Some(true) { None } else { Some(r[0].as_str().expect("ink key").to_string()) };
                (key, r[1].as_i64().expect("ink colour"))
            })
            .collect())
    }
    /// From a body's own `ink` (bodies.json).
    pub fn parse(rows: &[Vec<Datum>]) -> Ink {
        Ink(rows
            .iter()
            .map(|r| {
                let key = match &r[0] {
                    Datum::Str(s) => Some(s.clone()),
                    Datum::Bool(true) => None,
                    d => panic!("ink key {d:?}"),
                };
                (key, match r[1] { Datum::Int(h) => h, ref d => panic!("ink colour {d:?}") })
            })
            .collect())
    }
    /// `(cdr (or (assoc c ink) (assoc t ink)))`.
    pub fn of(&self, c: Option<&Datum>) -> i64 {
        let key = c.and_then(Datum::as_str);
        let row = key.and_then(|k| self.0.iter().find(|r| r.0.as_deref() == Some(k))).or_else(|| self.0.iter().find(|r| r.0.is_none()));
        row.expect("ink: no T row").1
    }
}

/// port: engine/lisp/body.lisp BUILD-SOLID: one mesh of SHAPES and its hull mesh (None: every shape inkless).
fn build_solid(shapes: &[&Shape], palette: &[(String, i64)], width: f32, ink: &Ink) -> (Vec<f32>, Option<Vec<f32>>) {
    let mut mb = Mb::new();
    let mut ranges = vec![];
    for s in shapes {
        let start = mb.fill();
        build_shape(&mut mb, s, palette, width, None);
        ranges.push((start, mb.fill(), *s, shape_ink_k(s, &mb, start)));
    }
    let mut hb = vec![];
    for (start, end, s, k) in ranges {
        if k > 0.0 {
            let c = if s.kind == "cone" || s.kind == "wedge" { 0.8 } else { 0.55 };
            hull(&mut hb, &mb.data, start, end, k, c, hexc(ink.of(s.opt("c"))));
        }
    }
    (mb.data, (!hb.is_empty()).then_some(hb))
}

/// A tagged solid part or a glow (BUILD-PARTS' EXTRAS #(joint mesh tint emissive tag)): TINT None for a tagged solid.
pub struct Extra {
    pub joint: usize,
    pub mesh: Vec<f32>,
    pub tint: Option<V3>,
    pub emissive: f32,
    pub tag: Option<String>,
}
/// An ink hull (BUILD-PARTS' HULLS #(joint mesh tag)).
pub struct HullPart {
    pub joint: usize,
    pub mesh: Vec<f32>,
    pub tag: Option<String>,
}
/// BUILD-PARTS' three values, the lists in the Lisp's order (they are push lists: the last built first).
pub struct Parts {
    pub parts: Vec<Option<Vec<f32>>>,
    pub extras: Vec<Extra>,
    pub hulls: Vec<HullPart>,
}

/// port: engine/lisp/body.lisp BUILD-PARTS, after duel/lisp/body.lisp BUILD-BODY's GIRTH-SPEC.
pub fn build_body(b: &Body, rig: &duel_data::Rig, ink: &Ink) -> Parts {
    let mut parts: Vec<Option<Vec<f32>>> = vec![None; rig.joints.len()];
    let (mut extras, mut hulls) = (vec![], vec![]);
    for entry in &b.spec {
        let jname = entry[0].as_str().expect("spec joint");
        let j = crate::rig::joint_index(rig, jname);
        let girth = b.girth.as_ref().and_then(|g| g.iter().find(|r| r.0 == jname)).map(|r| (r.1, r.2, r.3));
        let items: Vec<Item> = entry[1..]
            .iter()
            .map(|d| {
                let it = parse_item(list(d));
                match (girth, it) {
                    (Some(s), Item::Solid(sh)) => Item::Solid(girth_shape(&sh, s)),
                    (Some(s), Item::Glow { e, shape, tag }) => Item::Glow { e, shape: girth_shape(&shape, s), tag },
                    (None, it) => it,
                }
            })
            .collect();
        let solid: Vec<&Shape> = items.iter().filter_map(|i| if let Item::Solid(s) = i { Some(s) } else { None }).collect();
        let plain: Vec<&Shape> = solid.iter().copied().filter(|s| s.tag().is_none()).collect();
        // CL REMOVE-DUPLICATES keeps each tag's last occurrence, in that order
        let all: Vec<&str> = solid.iter().filter_map(|s| s.tag()).collect();
        let tags: Vec<&str> = all.iter().enumerate().filter(|(i, t)| !all[i + 1..].contains(t)).map(|(_, t)| *t).collect();
        if !plain.is_empty() {
            let (mesh, hull) = build_solid(&plain, &b.palette, b.width, ink);
            parts[j] = Some(mesh);
            if let Some(h) = hull {
                hulls.push(HullPart { joint: j, mesh: h, tag: None });
            }
        }
        for tag in tags {
            let these: Vec<&Shape> = solid.iter().copied().filter(|s| s.tag() == Some(tag)).collect();
            let (mesh, hull) = build_solid(&these, &b.palette, b.width, ink);
            extras.push(Extra { joint: j, mesh, tint: None, emissive: 0.0, tag: Some(tag.to_string()) });
            if let Some(h) = hull {
                hulls.push(HullPart { joint: j, mesh: h, tag: Some(tag.to_string()) });
            }
        }
        for it in &items {
            if let Item::Glow { e, shape, tag } = it {
                let col = shape.opt("c").and_then(|c| pal_rgb(c, &b.palette));
                let mut mb = Mb::with_color([1.0, 1.0, 1.0]);
                build_shape(&mut mb, shape, &b.palette, b.width, Some([1.0, 1.0, 1.0]));
                extras.push(Extra { joint: j, mesh: mb.data, tint: col, emissive: *e, tag: tag.clone() });
            }
        }
    }
    extras.reverse();
    hulls.reverse();
    Parts { parts, extras, hulls }
}
