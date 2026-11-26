#!/bin/sh
# The Bevy-free crates must not pull in bevy: prints one count per crate, all must be 0.
cd "$(dirname "$0")/../../rs" || exit 1
rc=0
for c in duel-sim duel-data duel-look; do
  out=$(cargo tree -p "${CHECK_DEPS_CRATE:-$c}" -e normal --prefix none 2>/dev/null) || { echo "cargo tree failed for $c" >&2; echo "?"; rc=1; continue; }
  n=$(printf '%s\n' "$out" | grep -c '^bevy')
  echo "$n"
  [ "$n" = 0 ] || rc=1
done
exit $rc
