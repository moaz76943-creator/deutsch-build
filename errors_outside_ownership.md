# Errors outside ownership
The test execution via `flutter test` fails due to pre-existing Dart syntax and analyzer errors (merge conflict markers) in the following out-of-scope files present on the branch `staging/v2-full-platform`:
- `lib/core/srs/production_srs_engine.dart`
- `lib/services/srs_scheduler_service.dart`
- `lib/services/user_vault_security_service.dart`
- `lib/services/database_service.dart`

Our tests in `test/jules/J006/fts_search_service_test.dart` and changes to `lib/services/fts_search_service.dart` are correct and syntactically valid, as verified locally using isolated dart runner and the `dart analyze` command against the specific owned file.
