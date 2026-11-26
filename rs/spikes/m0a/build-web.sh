#!/usr/bin/env bash
# M0a: the Bevy replay page as index.html + index.js + index.wasm in dist/bevy-m0a (the Artifact publish flow's three files).
# Needs build/port/capture/frames.bin (tools/port/capture), wasm-bindgen-cli at rs/Cargo.lock's wasm-bindgen version, and
# binaryen's wasm-opt (emsdk's, or WASM_OPT).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); root=$(cd "$here/../../.." && pwd); out="$root/dist/bevy-m0a"
WASM_OPT=${WASM_OPT:-$(command -v wasm-opt || echo /media/8tsp/projects/emsdk/upstream/bin/wasm-opt)}
cd "$root/rs"
RUSTFLAGS='--cfg getrandom_backend="wasm_js"' cargo build -p m0a --release --target wasm32-unknown-unknown
rm -rf "${out:?}"; mkdir -p "$out"
wasm-bindgen --target web --no-typescript --out-name index --out-dir "$out" target/wasm32-unknown-unknown/release/m0a.wasm
mv "$out/index_bg.wasm" "$out/index.wasm"
"$WASM_OPT" -Oz --enable-bulk-memory --enable-nontrapping-float-to-int --enable-sign-ext --enable-mutable-globals \
  --enable-reference-types --enable-multivalue "$out/index.wasm" -o "$out/index.wasm"
cp "$here/web/index.html" "$out/index.html"
ls -l "$out"
