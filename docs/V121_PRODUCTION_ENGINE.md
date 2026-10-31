# V121 — Production & Sentence Engine

V121 adds a production layer that turns vocabulary and mistake signals into progressive sentence-production tasks.

## Capabilities
- Recognize → guided production → free production modes.
- Arabic meaning and target word prompts.
- Normalized answer matching with accepted variants.
- Word-order and writing mistakes receive guided production first.
- Repeated/high recent failure can fall back to recognition before production.
- LearningEngine now surfaces a concrete production prompt for production-selected items.

## Compatibility
The engine is additive and does not change persisted learner JSON structures.
