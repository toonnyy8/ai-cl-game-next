//! port: engine/c/render.c r_frame on Bevy's renderer (the user: 「全部用 Bevy 繪圖」): a `FrameOut` (what the frozen build hands the C
//! renderer) drawn pass for pass in render.c's order by one system of the camera's own render-graph schedule (`DuelGraph`), with
//! every RP_* slot a pipeline of Bevy's `PipelineCache` (pipes.rs) and the meshes in vertex-buffer chunks (meshes.rs). See
//! docs/bevy/M3A_NOTES.md §9 for each pass and the choices made where Bevy differs from SDL_GPU.
//!
//! Data flow per frame: the driver (main world) fills `FrameRes`; `extract_frame` copies the draw records into `Mirror` (render
//! world, reserved once) and writes every array into its GPU buffer (render.c's copy pass); `duel_frame` encodes the passes;
//! `count_frames` counts the submitted frames and, through the queue's work-done callback, the finished ones (the page's
//! `Module._frames_done()`, which run.mjs's settle waits on: index.html).
pub mod camera;
pub mod meshes;
pub mod pipes;
pub mod ui;

use bevy::ecs::schedule::ScheduleLabel;
use bevy::prelude::*;
use bevy::render::render_resource::*;
use bevy::render::renderer::{RenderContext, RenderDevice, RenderQueue, ViewQuery};
use bevy::render::view::{ExtractedWindow, ViewTarget};
use bevy::render::{Extract, ExtractSchedule, Render, RenderApp, RenderStartup, RenderSystems};
use bevy::shader::Shader;
use duel_look::draw::frame::{DQ_STRIDE, FU_FLOATS, P_FLOATS};
use duel_look::mesh::Meshes;
use duel_look::FrameOut;
use meshes::MeshGpu;
use pipes::*;
use std::sync::atomic::{AtomicBool, AtomicU32, Ordering::Relaxed};
use std::sync::Arc;

/// render.c R_MAX_DRAWS (records past it are dropped, as r_frame drops them).
pub const R_MAX_DRAWS: usize = 4096;
/// render.c R_FX_VERTS (9 floats each), R_UI_VERTS (8 floats each): the streams' buffers (STREAM-ROOM-P keeps the fills inside).
const FX_VERTS: u64 = 16384;
const UI_VERTS: u64 = 32768;
/// The scene's MSAA samples (render.c r_init: 4 when the device supports it, which WebGPU guarantees for RGBA8 and D32): the one
/// source of both the renderer's targets and `SceneInputs.msaa` (the toon fx cut, fu[157]).
pub const SCENE_MSAA: u32 = 4;

/// The camera's render-graph schedule: `duel_frame` only (camera.rs).
#[derive(ScheduleLabel, Debug, Clone, PartialEq, Eq, Hash, Default)]
pub struct DuelGraph;

/// The frame the driver drew (main world).
#[derive(Resource, Default)]
pub struct FrameRes(pub FrameOut);

/// The meshes to upload (main world; the render world takes the Arc once).
#[derive(Resource, Clone)]
pub struct MeshSrc(pub Arc<Meshes>);

static READY: AtomicBool = AtomicBool::new(false);
static DREW: AtomicBool = AtomicBool::new(false);
static SUBMITTED: AtomicU32 = AtomicU32::new(0);
static DONE: AtomicU32 = AtomicU32::new(0);

/// Every mesh uploaded and every pipeline compiled: the driver starts (no frame draws half its passes).
pub fn ready() -> bool {
    READY.load(Relaxed)
}

/// `Module._frames_done()`: the frames whose GPU work finished (submitted and presented before).
#[cfg_attr(target_arch = "wasm32", wasm_bindgen::prelude::wasm_bindgen)]
pub fn frames_done() -> u32 {
    DONE.load(Relaxed)
}

/// The frames submitted (the settle waits until `frames_done` reaches it).
#[cfg_attr(target_arch = "wasm32", wasm_bindgen::prelude::wasm_bindgen)]
pub fn frames_submitted() -> u32 {
    SUBMITTED.load(Relaxed)
}

pub struct RenderPlugin {
    /// ui.lisp's font atlas bytes (ui::atlas_bytes).
    pub font: Vec<u8>,
}

#[derive(Resource, Clone)]
struct Shaders(Vec<(&'static str, Handle<Shader>)>);

#[derive(Resource)]
struct FontBytes(Vec<u8>);

impl Plugin for RenderPlugin {
    fn build(&self, app: &mut App) {
        let mut assets = app.world_mut().resource_mut::<Assets<Shader>>();
        let sh = Shaders(programs().into_iter().map(|p| (p, assets.add(Shader::from_wgsl(expand(p), format!("duel/{p}.wgsl"))))).collect());
        app.init_resource::<FrameRes>();
        let Some(ra) = app.get_sub_app_mut(RenderApp) else { return };
        ra.insert_resource(sh)
            .insert_resource(FontBytes(self.font.clone()))
            .insert_resource(Mirror::default())
            .add_schedule(Schedule::new(DuelGraph))
            .add_systems(DuelGraph, duel_frame)
            .add_systems(RenderStartup, init_gpu)
            .add_systems(ExtractSchedule, extract_frame)
            .add_systems(Render, prepare.in_set(RenderSystems::PrepareResources))
            .add_systems(Render, count_frames.in_set(RenderSystems::Cleanup));
    }
}

/// The frame's arrays the passes read on the CPU (render world): the draw records (r_draw_queue reads each one's alpha, mesh, toon
/// mode and determinant), the post parameters, fu[159] and the stream fills (vertices).
#[derive(Resource)]
pub struct Mirror {
    dq: Vec<[f32; DQ_STRIDE]>,
    p: [f32; P_FLOATS],
    fu159: f32,
    nfa: u32,
    nfb: u32,
    nui: u32,
    nft: u32,
    live: bool,
}

impl Default for Mirror {
    fn default() -> Self {
        Mirror { dq: Vec::with_capacity(R_MAX_DRAWS), p: [0.0; P_FLOATS], fu159: 0.0, nfa: 0, nfb: 0, nui: 0, nft: 0, live: false }
    }
}

/// The offscreen targets (render.c r_targets) and the post passes' texture bind groups.
struct Targets {
    w: u32,
    h: u32,
    scene: TextureView,
    msaa: Option<TextureView>,
    flame: TextureView,
    flame_msaa: Option<TextureView>,
    depth: TextureView,
    half: [TextureView; 2],
    q: [TextureView; 2],
    /// group 2 of: RP_BRIGHT (scene), RP_BRIGHT_FL (scene, flame), the four blurs (half0, half1, half0, q0), the composites (scene,
    /// half0, q1), RP_COMP_FL (flame, nearest)
    g_bright: BindGroup,
    g_bright_fl: BindGroup,
    g_blur: [BindGroup; 4],
    g_comp: BindGroup,
    g_fl: BindGroup,
    /// the textures behind the views (a dropped texture is destroyed: the web backend frees it at once)
    _keep: Vec<Texture>,
}

#[derive(Resource)]
struct Gpu {
    layouts: Layouts,
    draws: Buffer,
    fu: Buffer,
    fx: [Buffer; 3],
    ui: Buffer,
    /// the post uniforms P: bright, the four blurs, the composite (5 vec4: RP_COMP_FX's, the first 2 RP_COMP's), the flame comp, ui's S
    u_bright: Buffer,
    u_blur: [Buffer; 4],
    u_comp: Buffer,
    u_fl: Buffer,
    u_s: Buffer,
    g_empty: BindGroup,
    g_draws: BindGroup,
    g_frame: BindGroup,
    g_u_bright: BindGroup,
    g_u_blur: [BindGroup; 4],
    g_u_comp: BindGroup,
    g_u_fl: BindGroup,
    g_u_s: BindGroup,
    g_font: BindGroup,
    _font: Texture,
    linear: Sampler,
    nearest: Sampler,
    pipes: [Option<CachedRenderPipelineId>; RP_N],
    swap: Option<TextureFormat>,
    targets: Option<Targets>,
    meshes: MeshGpu,
    failed: bool,
}

fn buffer(dev: &RenderDevice, label: &'static str, size: u64, usage: BufferUsages) -> Buffer {
    dev.create_buffer(&BufferDescriptor { label: Some(label), size, usage: usage | BufferUsages::COPY_DST, mapped_at_creation: false })
}

/// port: render.c r_init (+ ui.lisp's r_font_new): the samplers, the per-frame buffers, the font atlas.
fn init_gpu(mut commands: Commands, dev: Res<RenderDevice>, queue: Res<RenderQueue>, cache: Res<PipelineCache>, font: Res<FontBytes>) {
    let layouts = Layouts::new();
    let sampler = |f: FilterMode| {
        dev.create_sampler(&SamplerDescriptor {
            address_mode_u: AddressMode::ClampToEdge,
            address_mode_v: AddressMode::ClampToEdge,
            address_mode_w: AddressMode::ClampToEdge,
            mag_filter: f,
            min_filter: f,
            ..Default::default()
        })
    };
    let (linear, nearest) = (sampler(FilterMode::Linear), sampler(FilterMode::Nearest));
    let draws = buffer(&dev, "duel draws", (R_MAX_DRAWS * DQ_STRIDE * 4) as u64, BufferUsages::STORAGE);
    let fu = buffer(&dev, "duel frame", (FU_FLOATS * 4) as u64, BufferUsages::UNIFORM);
    let fx = [0, 1, 2].map(|_| buffer(&dev, "duel fx", FX_VERTS * 36, BufferUsages::VERTEX));
    let ui = buffer(&dev, "duel ui", UI_VERTS * 32, BufferUsages::VERTEX);
    let u16b = |l| buffer(&dev, l, 16, BufferUsages::UNIFORM);
    let (u_bright, u_comp, u_fl, u_s) = (u16b("duel P bright"), buffer(&dev, "duel P comp", 80, BufferUsages::UNIFORM), u16b("duel P flame"), u16b("duel S"));
    let u_blur = [0, 1, 2, 3].map(|_| u16b("duel P blur"));
    let bgl = |d: &BindGroupLayoutDescriptor| cache.get_bind_group_layout(d);
    let uni = bgl(&layouts.uni);
    let ug = |b: &Buffer| dev.create_bind_group("duel uni", &uni, &BindGroupEntries::single(b.as_entire_binding()));
    let tex = dev.create_texture_with_data(
        &queue,
        &TextureDescriptor {
            label: Some("duel font"),
            size: Extent3d { width: ui::ATLAS_W, height: ui::ATLAS_H, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: TextureDimension::D2,
            format: TextureFormat::R8Unorm,
            usage: TextureUsages::TEXTURE_BINDING | TextureUsages::COPY_DST,
            view_formats: &[],
        },
        bevy::render::render_resource::TextureDataOrder::LayerMajor,
        &font.0,
    );
    let font_view = tex.create_view(&TextureViewDescriptor::default());
    let g = Gpu {
        g_empty: dev.create_bind_group("duel empty", &bgl(&layouts.empty), &[]),
        g_draws: dev.create_bind_group("duel draws", &bgl(&layouts.draws), &BindGroupEntries::single(draws.as_entire_binding())),
        g_frame: ug(&fu),
        g_u_bright: ug(&u_bright),
        g_u_blur: [0, 1, 2, 3].map(|i| ug(&u_blur[i])),
        g_u_comp: ug(&u_comp),
        g_u_fl: ug(&u_fl),
        g_u_s: ug(&u_s),
        g_font: dev.create_bind_group("duel font", &bgl(&layouts.tex[1]), &BindGroupEntries::sequential((&font_view, &nearest))),
        _font: tex,
        layouts,
        draws,
        fu,
        fx,
        ui,
        u_bright,
        u_blur,
        u_comp,
        u_fl,
        u_s,
        linear,
        nearest,
        pipes: [None; RP_N],
        swap: None,
        targets: None,
        meshes: MeshGpu::default(),
        failed: false,
    };
    commands.insert_resource(g);
}

/// render.c r_frame's copy pass: every array into its buffer (n clamped to R_MAX_DRAWS), and the CPU side into `Mirror`. Nothing
/// grows: the mirror's records are reserved for R_MAX_DRAWS and the streams' fills never pass their buffers (STREAM-ROOM-P).
fn extract_frame(src: Extract<Res<FrameRes>>, meshes: Extract<Option<Res<MeshSrc>>>, gpu: Option<ResMut<Gpu>>, queue: Res<RenderQueue>, mut mir: ResMut<Mirror>) {
    let Some(mut gpu) = gpu else { return };
    if let Some(m) = meshes.as_ref() {
        gpu.meshes.set_source(m.0.clone());
    }
    let f = &src.0;
    copy_frame(f, &mut mir);
    let w = |b: &Buffer, v: &[f32]| {
        if !v.is_empty() {
            queue.write_buffer(b, 0, bytemuck::cast_slice(v));
        }
    };
    w(&gpu.fu, &f.fu);
    w(&gpu.draws, bytemuck::cast_slice(&mir.dq));
    w(&gpu.fx[0], &f.fxa[..mir.nfa as usize * 9]);
    w(&gpu.fx[1], &f.fxb[..mir.nfb as usize * 9]);
    w(&gpu.fx[2], &f.ft[..mir.nft as usize * 9]);
    w(&gpu.ui, &f.ui[..mir.nui as usize * 8]);
}

/// The CPU half of the copy (no allocation once `Mirror` is made: tests/alloc.rs).
pub fn copy_frame(f: &FrameOut, mir: &mut Mirror) {
    let n = f.dq.len().min(R_MAX_DRAWS); // (ponytail: render.c's fixed capacity)
    mir.dq.clear();
    mir.dq.extend_from_slice(&f.dq[..n]);
    mir.p = f.p;
    mir.fu159 = f.fu[159];
    let verts = |v: &Vec<f32>, stride: usize, cap: u64| ((v.len() / stride) as u64).min(cap) as u32;
    (mir.nfa, mir.nfb, mir.nft, mir.nui) = (verts(&f.fxa, 9, FX_VERTS), verts(&f.fxb, 9, FX_VERTS), verts(&f.ft, 9, FX_VERTS), verts(&f.ui, 8, UI_VERTS));
    mir.live = true;
}

/// The load (the meshes, a few per frame), the pipelines (once the swapchain's format is known), the targets (render.c r_targets),
/// and READY.
fn prepare(mut gpu: Option<ResMut<Gpu>>, dev: Res<RenderDevice>, queue: Res<RenderQueue>, cache: Res<PipelineCache>, shaders: Res<Shaders>, mir: Res<Mirror>, windows: Query<&ExtractedWindow>) {
    let Some(g) = gpu.as_deref_mut() else { return };
    g.meshes.step(&dev, &queue);
    if g.swap.is_none()
        && let Some(f) = windows.iter().next().and_then(|w| w.swap_chain_texture_format)
    {
        g.swap = Some(f);
        let sh = |n: &str| shaders.0.iter().find(|s| s.0 == n).expect("program").1.clone();
        for d in &DEFS {
            g.pipes[d.slot] = Some(cache.queue_render_pipeline(descriptor(d, &sh, &g.layouts, SCENE_MSAA, f)));
        }
    }
    if mir.live {
        let (w, h) = (mir.p[4] as u32, mir.p[5] as u32);
        if g.targets.as_ref().is_none_or(|t| (t.w, t.h) != (w, h)) {
            g.targets = Some(targets(g, &dev, &cache, w, h));
        }
    }
    let mut ok = g.swap.is_some();
    for (slot, id) in g.pipes.iter().enumerate() {
        let Some(id) = id else { continue };
        match cache.get_render_pipeline_state(*id) {
            CachedPipelineState::Ok(_) => {}
            CachedPipelineState::Err(e) if !g.failed => {
                crate::page::say(&format!("render: pipeline {slot} failed: {e}"));
                g.failed = true;
                ok = false;
            }
            _ => ok = false,
        }
    }
    READY.store(ok && g.meshes.done() && g.targets.is_some(), Relaxed);
}

/// port: render.c r_targets (+ the bind groups that read them).
fn targets(g: &Gpu, dev: &RenderDevice, cache: &PipelineCache, w: u32, h: u32) -> Targets {
    let keep = std::cell::RefCell::new(Vec::new());
    let tex = |w: u32, h: u32, f: TextureFormat, samples: u32, usage: TextureUsages| {
        let t = dev.create_texture(&TextureDescriptor {
            label: Some("duel target"),
            size: Extent3d { width: w.max(1), height: h.max(1), depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: if samples > 1 { 4 } else { 1 },
            dimension: TextureDimension::D2,
            format: f,
            usage,
            view_formats: &[],
        });
        let v = t.create_view(&TextureViewDescriptor::default());
        keep.borrow_mut().push(t);
        v
    };
    let rt = TextureUsages::RENDER_ATTACHMENT | TextureUsages::TEXTURE_BINDING;
    let ms = SCENE_MSAA > 1;
    let scene = tex(w, h, SCENE_FORMAT, 1, rt);
    let msaa = ms.then(|| tex(w, h, SCENE_FORMAT, SCENE_MSAA, TextureUsages::RENDER_ATTACHMENT));
    let flame = tex(w, h, SCENE_FORMAT, 1, rt);
    let flame_msaa = ms.then(|| tex(w, h, SCENE_FORMAT, SCENE_MSAA, TextureUsages::RENDER_ATTACHMENT));
    let depth = tex(w, h, DEPTH_FORMAT, SCENE_MSAA, TextureUsages::RENDER_ATTACHMENT);
    let half = [0, 1].map(|_| tex(w / 2, h / 2, SCENE_FORMAT, 1, rt));
    let q = [0, 1].map(|_| tex(w / 4, h / 4, SCENE_FORMAT, 1, rt));
    let l = |n: usize| cache.get_bind_group_layout(&g.layouts.tex[n]);
    let (l1, l2, l3) = (l(1), l(2), l(3));
    let lin = &g.linear;
    let g1 = |a: &TextureView| dev.create_bind_group("duel tex1", &l1, &BindGroupEntries::sequential((a, lin)));
    Targets {
        g_bright: g1(&scene),
        g_bright_fl: dev.create_bind_group("duel tex2", &l2, &BindGroupEntries::sequential((&scene, lin, &flame, lin))),
        g_blur: [g1(&half[0]), g1(&half[1]), g1(&half[0]), g1(&q[0])],
        g_comp: dev.create_bind_group("duel tex3", &l3, &BindGroupEntries::sequential((&scene, lin, &half[0], lin, &q[1], lin))),
        g_fl: dev.create_bind_group("duel tex1", &l1, &BindGroupEntries::sequential((&flame, &g.nearest))),
        w,
        h,
        scene,
        msaa,
        flame,
        flame_msaa,
        depth,
        half,
        q,
        _keep: keep.into_inner(),
    }
}

/// port: r_draw_queue's choice for one record: drawn in this half (opaque or alpha < 1), and its pipeline: the lit pipes for a
/// transparent record or toon mode 0, RP_HULL for mode 3, RP_TOON for 1 / 2; the clockwise twin when the model's 3x3 determinant
/// is negative (a mirrored transform flips the winding).
pub fn pipe_of(q: &[f32; DQ_STRIDE], transparent: bool) -> Option<usize> {
    if (q[19] < 0.999) != transparent {
        return None;
    }
    let det = q[0] * (q[5] * q[10] - q[9] * q[6]) - q[4] * (q[1] * q[10] - q[9] * q[2]) + q[8] * (q[1] * q[6] - q[5] * q[2]);
    let base = if transparent || q[28] < 0.5 { RP_LIT + 2 * transparent as usize } else if q[28] > 2.5 { RP_HULL } else { RP_TOON };
    Some(base + (det < 0.0) as usize)
}

type Pipes<'a> = [Option<&'a RenderPipeline>; RP_N];

/// The scene pipelines' bind groups (the draw records, the Frame at groups 1 and 3).
fn scene_groups(rp: &mut wgpu::RenderPass, g: &Gpu) {
    rp.set_bind_group(0, &*g.g_draws, &[]);
    rp.set_bind_group(1, &*g.g_frame, &[]);
    rp.set_bind_group(2, &*g.g_empty, &[]);
    rp.set_bind_group(3, &*g.g_frame, &[]);
}

/// port: r_draw_queue. Returns the records drawn.
fn draw_queue(rp: &mut wgpu::RenderPass, g: &Gpu, pipes: &Pipes, dq: &[[f32; DQ_STRIDE]], transparent: bool) -> u32 {
    let (mut cur_pipe, mut cur_buf, mut drawn) = (usize::MAX, u32::MAX, 0);
    for (i, q) in dq.iter().enumerate() {
        let Some(pipe) = pipe_of(q, transparent) else { continue };
        let id = q[23] as i32;
        let Some(m) = (id >= 0).then(|| g.meshes.table.get(id as usize)).flatten().filter(|m| m.count > 0) else { continue };
        if pipe != cur_pipe {
            rp.set_pipeline(pipes[pipe].unwrap());
            cur_pipe = pipe;
        }
        if m.buf != cur_buf {
            rp.set_vertex_buffer(0, (*g.meshes.chunks[m.buf as usize]).slice(..));
            cur_buf = m.buf;
        }
        rp.draw(m.first..m.first + m.count, i as u32..i as u32 + 1);
        drawn += 1;
    }
    drawn
}

/// port: r_draw_batch.
fn draw_batch(rp: &mut wgpu::RenderPass, pipes: &Pipes, pipe: usize, buf: &Buffer, nverts: u32) {
    if nverts == 0 {
        return;
    }
    rp.set_pipeline(pipes[pipe].unwrap());
    rp.set_vertex_buffer(0, (**buf).slice(..));
    rp.draw(0..nverts, 0..1);
}

fn color<'a>(view: &'a WgpuTextureView, resolve: Option<&'a WgpuTextureView>, load: LoadOp<wgpu::Color>, store: StoreOp) -> Option<RenderPassColorAttachment<'a>> {
    Some(RenderPassColorAttachment { view, depth_slice: None, resolve_target: resolve, ops: Operations { load, store } })
}

const CLEAR0: LoadOp<wgpu::Color> = LoadOp::Clear(wgpu::Color::TRANSPARENT);

/// port: r_fs_pass (keep_open 0): a full-screen pass into DST (DONT_CARE load: cleared, every pixel is written).
fn fs_pass(enc: &mut CommandEncoder, dst: &TextureView, pipe: &RenderPipeline, g: &Gpu, tex: &BindGroup, u: &BindGroup) {
    let mut rp = enc.begin_render_pass(&RenderPassDescriptor {
        label: Some("duel post"),
        color_attachments: &[color(&**dst, None, CLEAR0, StoreOp::Store)],
        depth_stencil_attachment: None,
        timestamp_writes: None,
        occlusion_query_set: None,
        multiview_mask: None,
    });
    rp.set_pipeline(pipe);
    rp.set_bind_group(0, &*g.g_empty, &[]);
    rp.set_bind_group(1, &*g.g_empty, &[]);
    rp.set_bind_group(2, &**tex, &[]);
    rp.set_bind_group(3, &**u, &[]);
    rp.draw(0..3, 0..1);
}

/// port: render.c r_frame (the copy pass is `extract_frame`'s). The swapchain is written through a view in its own (non-sRGB)
/// format, as SDL's swapchain (the shaders encode sRGB themselves; Bevy's sRGB view would encode a second time).
fn duel_frame(view: ViewQuery<&ViewTarget>, gpu: Option<Res<Gpu>>, mir: Res<Mirror>, cache: Res<PipelineCache>, queue: Res<RenderQueue>, windows: Query<&ExtractedWindow>, mut ctx: RenderContext) {
    let Some(win) = windows.iter().next() else { return };
    let (Some(st), Some(fmt)) = (win.swap_chain_texture.as_ref(), win.swap_chain_texture_format) else { return };
    // the swapchain in its own format (Chrome: bgra8unorm or rgba8unorm); a surface that is sRGB itself (native) is written as it is
    // (M3A_NOTES §9)
    let swap_view = st.texture.create_view(&TextureViewDescriptor { format: Some(fmt), ..Default::default() });
    // Bevy presents a window only when its view target's output was used this frame, and keeps an unpresented swapchain texture for
    // the next update, where the web canvas has already expired it: mark it every frame (the passes below, or the clear, write it)
    let _ = view.into_inner().out_texture_color_attachment(None);
    let ready_frame = gpu.as_deref().filter(|g| ready() && mir.live && g.targets.is_some());
    let Some(g) = ready_frame else {
        // still loading: a cleared canvas (render.c never draws before its pipelines exist either)
        ctx.command_encoder().begin_render_pass(&RenderPassDescriptor {
            label: Some("duel loading"),
            color_attachments: &[color(&swap_view, None, LoadOp::Clear(wgpu::Color::BLACK), StoreOp::Store)],
            depth_stencil_attachment: None,
            timestamp_writes: None,
            occlusion_query_set: None,
            multiview_mask: None,
        });
        return;
    };
    let t = g.targets.as_ref().unwrap();
    let mut pipes: Pipes = [None; RP_N];
    for (i, id) in g.pipes.iter().enumerate() {
        pipes[i] = id.and_then(|id| cache.get_render_pipeline(id));
    }
    let p = &mir.p;
    let (nfa, nfb, nui, nft) = (mir.nfa, mir.nfb, mir.nui, mir.nft);
    let ms = SCENE_MSAA > 1;
    let enc = ctx.command_encoder();

    // scene: sky, opaque (+ ink hulls), transparent, toon fx, fx; MSAA resolves into the scene target
    let layer = p[24] < 1.0 && nft > 0;
    let (sv, sr): (&WgpuTextureView, Option<&WgpuTextureView>) = if ms { (t.msaa.as_ref().unwrap(), Some(&t.scene)) } else { (&t.scene, None) };
    let resolve_store = if ms { StoreOp::Discard } else { StoreOp::Store };
    let depth = |load: LoadOp<f32>, store: StoreOp| {
        Some(RenderPassDepthStencilAttachment { view: &t.depth, depth_ops: Some(Operations { load, store }), stencil_ops: None })
    };
    {
        let mut rp = enc.begin_render_pass(&RenderPassDescriptor {
            label: Some("duel scene"),
            color_attachments: &[color(sv, sr, CLEAR0, if layer { StoreOp::Store } else { resolve_store })],
            depth_stencil_attachment: depth(LoadOp::Clear(1.0), if layer { StoreOp::Store } else { StoreOp::Discard }),
            timestamp_writes: None,
            occlusion_query_set: None,
            multiview_mask: None,
        });
        scene_groups(&mut rp, g);
        if p[22] == 0.0 {
            rp.set_pipeline(pipes[if p[10] != 0.0 { RP_SKY_TOON } else { RP_SKY }].unwrap());
            rp.draw(0..3, 0..1); // (transparent: the clear (0,0,0,0) stays)
        }
        draw_queue(&mut rp, g, &pipes, &mir.dq, false);
        draw_queue(&mut rp, g, &pipes, &mir.dq, true);
        if !layer {
            draw_batch(&mut rp, &pipes, RP_FXT, &g.fx[2], nft);
            if mir.fu159 > 0.0 {
                draw_batch(&mut rp, &pipes, RP_FXT_F, &g.fx[2], nft); // the soft flame's fringe: FU[159] = feather px
            }
            draw_batch(&mut rp, &pipes, RP_FXA, &g.fx[0], nfa);
            draw_batch(&mut rp, &pipes, RP_FXB, &g.fx[1], nfb);
        } else {
            draw_batch(&mut rp, &pipes, RP_FXT_N, &g.fx[2], nft); // every toon fx but the flames
        }
    }
    if layer {
        {
            // pass B: the flame layer, cleared to 0, sharing the scene's depth
            let (lv, lr): (&WgpuTextureView, Option<&WgpuTextureView>) = if ms { (t.flame_msaa.as_ref().unwrap(), Some(&t.flame)) } else { (&t.flame, None) };
            let mut rp = enc.begin_render_pass(&RenderPassDescriptor {
                label: Some("duel flame layer"),
                color_attachments: &[color(lv, lr, CLEAR0, resolve_store)],
                depth_stencil_attachment: depth(LoadOp::Load, StoreOp::Store),
                timestamp_writes: None,
                occlusion_query_set: None,
                multiview_mask: None,
            });
            scene_groups(&mut rp, g);
            draw_batch(&mut rp, &pipes, RP_FXT_L, &g.fx[2], nft);
            if mir.fu159 > 0.0 {
                draw_batch(&mut rp, &pipes, RP_FXT_FL, &g.fx[2], nft);
            }
        }
        // pass C: the layer over the scene at one opacity (P.x = rp[24]), then the other fx
        queue.write_buffer(&g.u_fl, 0, bytemuck::cast_slice(&[p[24], 0.0, 0.0, 0.0]));
        let mut rp = enc.begin_render_pass(&RenderPassDescriptor {
            label: Some("duel scene C"),
            color_attachments: &[color(sv, sr, LoadOp::Load, resolve_store)],
            depth_stencil_attachment: depth(LoadOp::Load, StoreOp::Discard),
            timestamp_writes: None,
            occlusion_query_set: None,
            multiview_mask: None,
        });
        rp.set_pipeline(pipes[RP_COMP_FL].unwrap());
        rp.set_bind_group(0, &*g.g_empty, &[]);
        rp.set_bind_group(1, &*g.g_empty, &[]);
        rp.set_bind_group(2, &*t.g_fl, &[]);
        rp.set_bind_group(3, &*g.g_u_fl, &[]);
        rp.draw(0..3, 0..1);
        scene_groups(&mut rp, g); // (the Frame back for the fx below)
        draw_batch(&mut rp, &pipes, RP_FXA, &g.fx[0], nfa);
        draw_batch(&mut rp, &pipes, RP_FXB, &g.fx[1], nfb);
    }

    // bloom: bright pass at 1/2, separable blur at 1/2 and 1/4
    let bloom = p[0] != 0.0;
    let (hw, hh, qw, qh) = ((t.w / 2).max(1) as f32, (t.h / 2).max(1) as f32, (t.w / 4).max(1) as f32, (t.h / 4).max(1) as f32);
    if bloom {
        let wq = |b: &Buffer, u: [f32; 4]| queue.write_buffer(b, 0, bytemuck::cast_slice(&u));
        if layer {
            wq(&g.u_bright, [p[1], p[23], p[24], 0.0]);
            fs_pass(enc, &t.half[0], pipes[RP_BRIGHT_FL].unwrap(), g, &t.g_bright_fl, &g.g_u_bright);
        } else {
            wq(&g.u_bright, [p[1], p[23], 0.0, 0.0]);
            fs_pass(enc, &t.half[0], pipes[RP_BRIGHT].unwrap(), g, &t.g_bright, &g.g_u_bright);
        }
        let steps = [([1.0 / hw, 0.0, 0.0, 0.0], &t.half[1]), ([0.0, 1.0 / hh, 0.0, 0.0], &t.half[0]), ([1.0 / qw, 0.0, 0.0, 0.0], &t.q[0]), ([0.0, 1.0 / qh, 0.0, 0.0], &t.q[1])];
        for (i, (u, dst)) in steps.into_iter().enumerate() {
            wq(&g.u_blur[i], u);
            fs_pass(enc, dst, pipes[RP_BLUR].unwrap(), g, &t.g_blur[i], &g.g_u_blur[i]);
        }
    }

    // the split (split.wgsl), in window heights: *GRADE-SPLIT*'s shear, or the cut's while it is on (its open >= 0)
    let wh = if p[7] > 0.0 { p[7] } else { 1.0 };
    let cut_on = p[28] != 0.0 || p[29] != 0.0;
    let shear = if cut_on { p[28] / wh } else if p[7] > 0.0 { p[9] / p[7] } else { 0.0 };
    let cut = if cut_on { [(p[25] - 0.5 * p[6]) / wh, (p[26] - 0.5 * wh) / wh, p[27], p[29] / wh] } else { [0.0, 0.0, 0.0, -1.0] };
    let strength = if bloom { p[2] } else { 0.0 };

    // composite to the swapchain, then the UI on top in the same pass (the paint stream hb / hk: M3b)
    let (pipe, u): (usize, [f32; 20]) = if p[11] != 0.0 && p[22] == 0.0 {
        let u = [strength, p[3], p[8], shear, p[11], p[12], p[13], p[14], p[15], p[16], p[17], p[21], p[18], p[19], p[20], 0.0, cut[0], cut[1], cut[2], cut[3]];
        (RP_COMP_FX, u)
    } else {
        let mut u = [0.0; 20];
        u[..8].copy_from_slice(&[strength, p[3], p[8], shear, cut[0], cut[1], cut[2], cut[3]]);
        (if p[22] != 0.0 { RP_COMP_A } else { RP_COMP }, u)
    };
    queue.write_buffer(&g.u_comp, 0, bytemuck::cast_slice(&u));
    let mut rp = enc.begin_render_pass(&RenderPassDescriptor {
        label: Some("duel composite"),
        color_attachments: &[color(&swap_view, None, CLEAR0, StoreOp::Store)],
        depth_stencil_attachment: None,
        timestamp_writes: None,
        occlusion_query_set: None,
        multiview_mask: None,
    });
    rp.set_pipeline(pipes[pipe].unwrap());
    rp.set_bind_group(0, &*g.g_empty, &[]);
    rp.set_bind_group(1, &*g.g_empty, &[]);
    rp.set_bind_group(2, &*t.g_comp, &[]);
    rp.set_bind_group(3, &*g.g_u_comp, &[]);
    rp.draw(0..3, 0..1);
    if nui > 0 {
        queue.write_buffer(&g.u_s, 0, bytemuck::cast_slice(&[p[6], p[7], 0.0, 0.0]));
        rp.set_pipeline(pipes[RP_UI].unwrap());
        rp.set_bind_group(1, &*g.g_u_s, &[]);
        rp.set_bind_group(2, &*g.g_font, &[]);
        rp.set_bind_group(3, &*g.g_empty, &[]);
        rp.set_vertex_buffer(0, (*g.ui).slice(..));
        rp.draw(0..nui, 0..1);
    }
    drop(rp);
    DREW.store(true, Relaxed);
}

/// After the submit: a drawn frame is counted, and counted again as done when the GPU finished it (the page's frame-done counter).
fn count_frames(queue: Res<RenderQueue>) {
    if DREW.swap(false, Relaxed) {
        SUBMITTED.fetch_add(1, Relaxed);
        queue.on_submitted_work_done(|| {
            DONE.fetch_add(1, Relaxed);
        });
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn record_pipes() {
        let mut q = [0.0f32; DQ_STRIDE];
        (q[0], q[5], q[10], q[19]) = (1.0, 1.0, 1.0, 1.0);
        assert_eq!(pipe_of(&q, false), Some(RP_LIT));
        assert_eq!(pipe_of(&q, true), None);
        q[28] = 2.0;
        assert_eq!(pipe_of(&q, false), Some(RP_TOON));
        q[28] = 3.0;
        q[0] = -1.0; // mirrored
        assert_eq!(pipe_of(&q, false), Some(RP_HULL + 1));
        q[19] = 0.5; // alpha < 1: the lit transparent pipes whatever the toon mode
        assert_eq!(pipe_of(&q, true), Some(RP_LIT_T + 1));
    }

    #[test]
    fn copy_frame_clamps_within_capacity() {
        // (the allocation count of the copy and the driver: tests/alloc.rs)
        let mut f = FrameOut::default();
        f.dq.resize(R_MAX_DRAWS + 10, [0.0; DQ_STRIDE]);
        let mut m = Mirror::default();
        let cap = m.dq.capacity();
        copy_frame(&f, &mut m);
        assert_eq!((m.dq.len(), m.dq.capacity()), (R_MAX_DRAWS, cap));
    }
}
