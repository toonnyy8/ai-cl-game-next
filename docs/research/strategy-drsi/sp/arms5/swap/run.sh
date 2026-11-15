#!/bin/sh
# Swap test (lead, 2026-11-15): which table makes KH / IH stall — B4's shipped (arms4/t0final) vs arms5's final (arms5/t0), seeds 141-180 both seats.
set -e
cd "$(dirname "$0")/../.."
export SP_BUILD=f0e2bb129de1
B=arms4/t0final; A=arms5/t0; L=arms5/swap/swap.jsonl
r() { python3 arms5/inband.py result --me "$1" --vs "$2" --mine "$3" --theirs "$4" --tag "$5" --log $L -j 20; }
r hisagi kenpachi $B/t0-kh-hisagi.lisp $B/t0-kh-kenpachi.lisp KH-b4H-b4K
r hisagi kenpachi $B/t0-kh-hisagi.lisp $A/t0-kh-kenpachi.lisp KH-b4H-a5K
r hisagi kenpachi $A/t0-kh-hisagi.lisp $B/t0-kh-kenpachi.lisp KH-a5H-b4K
r hisagi kenpachi $A/t0-kh-hisagi.lisp $A/t0-kh-kenpachi.lisp KH-a5H-a5K
r hisagi ichigo $B/t0-ih-hisagi.lisp $B/t0-ih-ichigo.lisp IH-b4H-b4I
r hisagi ichigo $B/t0-ih-hisagi.lisp $A/t0-ih-ichigo.lisp IH-b4H-a5I
r hisagi ichigo $A/t0-ih-hisagi.lisp $B/t0-ih-ichigo.lisp IH-a5H-b4I
r hisagi ichigo $A/t0-ih-hisagi.lisp $A/t0-ih-ichigo.lisp IH-a5H-a5I
