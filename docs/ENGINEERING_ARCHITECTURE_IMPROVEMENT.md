# Engineering & Architecture Improvement Plan
## Deutsch بالعربي — Continuous Improvement for Speed, Quality, Ease of Development

### Current State Assessment
- **Strengths**: Offline-first design (privacy-preserving), Riverpod for DI, feature-based structure with some Clean Architecture layers (presentation/domain/application/data), strong release security (R8/ProGuard, Flutter obfuscation, Play Integrity, careful keystore handling in CI), comprehensive CI workflows for AAB, tests present.
- **Opportunities**: Large `core/` and `features/` (130+ screens), complex agent system that can slow navigation/onboarding for new developers, inconsistent layering across features, potential for better modularization to enable parallel development and faster builds.

### Prioritized Action Plan
1. **P0 - Modularization & Feature Templates** (this run focuses here): Standardize feature modules on Clean Architecture + MVVM with Riverpod. Extract shared UI kits.
2. **P1 - Dependency Injection**: Centralize Riverpod providers per feature; prefer abstract interfaces.
3. **P2 - Testing**: Expand unit/widget tests for domain and viewmodels; golden tests for UI; integration for offline flows.
4. **P3 - CI/CD for Play**: Keep signed AAB workflow; add automated Play Console upload via Fastlane or Google Play API (with service account); size guards already exist.
5. **P4 - Performance**: Lazy feature loading, const widgets, isolate heavy work (already partially done), asset budgets.
6. **P5 - Security**: Maintain existing obfuscation/minify; add runtime integrity checks; never log sensitive learner data.

### Concrete Refactoring Example: Feature Module Template (MVVM + Clean)
**Before** (typical monolithic screen with orchestrator):
```dart
class _SomeMasterHubState extends State<SomeMasterHub> {
  late final SomeMasterOrchestrator _orchestrator;
  // business logic mixed with UI
}
```

**After** (Clean + MVVM with Riverpod):
```dart
// domain/entities/item.dart
class LearningItem { ... }

// domain/repositories/item_repository.dart
abstract class ItemRepository {
  Future<List<LearningItem>> getItems();
}

// data/item_repository_impl.dart
class ItemRepositoryImpl implements ItemRepository { ... }

// application/item_viewmodel.dart  (or notifier)
final itemViewModelProvider = StateNotifierProvider<ItemViewModel, AsyncValue<List<LearningItem>>>((ref) {
  return ItemViewModel(ref.watch(itemRepositoryProvider));
});

class ItemViewModel extends StateNotifier<AsyncValue<List<LearningItem>>> {
  ItemViewModel(this._repo) : super(const AsyncValue.loading()) {
    load();
  }
  final ItemRepository _repo;
  Future<void> load() async { ... }
}

// presentation/item_screen.dart
class ItemScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itemViewModelProvider);
    return state.when(
      data: (items) => ListView(...),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

### Implemented Optimization (this run)
- Added this document as the living architecture guide.
- Next runs will extract one high-traffic feature (e.g., flashcards or onboarding) into the template above and measure build/test time impact.

### Security Notes
All changes preserve existing R8 rules, Flutter `--obfuscate`, Play Integrity dependency, and no learner data leaves the device. New modules must not introduce network calls without explicit offline gates.
