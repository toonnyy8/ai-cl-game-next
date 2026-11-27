//! port: engine/c/render.c r_make_pipe and engine/lisp/render.lisp RENDER-INIT's pipeline table (+ ui.lisp's RP_UI): every RP_* slot
//! as a pipeline in Bevy's `PipelineCache`, from the WGSL of engine/shaders/ copied unchanged into rs/duel-app/assets/shaders/.
//! The SDL WebGPU backend's group convention is kept, so the WGSL needs no edit: group 0 the vertex storage (the draw records),
//! 1 the vertex uniform, 2 the fragment textures and samplers, 3 the fragment uniform.
use bevy::asset::Handle;
use bevy::mesh::VertexBufferLayout;
use bevy::render::render_resource::binding_types::{sampler, storage_buffer_read_only_sized, texture_2d, uniform_buffer_sized};
use bevy::render::render_resource::*;
use bevy::shader::Shader;
use std::borrow::Cow;

/// render.c's enum RP_* (slots fixed: ui.lisp RP_UI = 10, paint.lisp RP_HUD = 19 and RP_COMP_AO = 20, M3b's).
pub const RP_LIT: usize = 0;
pub const RP_LIT_T: usize = 2;
pub const RP_SKY: usize = 4;
pub const RP_FXA: usize = 5;
pub const RP_FXB: usize = 6;
pub const RP_BRIGHT: usize = 7;
pub const RP_BLUR: usize = 8;
pub const RP_COMP: usize = 9;
pub const RP_UI: usize = 10;
pub const RP_TOON: usize = 11;
pub const RP_SKY_TOON: usize = 13;
pub const RP_HULL: usize = 14;
pub const RP_FXT: usize = 16;
pub const RP_COMP_FX: usize = 17;
pub const RP_COMP_A: usize = 18;
pub const RP_FXT_F: usize = 21;
pub const RP_FXT_N: usize = 22;
pub const RP_FXT_L: usize = 23;
pub const RP_COMP_FL: usize = 24;
pub const RP_BRIGHT_FL: usize = 25;
pub const RP_FXT_FL: usize = 26;
pub const RP_N: usize = 27;

/// The bind groups a pipeline reads (its layout). `Scene`: the draw records (0), the Frame (1 and 3); `Tex(n, nearest)`: n textures
/// at group 2 and the post uniform P at group 3; `Ui`: the size uniform S (1) and the font atlas (2).
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Kind {
    Scene,
    Tex(u32),
    Ui,
}

/// One row of RENDER-INIT's table: slot, vertex file + entry, fragment file + entry, LAYOUT (attribute sizes as hex digits),
/// TARGET (0 scene MSAA + depth, 1 offscreen RGBA8, 2 swapchain), DEPTH (0 off, 1 test + write, 2 test), BLEND (0 off, 1 alpha,
/// 2 additive, 3 alpha-to-coverage, 4 premultiplied over), CULL (0 none, 1 back, 2 back cw, 3 front, 4 front cw).
pub struct Def {
    pub slot: usize,
    pub vs: &'static str,
    pub ve: &'static str,
    pub fs: &'static str,
    pub fe: &'static str,
    pub layout: u32,
    pub target: u8,
    pub depth: u8,
    pub blend: u8,
    pub cull: u8,
    pub kind: Kind,
}

const fn d(slot: usize, vs: &'static str, ve: &'static str, fs: &'static str, fe: &'static str, layout: u32, target: u8, depth: u8, blend: u8, cull: u8, kind: Kind) -> Def {
    Def { slot, vs, ve, fs, fe, layout, target, depth, blend, cull, kind }
}

use Kind::*;
/// port: render.lisp RENDER-INIT (slot vs entry fs entry layout target depth blend cull) and ui.lisp UI-INIT's RP_UI.
pub const DEFS: [Def; 25] = [
    d(0, "lit.vert", "vs_main", "lit.frag", "fs_main", 0x333, 0, 1, 0, 1, Scene), // RP_LIT
    d(1, "lit.vert", "vs_main", "lit.frag", "fs_main", 0x333, 0, 1, 0, 2, Scene), // RP_LIT_CW (mirrored)
    d(2, "lit.vert", "vs_main", "lit.frag", "fs_main", 0x333, 0, 2, 1, 1, Scene), // RP_LIT_T (alpha < 1)
    d(3, "lit.vert", "vs_main", "lit.frag", "fs_main", 0x333, 0, 2, 1, 2, Scene), // RP_LIT_T_CW
    d(4, "fullscreen.vert", "vs_tri", "sky.frag", "fs_sky", 0, 0, 0, 0, 0, Scene), // RP_SKY
    d(5, "fx.vert", "vs_fx", "fx.frag", "fs_fx_alpha", 0x324, 0, 2, 1, 0, Scene), // RP_FXA
    d(6, "fx.vert", "vs_fx", "fx.frag", "fs_fx_add", 0x324, 0, 2, 2, 0, Scene), // RP_FXB
    d(7, "fullscreen.vert", "vs_tri", "bright.frag", "fs_bright", 0, 1, 0, 0, 0, Tex(1)), // RP_BRIGHT
    d(8, "fullscreen.vert", "vs_tri", "blur.frag", "fs_blur", 0, 1, 0, 0, 0, Tex(1)), // RP_BLUR
    d(9, "fullscreen.vert", "vs_tri", "composite.frag", "fs_comp", 0, 2, 0, 0, 0, Tex(3)), // RP_COMP
    d(10, "ui.vert", "vs_ui", "ui.frag", "fs_ui", 0x224, 2, 0, 1, 0, Ui), // RP_UI (ui.lisp)
    d(11, "toon.vert", "vs_toon", "toon.frag", "fs_toon", 0x333, 0, 1, 0, 1, Scene), // RP_TOON
    d(12, "toon.vert", "vs_toon", "toon.frag", "fs_toon", 0x333, 0, 1, 0, 2, Scene), // RP_TOON_CW
    d(13, "fullscreen.vert", "vs_tri", "sky-toon.frag", "fs_sky_toon", 0, 0, 0, 0, 0, Scene), // RP_SKY_TOON
    d(14, "toon.vert", "vs_hull", "toon.frag", "fs_ink", 0x333, 0, 1, 0, 3, Scene), // RP_HULL
    d(15, "toon.vert", "vs_hull", "toon.frag", "fs_ink", 0x333, 0, 1, 0, 4, Scene), // RP_HULL_CW
    d(16, "fx-toon.vert", "vs_fx_toon", "fx-toon.frag", "fs_fx_toon", 0x324, 0, 1, 3, 0, Scene), // RP_FXT (A2C)
    d(17, "fullscreen.vert", "vs_tri", "composite-fx.frag", "fs_comp_fx", 0, 2, 0, 0, 0, Tex(3)), // RP_COMP_FX
    d(18, "fullscreen.vert", "vs_tri", "composite.frag", "fs_comp_a", 0, 2, 0, 0, 0, Tex(3)), // RP_COMP_A
    d(21, "fx-toon.vert", "vs_fx_toon_f", "fx-toon.frag", "fs_fx_toon_f", 0x324, 0, 2, 1, 0, Scene), // RP_FXT_F
    d(22, "fx-toon.vert", "vs_fx_toon_n", "fx-toon.frag", "fs_fx_toon", 0x324, 0, 1, 3, 0, Scene), // RP_FXT_N
    d(23, "fx-toon.vert", "vs_fx_toon_l", "fx-toon.frag", "fs_fx_toon_l", 0x324, 0, 1, 0, 0, Scene), // RP_FXT_L
    d(24, "fullscreen.vert", "vs_tri", "flame-comp.frag", "fs_flame_comp", 0, 0, 0, 4, 0, Tex(1)), // RP_COMP_FL
    d(25, "fullscreen.vert", "vs_tri", "flame-bright.frag", "fs_bright_fl", 0, 1, 0, 0, 0, Tex(2)), // RP_BRIGHT_FL
    d(26, "fx-toon.vert", "vs_fx_toon_f", "fx-toon.frag", "fs_fx_toon_fl", 0x324, 0, 2, 1, 0, Scene), // RP_FXT_FL
];

/// The shader files (each a program: includes resolved), embedded at compile time from rs/duel-app/assets/shaders/.
/// ponytail: embedded, not loaded at run time with hot reload (BEVY_PORT §7.1): render.lisp's own `// #include` resolution has to
/// run on the text before Bevy sees it; a loader that resolves includes on hot reload comes when someone edits shaders live.
pub const FILES: [(&str, &str); 26] = [
    ("blur.frag", include_str!("../../assets/shaders/blur.frag.wgsl")),
    ("bright.frag", include_str!("../../assets/shaders/bright.frag.wgsl")),
    ("composite.frag", include_str!("../../assets/shaders/composite.frag.wgsl")),
    ("composite-fx.frag", include_str!("../../assets/shaders/composite-fx.frag.wgsl")),
    ("flame-bright.frag", include_str!("../../assets/shaders/flame-bright.frag.wgsl")),
    ("flame-comp.frag", include_str!("../../assets/shaders/flame-comp.frag.wgsl")),
    ("frame", include_str!("../../assets/shaders/frame.wgsl")),
    ("fullscreen.vert", include_str!("../../assets/shaders/fullscreen.vert.wgsl")),
    ("fx.frag", include_str!("../../assets/shaders/fx.frag.wgsl")),
    ("fx-io", include_str!("../../assets/shaders/fx-io.wgsl")),
    ("fx-toon.frag", include_str!("../../assets/shaders/fx-toon.frag.wgsl")),
    ("fx-toon-io", include_str!("../../assets/shaders/fx-toon-io.wgsl")),
    ("fx-toon-pal", include_str!("../../assets/shaders/fx-toon-pal.wgsl")),
    ("fx-toon.vert", include_str!("../../assets/shaders/fx-toon.vert.wgsl")),
    ("fx.vert", include_str!("../../assets/shaders/fx.vert.wgsl")),
    ("lit.frag", include_str!("../../assets/shaders/lit.frag.wgsl")),
    ("lit-io", include_str!("../../assets/shaders/lit-io.wgsl")),
    ("lit.vert", include_str!("../../assets/shaders/lit.vert.wgsl")),
    ("sky.frag", include_str!("../../assets/shaders/sky.frag.wgsl")),
    ("sky-toon.frag", include_str!("../../assets/shaders/sky-toon.frag.wgsl")),
    ("split", include_str!("../../assets/shaders/split.wgsl")),
    ("toon.frag", include_str!("../../assets/shaders/toon.frag.wgsl")),
    ("toon-io", include_str!("../../assets/shaders/toon-io.wgsl")),
    ("toon.vert", include_str!("../../assets/shaders/toon.vert.wgsl")),
    ("ui.frag", include_str!("../../assets/shaders/ui.frag.wgsl")),
    ("ui.vert", include_str!("../../assets/shaders/ui.vert.wgsl")),
];

fn file(name: &str) -> &'static str {
    FILES.iter().find(|f| f.0 == name).unwrap_or_else(|| panic!("shader {name}: not in FILES")).1
}

/// port: render.lisp READ-WGSL: each line `// #include "F"` is replaced by F's text (recursively), every // comment is removed, and
/// so are blank lines. (The include names drop `.wgsl`, as FILES does.)
pub fn expand(name: &str) -> String {
    let mut out = String::new();
    for line in file(name).lines() {
        let t = line.trim_start();
        if let Some(rest) = t.strip_prefix("// #include \"") {
            let inc = rest.split('"').next().unwrap_or("");
            out += &expand(inc.strip_suffix(".wgsl").unwrap_or(inc));
            continue;
        }
        let code = line.split("//").next().unwrap_or("").trim_end();
        if !code.is_empty() {
            out += code;
            out.push('\n');
        }
    }
    out
}

/// The programs a pipeline names (vertex and fragment files of DEFS), each once.
pub fn programs() -> Vec<&'static str> {
    let mut v: Vec<&'static str> = DEFS.iter().flat_map(|d| [d.vs, d.fs]).collect();
    v.sort();
    v.dedup();
    v
}

/// The bind group layouts (group 0..3 of each kind).
pub struct Layouts {
    pub empty: BindGroupLayoutDescriptor,
    pub draws: BindGroupLayoutDescriptor,
    pub uni: BindGroupLayoutDescriptor,
    pub tex: [BindGroupLayoutDescriptor; 4],
}

impl Layouts {
    pub fn new() -> Layouts {
        let vf = ShaderStages::VERTEX_FRAGMENT;
        let tex = |n: u32| {
            let mut e = Vec::new();
            for i in 0..n {
                e.push(texture_2d(TextureSampleType::Float { filterable: true }).build(2 * i, ShaderStages::FRAGMENT));
                e.push(sampler(SamplerBindingType::Filtering).build(2 * i + 1, ShaderStages::FRAGMENT));
            }
            BindGroupLayoutDescriptor::new(format!("duel_tex{n}"), &e)
        };
        Layouts {
            empty: BindGroupLayoutDescriptor::new("duel_empty", &[]),
            draws: BindGroupLayoutDescriptor::new("duel_draws", &[storage_buffer_read_only_sized(false, None).build(0, ShaderStages::VERTEX)]),
            uni: BindGroupLayoutDescriptor::new("duel_uni", &[uniform_buffer_sized(false, None).build(0, vf)]),
            tex: [tex(0), tex(1), tex(2), tex(3)],
        }
    }
    /// A pipeline's four groups.
    pub fn of(&self, k: Kind) -> Vec<BindGroupLayoutDescriptor> {
        match k {
            Scene => vec![self.draws.clone(), self.uni.clone(), self.empty.clone(), self.uni.clone()],
            Tex(n) => vec![self.empty.clone(), self.empty.clone(), self.tex[n as usize].clone(), self.uni.clone()],
            Ui => vec![self.empty.clone(), self.uni.clone(), self.tex[1].clone(), self.empty.clone()],
        }
    }
}

/// port: r_make_pipe's LAYOUT: attribute sizes as hex digits (0x333 = 3 x float3), one interleaved buffer; 0 = no vertex buffer.
pub fn vertex_layout(layout: u32) -> Vec<VertexBufferLayout> {
    const FMT: [VertexFormat; 5] = [VertexFormat::Float32, VertexFormat::Float32, VertexFormat::Float32x2, VertexFormat::Float32x3, VertexFormat::Float32x4];
    let (mut attrs, mut off) = (Vec::new(), 0u64);
    for sh in [12, 8, 4, 0] {
        let n = (layout >> sh) & 15;
        if n == 0 {
            continue;
        }
        attrs.push(VertexAttribute { format: FMT[n as usize], offset: off * 4, shader_location: attrs.len() as u32 });
        off += n as u64;
    }
    if attrs.is_empty() {
        return vec![];
    }
    vec![VertexBufferLayout { array_stride: off * 4, step_mode: VertexStepMode::Vertex, attributes: attrs }]
}

/// port: r_make_pipe's blend states (BLEND after its 3 / 4 decoding: 3 = no blend + alpha-to-coverage, 4 = alpha with the source
/// colour not multiplied).
pub fn blend(b: u8) -> Option<BlendState> {
    use BlendFactor::*;
    let pmo = b == 4;
    let b = match b {
        3 => 0,
        4 => 1,
        x => x,
    };
    if b == 0 {
        return None;
    }
    let dst = if b == 1 { OneMinusSrcAlpha } else { One };
    Some(BlendState {
        color: BlendComponent { src_factor: if pmo { One } else { SrcAlpha }, dst_factor: dst, operation: BlendOperation::Add },
        alpha: BlendComponent { src_factor: if b == 2 { SrcAlpha } else { One }, dst_factor: dst, operation: BlendOperation::Add },
    })
}

/// The scene targets' colour format (render.c: R8G8B8A8_UNORM; the engine shaders write sRGB-encoded values themselves).
pub const SCENE_FORMAT: TextureFormat = TextureFormat::Rgba8Unorm;
pub const DEPTH_FORMAT: TextureFormat = TextureFormat::Depth32Float;

/// port: r_make_pipe: D's pipeline for scene MSAA SAMPLES (1 or 4) and the swapchain view's format SWAP.
pub fn descriptor(d: &Def, shaders: &dyn Fn(&str) -> Handle<Shader>, layouts: &Layouts, samples: u32, swap: TextureFormat) -> RenderPipelineDescriptor {
    let format = if d.target == 2 { swap } else { SCENE_FORMAT };
    let count = if d.target == 0 && samples > 1 { 4 } else { 1 };
    let (cull_mode, front_face) = match d.cull {
        0 => (None, FrontFace::Ccw),
        1 => (Some(Face::Back), FrontFace::Ccw),
        2 => (Some(Face::Back), FrontFace::Cw),
        3 => (Some(Face::Front), FrontFace::Ccw),
        _ => (Some(Face::Front), FrontFace::Cw),
    };
    RenderPipelineDescriptor {
        label: Some(Cow::Owned(format!("duel {}/{} #{}", d.ve, d.fe, d.slot))),
        layout: layouts.of(d.kind),
        immediate_size: 0,
        vertex: VertexState { shader: shaders(d.vs), entry_point: Some(d.ve.into()), buffers: vertex_layout(d.layout), ..Default::default() },
        primitive: PrimitiveState { topology: PrimitiveTopology::TriangleList, cull_mode, front_face, ..Default::default() },
        // (the WebGPU backend ignores enable_depth_test: an untested pipeline gets compare ALWAYS, as r_make_pipe does)
        depth_stencil: (d.target == 0).then(|| DepthStencilState {
            format: DEPTH_FORMAT,
            depth_write_enabled: Some(d.depth == 1),
            depth_compare: Some(if d.depth > 0 { CompareFunction::Less } else { CompareFunction::Always }),
            stencil: StencilState::default(),
            bias: DepthBiasState::default(),
        }),
        multisample: MultisampleState { count, mask: !0, alpha_to_coverage_enabled: d.blend == 3 && count > 1 },
        fragment: Some(FragmentState {
            shader: shaders(d.fs),
            entry_point: Some(d.fe.into()),
            targets: vec![Some(ColorTargetState { format, blend: blend(d.blend), write_mask: ColorWrites::ALL })],
            ..Default::default()
        }),
        zero_initialize_workgroup_memory: false,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn slots_are_the_enum() {
        // every slot of render.c's enum but RP_HUD (19) and RP_COMP_AO (20), M3b's, once
        let mut s: Vec<usize> = DEFS.iter().map(|d| d.slot).collect();
        s.sort();
        assert_eq!(s, (0..RP_N).filter(|i| *i != 19 && *i != 20).collect::<Vec<_>>());
    }

    #[test]
    fn includes_expand_and_comments_go() {
        let s = expand("fx-toon.frag");
        assert!(s.contains("struct Frame") && s.contains("fn soft_class") && s.contains("var<private> PAL"));
        assert!(!s.contains("//") && !s.contains("#include"));
        for p in programs() {
            assert!(!expand(p).is_empty(), "{p}");
        }
    }

    #[test]
    fn layouts_and_blends() {
        assert_eq!(vertex_layout(0x324)[0].array_stride, 36);
        assert_eq!(vertex_layout(0x224)[0].array_stride, 32);
        assert!(vertex_layout(0).is_empty());
        let b = blend(4).unwrap();
        assert_eq!((b.color.src_factor, b.color.dst_factor), (BlendFactor::One, BlendFactor::OneMinusSrcAlpha));
        let b = blend(2).unwrap();
        assert_eq!((b.alpha.src_factor, b.alpha.dst_factor), (BlendFactor::SrcAlpha, BlendFactor::One));
        assert!(blend(3).is_none() && blend(0).is_none());
    }
}
