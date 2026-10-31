# V118 — Smart Mastery + SRS Intelligence

V118 keeps the V117 content corpus intact and improves review prioritization using retrievability, stability, lapse history, failures, and difficulty.

## Changes
- Added `Srs.retrievability()` using stability-aware exponential decay.
- Added `Srs.reviewPriority()` combining forgetting pressure, overdue time, lapses, failures, and difficulty.
- Integrated the new score into `MemoryQueue.priority()` without removing existing due-card behavior.
- Added `MasteryEvidence.nextReviewDays` as a bounded, learner-facing review horizon.
- Learning-plan reasons now expose the adaptive next-review horizon for historical items.
- Preserved the existing SRS schedule and persisted `ReviewCard` schema for backward compatibility.

## Safety
- No content IDs were removed.
- No learner persistence fields were renamed or removed.
- Priority changes are additive: due cards remain eligible and continue to be ranked first by due status.
