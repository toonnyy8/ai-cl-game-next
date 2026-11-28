//! The canvas stream's font atlas (ui.lisp UI-INIT's r_font_new): the 5x7 font of `+FONT-5X7+` (duel-data's tuning.json) baked into
//! a 96 x 48 R8 texture, 16 x 6 cells of 6 x 8, cell 95 solid white (the flat colour's texel).

/// ui.lisp +ATLAS-W+ / +ATLAS-H+.
pub const ATLAS_W: u32 = 96;
pub const ATLAS_H: u32 = 48;

/// port: engine/lisp/ui.lisp FONT-ATLAS-BYTES (FONT = `+font-5x7+`'s 95 x 5 column bytes, bit 0 = the top row).
pub fn atlas_bytes(font: &[u8]) -> Vec<u8> {
    let mut img = vec![0u8; (ATLAS_W * ATLAS_H) as usize];
    for g in 0..96usize {
        let (cx, cy) = ((g % 16) * 6, (g / 16) * 8);
        for col in 0..6 {
            for row in 0..8 {
                let on = g == 95 || (col < 5 && row < 7 && (font[g * 5 + col] >> row) & 1 == 1);
                if on {
                    img[(cy + row) * ATLAS_W as usize + cx + col] = 255;
                }
            }
        }
    }
    img
}

/// `+font-5x7+` from the data (the tuning entry is its byte list).
pub fn font_5x7(d: &duel_data::Data) -> Vec<u8> {
    let v = d.tuning.get("+FONT-5X7+").and_then(|v| v.as_array()).expect("tuning +FONT-5X7+");
    v.iter().map(|x| x.as_u64().expect("+FONT-5X7+ byte") as u8).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn atlas_cells() {
        let f = font_5x7(&duel_data::Data::embedded());
        assert_eq!(f.len(), 95 * 5);
        let a = atlas_bytes(&f);
        // the white cell (95) is solid; '!' (g 1) is column 2 rows 0..4 and 6 (#x5F)
        assert!((0..8).all(|r| (0..6).all(|c| a[(40 + r) * 96 + 90 + c] == 255)));
        assert_eq!((0..8).map(|r| a[r * 96 + 6 + 2] / 255).collect::<Vec<_>>(), [1, 1, 1, 1, 1, 0, 1, 0]);
    }
}
