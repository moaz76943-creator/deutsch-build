# Feature Module Scaffold

Copy this folder and rename for new features (e.g. `flashcards`, `pronunciation`).

## Structure
```
features/my_feature/
  domain/
    entities/
    repositories/   # abstract
    usecases/
  data/
    models/
    datasources/    # local/remote
    repositories/   # impl
  presentation/
    notifiers/      # Riverpod Notifiers (ViewModels)
    screens/
    widgets/
```

## Example Riverpod DI (domain interface + override in app)
```dart
// domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<List<MyEntity>> getItems();
}

final myRepositoryProvider = Provider<MyRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// In main or composition root:
// myRepositoryProvider.overrideWith((ref) => MyRepositoryImpl(...))
```

## Benefits
- Fast onboarding: copy folder, implement.
- Testable: pure domain, mock repositories.
- Secure: sensitive logic in data layer, integrity checks at bootstrap.
- Performance: keep UI pure, heavy work in use cases with compute() if needed.

This is the key optimization for ease of development this run.
