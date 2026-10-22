The following files outside of the allowed paths for this task contain syntax errors due to git merge conflicts and breaking changes:
- lib/core/architecture/operation_result.dart
- lib/design_system/app_typography.dart
- lib/core/srs/production_srs_engine.dart
These errors block `flutter test` execution out of the box, but are noted here instead of being fixed since they fall outside of the `lib/core/ui/**` and `test/jules/J070/**` allowed paths.
