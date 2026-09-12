# V115 — Adaptive Focus + Content Expansion

- Added `AdaptiveFocus` to choose the weakest learning dimension per item.
- Applies light recency decay so stale knowledge receives targeted practice.
- Maps recent errors back to recall, listening, production, or transfer.
- LearningEngine now uses the selected dimension for learners with item history instead of falling back to a generic mode.
- ContentQuality now exposes collection-level duplicate ID/German checks.
- Added 30 curated A1/A2-friendly words and verb phrases without replacing existing IDs.
- Version: 1.62.0+72.
