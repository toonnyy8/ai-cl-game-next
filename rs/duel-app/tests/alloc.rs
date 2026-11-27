//! 0 allocations per drawn frame on the CPU half of the page's path (M3a Task 9): the driver's frame (`Game::frame`: the commands
//! due, the loop's three calls) and the render world's CPU copy (`render::copy_frame`: the draw records into the reserved mirror),
//! counted by a global allocator over a CPU fight (debug 2005) after its command frame. Not counted (they need a GPU device):
//! `extract_frame`'s `write_buffer` calls (wgpu's staging), `duel_frame` (its pass objects and the swapchain view's `create_view`), and
//! `count_frames`' work-done callback box (M3A_NOTES §9).
use duel_app::driver::Game;
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
    g.queue_cmd(2005, 1);
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
