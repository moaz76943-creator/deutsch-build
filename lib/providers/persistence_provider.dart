import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/persistence/local_persistence_port.dart';
import '../core/persistence/shared_preferences_adapter.dart';

/// Riverpod provider for the LocalPersistencePort.
/// Use this everywhere instead of SharedPreferences.getInstance().
/// Enables easy mocking in tests and centralizes persistence access.
final localPersistenceProvider = FutureProvider<LocalPersistencePort>((ref) async {
  return SharedPreferencesAdapter.create();
});

/// Synchronous access after initialization (use carefully in early bootstrap).
final localPersistenceSyncProvider = Provider<LocalPersistencePort?>((ref) {
  final asyncValue = ref.watch(localPersistenceProvider);
  return asyncValue.valueOrNull;
});
