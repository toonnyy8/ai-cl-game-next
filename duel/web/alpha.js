// SOUL DUEL: the canvas composites with alpha (docs/duel/DUEL_WEBUI.md §4; the user, 2026-10-28). SDL's WebGPU glue
// configures the context opaque; this asks for premultiplied instead, so a frame drawn with *RENDER-TRANSPARENT* (SELECT
// behind the HTML menus) shows the page's layers around the fighters. Every other frame writes alpha 1 everywhere, so
// it looks exactly as before. Loaded before the game (head.html).
(function () {
  if (!window.GPUCanvasContext) return;
  var configure = GPUCanvasContext.prototype.configure;
  GPUCanvasContext.prototype.configure = function (c) {
    return configure.call(this, Object.assign({}, c, { alphaMode: 'premultiplied' }));
  };
})();
