# V94 Smart Mistake Coach Implementation Plan

## Goal
Unify recurring errors from assessment, practice, voice conversation, and writing into one offline-first repair loop while restoring the V90 memory model that was lost when V91/V92/V93 were based on the V89 line.

## Files
- `lib/models/learner.dart`: restore V90 memory fields while retaining assessment history.
- `lib/services/srs.dart`: restore V90 stability/difficulty behavior.
- `lib/services/memory.dart`: restore V90 memory queue/snapshot.
- `lib/models/mistake.dart`: bounded mistake records, categories, repair drills and mastery.
- `lib/services/mistake_engine.dart`: aggregate/classify/prioritize mistakes from attempts and direct writing feedback.
- `lib/services/repair_engine.dart`: generate short bounded repair drills from learnable content.
- `lib/services/repository.dart`: persist mistake progress and repair outcomes safely.
- `lib/services/learning_engine.dart`: consume mistake priorities and memory queue without duplicating items.
- `lib/ui_v35/app.dart`: upgrade mistake coach UI and add repair flow; keep V93 voice conversation.
- `test/v94_mistake_engine_test.dart`: aggregation, classification, recurrence priority.
- `test/v94_repair_engine_test.dart`: bounded drills and safe content filtering.
- `test/v94_memory_regression_test.dart`: V90 memory fields, queue and stability behavior.
- `test/v94_ui_contract_test.dart`: static UI contracts for coach/repair integration.
- `docs/V94_SMART_MISTAKE_COACH_UPDATE.md`: release notes and limitations.

## TDD sequence
1. Add failing V94 tests and run the focused test command; record failure. Flutter is expected to be unavailable in this environment, so do not claim runtime test success.
2. Restore V90 memory model/services and make regression tests structurally satisfiable.
3. Implement mistake aggregation/classification/priority.
4. Implement repair drill generation and persistence.
5. Integrate repair priority into the daily learning engine.
6. Upgrade UI with top recurring mistakes and 3-step repair flow.
7. Run static audits, source contracts, ZIP integrity and hash; report Flutter/Dart limitation explicitly.

## Safety/quality constraints
- Offline-first; no new network dependency.
- No fake SRS cards for conversation turns or free-writing records.
- Bound persisted collections and normalize user text.
- Repairs must use existing learnable content only.
- Never treat a single failed attempt as a permanent weakness; recurrence and recency determine priority.
