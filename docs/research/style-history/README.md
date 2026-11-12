# Style review scripts (history)

These are the review-still and check scripts of the Storm x Kubo ink-style restyle, rounds 2 to 6, plus the
Kenpachi batch sheet script (`batch-shots.py`) and the older user-review still set (`style-shots.py`). They shot
the review stills and ran the pixel acceptance checks named in `docs/style/STYLE_STORM_DESIGN.md` §9 and §14.

No tool, test or build step calls them any more (checked 2026-11-12, R8 / D6). They are kept here as a record of
how each round was checked. The gates that still run are `tests/style-gates.py` and `tools/toon_check.py`.

Paths inside these scripts assume the old `tests/` location, so running one from here needs those paths adjusted first.
