"""KI matchup search policy 'topk' (DUEL_MATCHUP_AI §8). Prefix signals only: each branch's successful anchor (best ok score), the
observed anchors' spread, the baseline. Batch rule: wave 0 opens every legal root at once (W = 4 = the grid's width), then each later
wave refines the branches the rule keeps, all in one batch. Beta: one scalar, fixed per episode, 0 = refine the fewest, 1 = refine every
branch (the baseline). Grid: the user's budget, 4 branches x 1 refine, never more (GridPlan 4 x 1). Safeguards: a branch whose latest
attempt failed with a repairable class keeps its place (scored by its anchor, 0 if none, and given a retry only when beta >= 0.5); the
best anchor's branch is always refined (no premature stop); batches are as wide as the kept set (no serial probing).
Rule (topk):
  topk      refine the top ceil(1 + 3 beta) branches by anchor
  spread    refine branches whose anchor >= best - beta x (best - worst) - 0.01
  frontier  refine the top 2 by anchor, plus any branch whose anchor >= baseline + (1 - beta) x (best - baseline)
"""
from __future__ import annotations
import math
from policy_api import GridPlan, GridPlanningContext, LLMDesignedMethod, SimResult, _budget_done, _record_curve, finalize_result

RULE = "topk"


def ok(o):
    return o.evaluated and o.error is None and o.fail_class == "ok"


class OptimalPolicy(LLMDesignedMethod):
    NAME = "ki_" + RULE

    def __init__(self, config=None):
        super().__init__(config)
        self.beta = float(self.config.get("beta", 0.4))

    def keep(self, question, frontier):
        obs = question.observed()
        anchor = {}
        for o in obs.values():
            if ok(o):
                anchor[o.branch] = max(anchor.get(o.branch, 0.0), o.score)
        scored = sorted(frontier, key=lambda c: (-anchor.get(question.meta(c).branch, 0.0), question.meta(c).branch))
        if not scored:
            return []
        vals = [anchor.get(question.meta(c).branch, 0.0) for c in scored]
        best, worst, base = vals[0], vals[-1], question.baseline_score
        if RULE == "topk":
            out = scored[: max(1, math.ceil(1 + 3 * self.beta))]
        elif RULE == "spread":
            out = [c for c, v in zip(scored, vals) if v >= best - self.beta * (best - worst) - 0.01]
        else:
            out = scored[:2] + [c for c, v in zip(scored[2:], vals[2:]) if v >= base + (1 - self.beta) * (best - base)]
        if self.beta >= 0.5:   # a repairable failure gets its retry
            for c in scored:
                b = question.meta(c).branch
                if b not in anchor and c not in out:
                    out.append(c)
        return out[: question.max_parallelism]

    def solve(self, question, budget=None) -> SimResult:
        question.reset()
        res = SimResult()
        roots = sorted(question.legal_roots())
        if roots and not _budget_done(question, budget):
            question.probe_batch(roots[: question.max_parallelism], on_reveal=lambda _o: _record_curve(res, question))
        while not _budget_done(question, budget):
            frontier = sorted(c for c in question.legal_actions() if question.meta(c).attempt > 0)
            batch = self.keep(question, frontier)
            if not batch:
                break
            question.probe_batch(batch, on_reveal=lambda _o: _record_curve(res, question))
            break   # one refine wave a round (the grid has one refine)
        return finalize_result(question, res)

    def plan_grid(self, context: GridPlanningContext) -> GridPlan:
        return GridPlan(min(4, context.hard_max_branch_count), min(1, context.hard_max_refine_count),
                        "the user's budget: 4 branches x 2 attempts a round (DUEL_MATCHUP_AI §1)")
