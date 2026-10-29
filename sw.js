// SOUL DUEL's service worker: the installed app starts offline (the manual too). build.sh replaces the version below
// with a hash of the build and the page files, so every new build installs a fresh cache; pwa.js reloads the page once when the new worker takes
// over, and the old caches are deleted. Everything is served cache-first from ONE version, so index.html, index.js
// and index.wasm always come from the same build (a network-first index.html could pair a new page with an old
// index.js / index.wasm until the reload).
var VERSION = 'soulduel-c99754708a9b';
// The menus' Google Fonts (the CSS and its font files, cross-origin): cache-first in a cache of their own that outlives the
// builds, so the installed app keeps its faces offline after one online start (the user, 2026-10-28: 「讓 service worker 也把字型存起來」).
var FONTS = 'soulduel-fonts';
function fontHost(u) { return u.hostname === 'fonts.googleapis.com' || u.hostname === 'fonts.gstatic.com'; }
var FILES = ['./', 'index.html', 'index.js', 'index.wasm', 'alpha.js', 'pwa.js', 'menu.js', 'menu.css', 'hud.js', 'hud.css', 'manifest.webmanifest', 'manual.html',
             'icon-192.png', 'icon-512.png', 'icon-maskable-512.png', 'apple-touch-icon.png'];
self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(VERSION)
    .then(function (c) { return c.addAll(FILES.map(function (f) { return new Request(f, { cache: 'reload' }); })); })
    .then(function () { return self.skipWaiting(); }));
});
self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys()
    .then(function (ks) { return Promise.all(ks.filter(function (k) { return k !== VERSION && k !== FONTS; }).map(function (k) { return caches.delete(k); })); })
    .then(function () { return self.clients.claim(); }));
});
self.addEventListener('fetch', function (e) {
  if (e.request.method !== 'GET') return;
  var u = new URL(e.request.url);
  if (fontHost(u)) {
    e.respondWith(caches.open(FONTS).then(function (c) {
      return c.match(e.request).then(function (r) {
        return r || fetch(e.request).then(function (res) { if (res.ok || res.type === 'opaque') c.put(e.request, res.clone()); return res; });
      });
    }));
    return;
  }
  if (u.origin !== location.origin) return;
  e.respondWith(caches.open(VERSION).then(function (c) {
    return c.match(e.request, { ignoreSearch: true }).then(function (r) { return r || fetch(e.request); });
  }));
});
