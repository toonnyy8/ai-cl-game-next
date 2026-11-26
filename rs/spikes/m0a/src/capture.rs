//! frames.bin decoder: the frames tools/port/capture/stubs-capture.c records from the frozen game (M0a, Task 2). No Bevy types.

pub struct CapMesh {
    pub id: u32,
    pub verts: Vec<[f32; 9]>, // pos xyz, normal xyz, sRGB rgb (+vertex-floats+)
}

pub struct CapDraw {
    pub mesh: u32,
    pub pipe: u32,       // 0 lit, 1 toon, 2 ink hull, +3 transparent (render.c r_draw_queue)
    pub rec: [f32; 32],  // struct Draw: model (column-major), tint, fx, rim, toon
}

pub struct CapFrame {
    pub tick: u32,
    pub fu: [f32; 160], // struct Frame (engine/shaders/frame.wgsl)
    pub draws: Vec<CapDraw>,
}

pub struct Capture {
    pub meshes: Vec<CapMesh>,
    pub frames: Vec<CapFrame>,
}

struct Rd<'a> {
    b: &'a [u8],
    o: usize,
}

impl Rd<'_> {
    fn take(&mut self, n: usize) -> Result<&[u8], String> {
        let end = self.o.checked_add(n).ok_or("overflow")?;
        let s = self.b.get(self.o..end).ok_or_else(|| format!("truncated at byte {}", self.o))?;
        self.o = end;
        Ok(s)
    }
    fn u32(&mut self) -> Result<u32, String> {
        Ok(u32::from_le_bytes(self.take(4)?.try_into().unwrap()))
    }
    fn f32s<const N: usize>(&mut self) -> Result<[f32; N], String> {
        let s = self.take(4 * N)?;
        let mut a = [0f32; N];
        for (i, c) in s.chunks_exact(4).enumerate() {
            a[i] = f32::from_le_bytes(c.try_into().unwrap());
        }
        Ok(a)
    }
}

impl Capture {
    pub fn parse(b: &[u8]) -> Result<Capture, String> {
        let mut r = Rd { b, o: 0 };
        if r.take(8)? != b"SDCAP1\0\0" {
            return Err("bad magic".into());
        }
        let (nm, nf) = (r.u32()?, r.u32()?);
        let mut meshes = Vec::with_capacity(nm as usize);
        for _ in 0..nm {
            let id = r.u32()?;
            let nv = r.u32()? as usize;
            let mut verts = Vec::with_capacity(nv);
            for _ in 0..nv {
                verts.push(r.f32s::<9>()?);
            }
            meshes.push(CapMesh { id, verts });
        }
        let mut frames = Vec::with_capacity(nf as usize);
        for _ in 0..nf {
            let tick = r.u32()?;
            let fu = r.f32s::<160>()?;
            let nd = r.u32()? as usize;
            let mut draws = Vec::with_capacity(nd);
            for _ in 0..nd {
                draws.push(CapDraw { mesh: r.u32()?, pipe: r.u32()?, rec: r.f32s::<32>()? });
            }
            frames.push(CapFrame { tick, fu, draws });
        }
        if r.o != b.len() {
            return Err(format!("{} trailing bytes", b.len() - r.o));
        }
        Ok(Capture { meshes, frames })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn build(meshes: &[(u32, usize)], draws_per_frame: &[usize]) -> Vec<u8> {
        let mut b = b"SDCAP1\0\0".to_vec();
        b.extend((meshes.len() as u32).to_le_bytes());
        b.extend((draws_per_frame.len() as u32).to_le_bytes());
        for &(id, nv) in meshes {
            b.extend(id.to_le_bytes());
            b.extend((nv as u32).to_le_bytes());
            b.extend(std::iter::repeat_n(0u8, nv * 36));
        }
        for (t, &nd) in draws_per_frame.iter().enumerate() {
            b.extend((t as u32).to_le_bytes());
            b.extend(std::iter::repeat_n(0u8, 640));
            b.extend((nd as u32).to_le_bytes());
            for _ in 0..nd {
                b.extend(1u32.to_le_bytes());
                b.extend(1u32.to_le_bytes());
                b.extend(std::iter::repeat_n(0u8, 128));
            }
        }
        b
    }

    #[test]
    fn parses_header_and_counts() {
        let c = Capture::parse(&build(&[(0, 3), (1, 6)], &[2])).unwrap();
        assert_eq!(c.meshes.len(), 2);
        assert_eq!(c.meshes[1].verts.len(), 6);
        assert_eq!(c.frames[0].draws.len(), 2);
        assert_eq!(c.frames[0].draws[0].mesh, 1);
    }

    #[test]
    fn rejects_bad_magic() {
        let mut b = build(&[(0, 3)], &[1]);
        b[0] = b'X';
        assert!(Capture::parse(&b).is_err());
    }

    #[test]
    fn rejects_truncated() {
        let b = build(&[(0, 3)], &[1]);
        assert!(Capture::parse(&b[..b.len() - 1]).is_err());
    }
}
