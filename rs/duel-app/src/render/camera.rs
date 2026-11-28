//! The one camera setup every view uses (docs/bevy/M0_NOTES.md §1, §2).
use bevy::light::cluster::ClusterConfig;
use bevy::prelude::*;
use bevy::render::camera::CameraRenderGraph;
use bevy::core_pipeline::tonemapping::DebandDither;
use bevy::render::view::{Msaa, Tonemapping};

/// Spawn every camera with this:
/// - `ClusterConfig::None`: the other half of `page::no_light_clustering` (the headless device loss, M0_NOTES §1);
/// - `Tonemapping::None`, `DebandDither::Disabled`: the port grades in its own shaders (the default TonyMcMapFace also needs the
///   `tonemapping_luts` feature; Bevy warns about a dither it would not apply);
/// - `CameraRenderGraph(DuelGraph)`: the camera runs render.c's frame (`render::duel_frame`), not Bevy's core 3D passes, which
///   would re-sort the draw records and write the swapchain through its sRGB view (M3A_NOTES §9);
/// - `Msaa::Off`: Bevy's own (unused) main textures stay single-sample; the scene's MSAA is `render::SCENE_MSAA`, render.c's own.
pub fn camera_bundle() -> impl Bundle {
    (Camera3d::default(), ClusterConfig::None, Tonemapping::None, DebandDither::Disabled, Msaa::Off, CameraRenderGraph::new(super::DuelGraph))
}
