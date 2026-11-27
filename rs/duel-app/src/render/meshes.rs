//! port: engine/c/render.c r_mesh_new: every mesh of `duel_look::mesh::Meshes` uploaded once into 4 MB vertex-buffer chunks (a mesh =
//! chunk, first vertex, count; 36-byte vertices: position, normal, sRGB colour), a few per frame during the load (the frozen game's
//! `:load` steps), indexed by the Lisp mesh id the draw records carry (record[23]).
use bevy::render::render_resource::{Buffer, BufferDescriptor, BufferUsages};
use bevy::render::renderer::{RenderDevice, RenderQueue};
use duel_look::mesh::Meshes;
use std::sync::Arc;

/// render.c R_CHUNK.
const CHUNK: u64 = 4 << 20;
/// Bytes uploaded per frame during the load.
pub const BUDGET: u64 = 2 << 20;

#[derive(Clone, Copy, Default)]
pub struct RMesh {
    pub buf: u32,
    pub first: u32,
    pub count: u32,
}

#[derive(Default)]
pub struct MeshGpu {
    pub chunks: Vec<Buffer>,
    used: u64,
    cap: u64,
    /// By mesh id (count 0: none).
    pub table: Vec<RMesh>,
    src: Option<Arc<Meshes>>,
    todo: Vec<u32>,
    next: usize,
}

impl MeshGpu {
    /// The meshes to upload (once).
    pub fn set_source(&mut self, m: Arc<Meshes>) {
        if self.src.is_none() {
            self.todo = m.filled().collect();
            self.src = Some(m);
        }
    }
    pub fn done(&self) -> bool {
        self.src.is_some() && self.next == self.todo.len()
    }
    /// Upload the next meshes, about BUDGET bytes.
    pub fn step(&mut self, dev: &RenderDevice, queue: &RenderQueue) {
        let Some(src) = self.src.clone() else { return };
        let mut sent = 0u64;
        while self.next < self.todo.len() && sent < BUDGET {
            let id = self.todo[self.next];
            self.next += 1;
            let v = &src.get(id).expect("filled mesh").floats;
            let n = (v.len() / 9) as u32;
            let size = n as u64 * 36;
            if self.table.len() <= id as usize {
                self.table.resize(id as usize + 1, RMesh::default());
            }
            if n == 0 {
                continue;
            }
            if self.chunks.is_empty() || self.used + size > self.cap {
                self.cap = size.max(CHUNK);
                self.chunks.push(dev.create_buffer(&BufferDescriptor {
                    label: Some("duel mesh chunk"),
                    size: self.cap,
                    usage: BufferUsages::VERTEX | BufferUsages::COPY_DST,
                    mapped_at_creation: false,
                }));
                self.used = 0;
            }
            self.table[id as usize] = RMesh { buf: self.chunks.len() as u32 - 1, first: (self.used / 36) as u32, count: n };
            queue.write_buffer(self.chunks.last().unwrap(), self.used, bytemuck::cast_slice(&v[..n as usize * 9]));
            self.used += size;
            sent += size;
        }
    }
}
