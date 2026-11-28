//! 0 allocations per drawn frame on the CPU half of the page's path (M3a Task 9): the driver's frame (`Game::frame`: the commands
//! due, the loop's three calls) and the render world's CPU copy (`render::copy_frame`: the draw records into the reserved mirror),
//! counted by a global allocator over a CPU fight (debug 2005) after its command frame. Not counted (they need a GPU device):
//! `extract_frame`'s `write_buffer` calls (wgpu's staging), `duel_frame` (its pass objects and the swapchain view's `create_view`), and
//! `count_frames`' work-done callback box (M3A_NOTES §9).
use duel_app::game::Game;
use duel_app::render::{copy_frame, Mirror};
use duel_data::Data;
use duel_look::{FrameOut, SceneInputs};
use std::alloc::{GlobalAlloc, Layout, System};
use std::cell::Cell;

thread_local! { static N: Cell<u64> = const { Cell::new(0) }; }
struct Counting;
unsafe impl GlobalAlloc for Counting {
    unsafe fn alloc(&self, l: Layout) -> *mut u8 {
        let _ = N.try_with(|n| n.set(n.get() + 1));
        unsafe { System.alloc(l) }
    }
    unsafe fn realloc(&self, p: *mut u8, l: Layout, size: usize) -> *mut u8 {
        let _ = N.try_with(|n| n.set(n.get() + 1));
        unsafe { System.realloc(p, l, size) }
    }
    unsafe fn dealloc(&self, p: *mut u8, l: Layout) {
        unsafe { System.dealloc(p, l) }
    }
}
#[global_allocator]
static A: Counting = Counting;
fn count() -> u64 {
    N.with(Cell::get)
}

#[test]
fn page_cpu_half_allocates_nothing() {
    let data: &'static Data = Box::leak(Box::new(Data::embedded()));
    let inputs = SceneInputs { width: 640, height: 360, density: 1.0, msaa: 4, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 };
    let mut g = Game::new(data, inputs);
    let mut out = FrameOut::default();
    let mut mir = Mirror::default();
    g.queue_cmd(2005);
    let (mut n, mut frames) = (0u64, 0u64);
    for f in 1..=3600 {
        let a0 = count();
        assert!(g.frame(&mut out, duel_sim::flow::raw_dt(f)), "stopped: {:?}", g.stopped);
        copy_frame(&out, &mut mir);
        if f > 1 {
            n += count() - a0;
            frames += 1;
        }
    }
    println!("page frames: {n} allocations in {frames} frames after the command frame");
    assert!(g.m.match_tick > 0, "the fight ran");
    assert_eq!(n, 0);
}

/// M3a Task 10: the same over the page's default game, a VS CPU match (human Kenpachi on the keyboard vs a NORMAL Ichigo, whose MCTS
/// jobs roll out with the human's held keys read again: `Keyboard::rollout_read`), with the keyboard read (scripted held keys and
/// presses through `Keyboard::set`, as main.rs's update) and the dev line drawn every frame. Counted from the frame after the first
/// rollout (`*mc-full-stats*`' rollouts > 0), which makes the stand-in brain for the human (`mcts::rollout_start`; kept in the scratch
/// match and reused from then on: frame 2313 here; START-MATCH's buffers are made before, outside the battle) to frame 4800, an Esc
/// pause and its resume included.
#[test]
fn page_vs_cpu_keys_and_dev_line_allocate_nothing() {
    use duel_app::input::Key;
    let data: &'static Data = Box::leak(Box::new(Data::embedded()));
    let inputs = SceneInputs { width: 640, height: 360, density: 1.0, msaa: 4, render_scale: 1.0, pixel_lights: 8, coarse: false, scene_scale_cap: 1.0, safe_top: 0.0, safe_bottom: 0.0 };
    let mut g = Game::new(data, inputs);
    (g.start, g.dev) = (Some(duel_app::game::Start::default()), true);
    let mut out = FrameOut::default();
    let mut mir = Mirror::default();
    let (mut n, mut frames, mut warm) = (0u64, 0u64, None);
    for f in 1..=4800i64 {
        // walk in, then J / Shift+J / Space presses every few frames; Esc twice (a pause of 20 frames) at 3000
        let held = match f % 90 {
            0..30 => Key::D.bit(),
            30..40 => Key::J.bit(),
            50..60 => Key::J.bit() | Key::LShift.bit(),
            70..75 => Key::Space.bit(),
            _ => 0,
        };
        let pressed = if f == 3000 || f == 3020 { Key::Escape.bit() } else { 0 };
        let a0 = count();
        g.kb.set(held, pressed);
        assert!(g.frame(&mut out, duel_sim::flow::raw_dt(f)), "stopped: {:?}", g.stopped);
        copy_frame(&out, &mut mir);
        if warm.is_some() {
            n += count() - a0;
            frames += 1;
        } else if g.s.mc_stats[1] > 0 {
            warm = Some(f);
        }
    }
    println!("vs page frames: {n} allocations in {frames} frames after the first vs rollout (frame {warm:?}); match tick {}", g.m.match_tick);
    assert!(frames >= 1500 && g.m.match_tick > 3000 && !out.ui.is_empty(), "the fight ran, the dev line drawn");
    assert_eq!(n, 0);
}
