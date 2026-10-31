# V92 — Smart Learning Engine

V92 connects the V90 memory model and V91 assessment into a single local learning path.

## Added
- `LearningEngine` builds a bounded daily path prioritizing due memory cards, repeated mistakes, weak skills, and then new content.
- `MistakeCoach` converts repeated errors into a deterministic corrective action.
- `ReadingPractice` builds short passages from quality-approved content and exposes target vocabulary.
- `ProgressSnapshot` provides a local skill profile and level band without claiming certification.
- Home now exposes the personalized path, progress, mistake coach, and interactive reading.

## Privacy
All V92 orchestration is local. No new network endpoint, API key, or cloud dependency was introduced.

## Compatibility
The feature consumes the existing `LearnerState`, SRS, assessment history, and content quality firewall. Existing V90/V91 persisted data remains readable.
