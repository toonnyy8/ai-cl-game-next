#!/usr/bin/env bash
# Bevy port: a crate of rs/ as a page (index.html + index.js + index.wasm, the Artifact publish flow's files, + index.gzip.wasm).
#   tools/port/build-web.sh <crate> <out_dir> [release|web-dev]     e.g. tools/port/build-web.sh duel-app dist/rs-blank
# release (default): the measured page's settings, then wasm-opt -Oz; web-dev: rs/Cargo.toml's fast profile, no wasm-opt.
# The page shell is rs/<crate>/web/index.html. Needs wasm-bindgen-cli at rs/Cargo.lock's wasm-bindgen version (~/.cargo/bin)
# and binaryen's wasm-opt for release (emsdk's, or WASM_OPT). (From rs/spikes/m0a/build-web.sh.)
set -euo pipefail
crate=${1:?crate}; out_arg=${2:?out_dir}; profile=${3:-release}
case $profile in release | web-dev) ;; *) echo "profile must be release or web-dev" >&2; exit 2 ;; esac
root=$(cd "$(dirname "$0")/../.." && pwd); out=$(realpath -m "$out_arg")
WASM_OPT=${WASM_OPT:-$(command -v wasm-opt || echo /media/8tsp/projects/emsdk/upstream/bin/wasm-opt)}
PATH="$HOME/.cargo/bin:$PATH"
cd "$root/rs"
RUSTFLAGS='--cfg getrandom_backend="wasm_js"' cargo build -p "$crate" --profile "$profile" --target wasm32-unknown-unknown
rm -rf "${out:?}"; mkdir -p "$out"
wasm-bindgen --target web --no-typescript --out-name index --out-dir "$out" "target/wasm32-unknown-unknown/$profile/$crate.wasm"
mv "$out/index_bg.wasm" "$out/index.wasm"
if [ "$profile" = release ]; then
  "$WASM_OPT" -Oz --enable-bulk-memory --enable-nontrapping-float-to-int --enable-sign-ext --enable-mutable-globals \
    --enable-reference-types --enable-multivalue "$out/index.wasm" -o "$out/index.wasm"
fi
cp "$root/rs/$crate/web/index.html" "$out/index.html"
gzip -9 -c -n "$out/index.wasm" > "$out/index.gzip.wasm"   # gzip bytes under a served name: what the Artifact page loads (binary files stop at 15 MB, .gz is not served)
ls -l "$out"
