//! Look data and pure presentation math (no Bevy).
pub mod anim;
pub mod draw;
pub mod mesh;
pub mod rig;
pub mod rng;
pub mod scene;

pub use draw::{draw_frame, FrameOut};
pub use rng::CosRng;
pub use scene::{Scene, SceneInputs};
