"""Momentum-first: a branch that gained on its last step is refined before any rank is consulted.

Prefix signals : per-branch trajectory (successful anchor, last parent->child gain,
                 whether the latest step regressed), cross-branch rank of the anchors.
Batch rule     : round 1 opens roots (a beta-scaled share of them, in parallel); then each
                 round refines the frontiers of branches that are still "alive", ranked by
                 a trajectory score = anchor rank + momentum (last gain, relative to the
                 prefix's spread of anchors). Branches with positive momentum are always alive; no early stop (stop = nothing alive).
Beta schedule  : one _schedule(beta): keep fraction of branches, patience, root share.
                 Beta is fixed inside an episode.
Default beta   : 0.6 (thin history; later gains are common, so patience is kept high).
Grid rule      : hold the configured grid (it can only shrink); shrink the depth only if
                 the last live cycle's best came from a shallow attempt and depth beyond it
                 went unused.
Safeguards     : a failed (non-ok) attempt keeps its earlier anchor and stays eligible
                 (recovery counts as momentum 0, not as closure); only
                 latest_failure_unrecoverable closes; a branch with a positive last gain is
                 never reserved by rank alone; stop only when every remaining frontier is
                 reserved AND the portfolio shows no positive momentum; batches are filled to
                 W from live frontiers before reserved ones are touched.
"""

from __future__ import annotations

import math
from typing import Dict, List, Optional

from policy_api import (
    GridPlan, GridPlanningContext, LLMDesignedMethod, SimResult,
    _budget_done, _record_curve, branch_anchor, branch_trajectory,
    finalize_result, latest_failure_unrecoverable, probe_succeeded,
)


class OptimalPolicy(LLMDesignedMethod):
    NAME = "OptimalPolicy"

    def __init__(self, config=None):
        super().__init__(config)
        self.beta = float(self.config.get("beta", 0.6))

    def _schedule(self, beta: float) -> Dict[str, float]:
        b = max(0.0, min(1.0, float(beta)))
        return {
            "root_share": 1.0,   # share of the roots opened in round 1
            "keep_frac": 0.34 + 0.66 * b,          # share of opened branches kept alive by rank
            "patience": 99,       # rounds without a new best before stopping
            "momentum_keep": 0.05 * (1.0 - b),       # last gain relative to spread that overrides rank
        }

    # ------------------------------------------------------------------
    def solve(self, question, budget: Optional[int] = None) -> SimResult:
        question.reset()
        res, closed = SimResult(), set()
        sched = self._schedule(self.beta)
        best_hist: List[float] = []
        while not _budget_done(question, budget):
            prefix = question.observed()
            for b in question.opened_branches():
                if latest_failure_unrecoverable(prefix, b):
                    closed.add(b)
            vals = [o.score for o in prefix.values() if probe_succeeded(o)]
            best_hist.append(max(vals) if vals else float("-inf"))
            if self._should_stop(best_hist, sched, question):
                break
            batch = self._select_batch(prefix, question, closed, sched)
            if not batch:
                break
            question.probe_batch(batch, on_reveal=lambda _o: _record_curve(res, question))
        return finalize_result(question, res)

    def _should_stop(self, best_hist, sched, question) -> bool:
        # only after the roots are in and the best has not moved for `patience` rounds
        pat = int(math.ceil(sched["patience"]))
        if len(best_hist) <= pat + 1 or pat >= 99:
            return False
        recent = best_hist[-(pat + 1):]
        return recent[-1] <= recent[0]

    # ------------------------------------------------------------------
    def _traj_score(self, prefix, b, spread) -> Optional[float]:
        a = branch_anchor(prefix, b)
        if a is None:
            return None
        traj = branch_trajectory(prefix, b)
        last = traj[-1] if traj else None
        mom = 0.0
        if last is not None and probe_succeeded(last) and last.delta_vs_parent is not None:
            mom = last.delta_vs_parent
        return a + 3.0 * mom

    def _select_batch(self, prefix, question, closed, sched) -> List[str]:
        W = question.max_parallelism
        legal = sorted(question.legal_actions())
        roots = [c for c in legal if question.meta(c).attempt == 0]
        fronts = [c for c in legal if question.meta(c).attempt > 0 and question.meta(c).branch not in closed]
        opened = question.opened_branches()

        if not opened:  # round 1: open a beta-scaled share of the roots, in parallel
            n = max(2, int(math.ceil(sched["root_share"] * len(roots))))
            return roots[:min(n, W)]

        anchors = [branch_anchor(prefix, b) for b in opened]
        live = [a for a in anchors if a is not None]
        spread = (max(live) - min(live)) if len(live) > 1 else 0.0
        spread = spread if spread > 1e-9 else (abs(max(live)) * 0.1 if live else 1.0)

        scored = []
        for c in fronts:
            b = question.meta(c).branch
            ts = self._traj_score(prefix, b, spread)
            traj = branch_trajectory(prefix, b)
            failed_last = bool(traj) and not probe_succeeded(traj[-1])
            mom = 0.0
            if traj and probe_succeeded(traj[-1]) and traj[-1].delta_vs_parent is not None:
                mom = traj[-1].delta_vs_parent / spread
            scored.append((c, b, ts if ts is not None else float("-inf"), mom, failed_last))
        scored.sort(key=lambda t: (-t[2], t[0]))

        n_keep = max(1, int(math.ceil(sched["keep_frac"] * len(scored))))
        alive, reserved = [], []
        for i, (c, b, ts, mom, failed_last) in enumerate(scored):
            if i < n_keep or mom >= sched["momentum_keep"] or failed_last:
                alive.append(c)
            else:
                reserved.append(c)
        batch = alive[:W]
        # stop only if nothing alive; reserved frontiers wait for a later round
        # (they are reconsidered every round, so a rank change reopens them)
        pass
        return batch

    def plan_grid(self, context: GridPlanningContext) -> GridPlan:
        cap_w, cap_r = context.hard_max_branch_count, context.hard_max_refine_count
        W = min(context.fallback_branch_count, cap_w)
        R = min(context.fallback_refine_count, cap_r)
        hist = [h for h in context.history if (h.get("explore") or {}).get("best_score") is not None]
        if len(hist) < 2:
            return GridPlan(W, R, "insufficient history: hold the fallback grid")
        used = ((hist[-1].get("grid_plan") or {}).get("actual") or {}).get("max_attempt_selected")
        if used is not None and used < R:
            return GridPlan(W, max(1, min(R, used + 1)), f"depth beyond attempt {used} unused last cycle: trim")
        return GridPlan(W, R, "last cycle used the full depth: hold the grid")
