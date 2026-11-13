"""v2 successive halving: open every root, then narrow the field as depth grows.

Prefix signals : per-branch successful anchor (best ok score), mean ok score
                 (tie-break), trajectory stagnation, failure streak and class.
Batch rule     : first batch opens all legal roots (unopened roots carry no
                 evidence, so they tie). Afterwards one portfolio batch per
                 round: a branch's next attempt d runs only while the branch
                 ranks (by anchor, re-ranked after every reveal, among opened,
                 not-closed, not-stagnating branches) inside the top
                 round(n * shrink^d); at most one recovery cell; remaining
                 roots only when nothing pays off yet or at high beta. All
                 admitted frontiers run together (<= W).
Beta schedule  : _schedule(beta) only. shrink = 0.5 + 0.5*beta (beta 1 keeps
                 every branch at every depth); stagnation window 1 + floor(2*beta);
                 repairable-failure patience 1 + floor(2*beta); a no-anchor
                 recovery may take a slot from beta >= 0.25 (always when no
                 branch has an anchor). Beta is fixed inside solve().
Default beta   : 0.6. One live round per world: no live trend yet, so the
                 Listing 2 insufficient-history rule applies.
Grid rule      : < 2 live rounds -> the fallback grid clamped to hard_max
                 (the one round used its full depth and its best arrived at
                 the deepest attempt, so depth cannot shrink; the cap forbids
                 growth). With more history: hold while improving, widen on a
                 plateau, trim unused depth. Always clamped to hard_max_*.
Safeguards     : the keep set is recomputed every round from the prefix, so a
                 stagnating branch frees its slot for the next-ranked one and a
                 later success reopens anything. A repairable failure keeps
                 its anchor and its rank (it is a recovery, max one per
                 batch); only compile_env-type failures close a branch, and
                 only while they are the latest outcome. Exhausted kept
                 branches keep their slot (ranked evidence reserves the rest).
                 Singleton batches arise only at beta ~0 where the schedule
                 keeps one branch; otherwise all kept frontiers batch.
"""

from __future__ import annotations

from typing import Dict, List, Optional

from policy_api import (
    GridPlan,
    GridPlanningContext,
    LLMDesignedMethod,
    Observation,
    SimResult,
    _budget_done,
    _record_curve,
    branch_anchor,
    branch_trajectory,
    finalize_result,
    latest_failure_unrecoverable,
    probe_succeeded,
    stagnating,
)


class OptimalPolicy(LLMDesignedMethod):
    NAME = "OptimalPolicy"

    def __init__(self, config=None):
        super().__init__(config)
        self.beta = float(self.config.get("beta", 0.6))

    @staticmethod
    def _schedule(beta: float) -> Dict[str, float]:
        b = max(0.0, min(1.0, float(beta)))
        return {
            "shrink": 0.5 + 0.5 * b,
            "stagnation_window": 1 + int(2 * b),
            "fail_patience": 1 + int(2 * b),
            "recover_slot": b >= 0.25,
            "late_roots": b >= 0.5,
        }

    def solve(self, question, budget: Optional[int] = None) -> SimResult:
        question.reset()
        res = SimResult()
        sched = self._schedule(self.beta)
        while not _budget_done(question, budget):
            batch = self._select_batch(question.observed(), question, sched)
            if not batch:
                break
            question.probe_batch(batch, on_reveal=lambda _o: _record_curve(res, question))
        return finalize_result(question, res)

    def _select_batch(self, prefix: Dict[str, Observation], question, sched) -> List[str]:
        legal = sorted(question.legal_actions())
        if not legal:
            return []
        W = question.max_parallelism
        roots = sorted(question.legal_roots())
        frontier = {}
        for c in legal:
            m = question.meta(c)
            if m.attempt > 0:
                frontier[m.branch] = c

        opened = sorted(question.opened_branches())
        live = [b for b in opened if not latest_failure_unrecoverable(prefix, b)]
        anchors = {b: branch_anchor(prefix, b) for b in live}
        base = question.baseline_score
        paying = any(a is not None and a > base for a in anchors.values())

        # rank anchored, non-stagnating branches (exhausted ones keep their slot)
        anchored = [b for b in live if anchors[b] is not None
                    and not stagnating(prefix, b, window=int(sched["stagnation_window"]))]
        anchored.sort(key=lambda b: (-anchors[b], -_mean_ok(prefix, b), b))
        n = max(1, len(live))

        batch: List[str] = []
        recovery_used = False
        for rank, b in enumerate(anchored):
            c = frontier.get(b)
            if c is None:
                continue
            # successive halving: attempt d is open to the top n*f^d branches
            d = question.meta(c).attempt
            if rank >= max(1, int(n * sched["shrink"] ** d + 0.5)):
                continue
            traj = branch_trajectory(prefix, b)
            if traj and not probe_succeeded(traj[-1]):
                # repairable failure on an anchored branch: its anchor stands
                if recovery_used or _fail_streak(traj) > sched["fail_patience"]:
                    continue
                recovery_used = True
            batch.append(c)

        # branches with no successful anchor yet (root failed repairably)
        unanchored = [b for b in live if anchors[b] is None and b in frontier
                      and _fail_streak(branch_trajectory(prefix, b)) <= sched["fail_patience"]]
        unanchored.sort(key=lambda b: (_fail_streak(branch_trajectory(prefix, b)), b))
        if not anchored:
            batch += [frontier[b] for b in unanchored]   # nothing else to do: recover all
        elif unanchored and sched["recover_slot"] and not recovery_used:
            batch.append(frontier[unanchored[0]])

        # roots: all at the start / while nothing pays off; late ones only at high beta
        if not opened or not paying:
            batch = roots + batch
        elif sched["late_roots"]:
            batch += roots
        return list(dict.fromkeys(batch))[:W]

    def plan_grid(self, context: GridPlanningContext) -> GridPlan:
        cap_w, cap_r = context.hard_max_branch_count, context.hard_max_refine_count
        hist = [h for h in context.history
                if (h.get("explore") or {}).get("best_score") is not None]
        if len(hist) < 2:
            return GridPlan(max(1, min(context.fallback_branch_count, cap_w)),
                            max(0, min(context.fallback_refine_count, cap_r)),
                            f"{len(hist)} completed live round(s): no trend yet; "
                            "hold the fallback grid within the hard caps")
        last, prev = hist[-1], hist[-2]
        gp = last.get("grid_plan") or {}
        eff = gp.get("effective") or {}
        W = int(eff.get("branch_count", context.fallback_branch_count))
        R = int(eff.get("refine_count", context.fallback_refine_count))
        used = (gp.get("actual") or {}).get("max_attempt_selected")
        if last["explore"]["best_score"] > prev["explore"]["best_score"]:
            why = "live best still improving: hold the last grid"
        elif used is not None and used < R:
            W, R = W + 1, max(1, used)
            why = f"plateau and depth beyond {used} unused: widen, trim depth"
        else:
            W += 1
            why = "plateau after using full depth: widen"
        return GridPlan(max(1, min(W, cap_w)), max(0, min(R, cap_r)), why)


def _mean_ok(prefix: Dict[str, Observation], b: int) -> float:
    s = [o.score for o in branch_trajectory(prefix, b) if probe_succeeded(o)]
    return sum(s) / len(s) if s else 0.0


def _fail_streak(traj: List[Observation]) -> int:
    n = 0
    for o in reversed(traj):
        if probe_succeeded(o):
            break
        n += 1
    return n
