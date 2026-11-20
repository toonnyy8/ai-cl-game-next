// flame-comp.frag.wgsl — RP_COMP_FL (docs/style/STYLE_STORM_DESIGN.md §15.6): the flame layer (premultiplied, cleared to 0)
// laid over the scene target at one opacity P.x = *FLAME-ALPHA*, blended premultiplied over (one, one minus source alpha):
// scene x (1 - P.x a) + P.x x layer. Same size as the scene, sampled nearest at the pixel centres. Its own file: the shader
// loader counts the samplers in the whole source.
// #include "fullscreen.vert.wgsl"
@group(3) @binding(0) var<uniform> P: vec4f;
@group(2) @binding(0) var t0: texture_2d<f32>;
@group(2) @binding(1) var s0: sampler;
@fragment fn fs_flame_comp(i: Post) -> @location(0) vec4f { return textureSample(t0, s0, i.uv) * P.x; }
