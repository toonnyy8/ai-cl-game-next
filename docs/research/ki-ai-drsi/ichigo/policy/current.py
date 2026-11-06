"""Baseline: wave-parallel explore + refine (official dream_rsi/policy/baseline.py).

Wave 0 opens every root at once, wave 1 refines every branch once, ... up to
``max_refine``. No pruning, no stopping, beta is ignored. This is the policy
of Recursive Fixed Exploration and the shared starting point of both arms;
its beta sweep is degenerate by design and it spends every evaluated cell.

Config: ``max_width`` (branches to use, default all), ``max_refine``
(deepest attempt, default 10).
"""

from __future__ import annotations

from policy_api import LLMDesignedMethod, SimResult, _budget_done, _record_curve, finalize_result


class OptimalPolicy(LLMDesignedMethod):
    NAME = "parallel_refine"

    def __init__(self, config=None):
        super().__init__(config)
        width = self.config.get("max_width", self.config.get("width"))
        self.max_width = int(width) if width is not None else None
        self.max_refine = int(self.config.get("max_refine", self.config.get("max_depth", 10)))

    def solve(self, question, budget=None) -> SimResult:
        question.reset()
        res = SimResult()
        for attempt in range(self.max_refine + 1):
            if _budget_done(question, budget):
                break
            cells = [
                c for c in question.legal_actions()
                if question.meta(c).attempt == attempt
                and (self.max_width is None or question.meta(c).branch < self.max_width)
            ]
            if budget is not None:
                cells = cells[: budget - question.budget_spent]
            if cells:
                question.probe_batch(cells, on_reveal=lambda _o: _record_curve(res, question))
        return finalize_result(question, res)
