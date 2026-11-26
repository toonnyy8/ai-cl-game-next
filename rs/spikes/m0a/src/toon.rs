//! The toon and ink-hull materials of the M0a replay: engine/shaders/toon.{vert,frag}.wgsl ported to a Bevy `Material`
//! (the user: 「全部用 Bevy 繪圖」). One material per draw slot; its lanes are the original's Draw record (tint, fx, toon)
//! and the Frame lanes the toon entry points read. Hulls cull front faces (RP_HULL), mirrored hulls back faces (RP_HULL_CW).
use bevy::{
    mesh::MeshVertexBufferLayoutRef,
    pbr::{MaterialPipeline, MaterialPipelineKey},
    prelude::*,
    reflect::TypePath,
    render::render_resource::{AsBindGroup, Face, RenderPipelineDescriptor, ShaderType, SpecializedMeshPipelineError},
    shader::ShaderRef,
};

pub const SHADER: &str = "embedded://m0a/shaders/toon.wesl";

/// The lanes one draw needs: its Draw record's tint / fx / toon, and the Frame lanes of engine/shaders/frame.wgsl that
/// fs_toon / vs_hull / fs_ink read (key, toon, shd, cin, fog, fogh, moon_dir, cam, scr).
#[derive(ShaderType, Clone, Copy, Debug, Default, PartialEq)]
pub struct ToonLanes {
    pub tint: Vec4,
    pub fx: Vec4,
    pub toon: Vec4,
    pub key: Vec4,
    pub toon_f: Vec4,
    pub shd: Vec4,
    pub cin: Vec4,
    pub fog: Vec4,
    pub fogh: Vec4,
    pub moon_dir: Vec4,
    pub cam: Vec4,
    pub scr: Vec4,
}

macro_rules! toon_material {
    ($name:ident, $vs:literal, $fs:literal, $cull:expr) => {
        #[derive(Asset, TypePath, AsBindGroup, Debug, Clone)]
        pub struct $name {
            #[uniform(0)]
            pub lanes: ToonLanes,
        }
        impl Material for $name {
            fn vertex_shader() -> ShaderRef {
                SHADER.into()
            }
            fn fragment_shader() -> ShaderRef {
                SHADER.into()
            }
            fn specialize(
                _p: &MaterialPipeline,
                d: &mut RenderPipelineDescriptor,
                layout: &MeshVertexBufferLayoutRef,
                _k: MaterialPipelineKey<Self>,
            ) -> Result<(), SpecializedMeshPipelineError> {
                d.vertex.buffers = vec![layout.0.get_layout(&[
                    Mesh::ATTRIBUTE_POSITION.at_shader_location(0),
                    Mesh::ATTRIBUTE_NORMAL.at_shader_location(1),
                    Mesh::ATTRIBUTE_COLOR.at_shader_location(2),
                ])?];
                d.vertex.entry_point = Some($vs.into());
                if let Some(f) = d.fragment.as_mut() {
                    f.entry_point = Some($fs.into());
                }
                d.primitive.cull_mode = $cull;
                Ok(())
            }
        }
    };
}

// Toon draws: no culling (Bevy's winding under a mirrored model is not the original's RP_TOON_CW split; closed meshes,
// depth-tested, so only overdraw is added: the measurement's pessimistic side).
toon_material!(ToonMaterial, "vs_toon", "fs_toon", None);
toon_material!(HullMaterial, "vs_hull", "fs_ink", Some(Face::Front));
toon_material!(HullCwMaterial, "vs_hull", "fs_ink", Some(Face::Back));

/// The Frame lanes out of a captured frame uniform block FU (struct Frame, 160 floats; offsets in vec4s:
/// vp 0-3, inv_vp 4-7, cam 8, fog 9, fogh 10, amb_sky 11, amb_ground 12, moon_dir 13, moon_col 14, rim 15, sky_top 16,
/// spec 17, lp 18-25, lc 26-33, key 34, toon 35, shd 36, scr 37, cin 38, clk 39).
pub fn frame_lanes(fu: &[f32; 160]) -> ToonLanes {
    let v = |i: usize| Vec4::from_slice(&fu[4 * i..4 * i + 4]);
    ToonLanes {
        cam: v(8),
        fog: v(9),
        fogh: v(10),
        moon_dir: v(13),
        key: v(34),
        toon_f: v(35),
        shd: v(36),
        scr: v(37),
        cin: v(38),
        ..default()
    }
}

/// FRAME's lanes with draw record REC's tint (16-19), fx (20-23) and toon (28-31).
pub fn draw_lanes(frame: &ToonLanes, rec: &[f32; 32]) -> ToonLanes {
    ToonLanes {
        tint: Vec4::from_slice(&rec[16..20]),
        fx: Vec4::from_slice(&rec[20..24]),
        toon: Vec4::from_slice(&rec[28..32]),
        ..*frame
    }
}
