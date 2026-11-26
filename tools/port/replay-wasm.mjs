// The wasm32 replay (docs/bevy/BEVY_PORT.md §6.3): duel-tools built for wasm32-wasip1, run under node:wasi with the trace's
// directory preopened as /t (the data is embedded in the binary; a `--data DIR` is preopened as /d). Exit code = the replay's (0 OK).
// Usage: node tools/port/replay-wasm.mjs <trace> [replay args ...]
//   (build first: cd rs && cargo build --release -p duel-tools --target wasm32-wasip1)
import { readFile } from 'node:fs/promises';
import { WASI } from 'node:wasi';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const [trace, ...rest] = process.argv.slice(2);
if (!trace) { console.error('usage: node tools/port/replay-wasm.mjs <trace> [replay args ...]'); process.exit(2); }
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const wasm = path.join(root, 'rs/target/wasm32-wasip1/release/duel-tools.wasm');
const preopens = { '/t': path.dirname(path.resolve(trace)) };
const d = rest.indexOf('--data');
if (d >= 0) {
  if (!rest[d + 1]) { console.error('--data needs a directory'); process.exit(2); }
  preopens['/d'] = path.resolve(rest[d + 1]);
  rest[d + 1] = '/d';
}
const wasi = new WASI({ version: 'preview1', args: ['duel-tools', 'replay', '/t/' + path.basename(trace), ...rest], preopens,
                        returnOnExit: true });
const instance = await WebAssembly.instantiate(await WebAssembly.compile(await readFile(wasm)), wasi.getImportObject());
process.exitCode = wasi.start(instance);
