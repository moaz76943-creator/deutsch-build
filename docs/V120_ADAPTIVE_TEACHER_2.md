# V120 — Adaptive Teacher 2.0

V120 extends the teacher from a single weakest-skill decision into a lightweight session policy.

- Measures recent 14-day failure pressure.
- Measures review pressure from due and overdue cards.
- Exposes confidence, reviewPressure, recentFailureRate, and newContentReadiness.
- Reduces new-content expansion when recent errors or review pressure are high.
- Uses a smaller repair budget during high-failure periods.
- Keeps existing LearnerState persistence unchanged.
- LearningEngine consumes the teacher budget and readiness signal while preserving the existing review/mistake-first ordering.
