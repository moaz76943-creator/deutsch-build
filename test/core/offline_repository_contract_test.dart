import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/offline_repository_contract.dart';
import 'package:deutsch_bilarabi/models/learner.dart';

final class _MemoryOfflineRepository implements OfflineLearnerRepository {
  _MemoryOfflineRepository(this._state);

  LearnerState _state;

  @override
  OfflineRepositoryAuthority get authority =>
      OfflineRepositoryAuthority.localOnly;

  @override
  LearnerState load() => _state;

  @override
  LearnerState reload() => _state;

  @override
  Future<LearnerState> reloadPersisted() async => _state;

  @override
  Future<void> save(LearnerState state) async {
    _state = state;
  }
}

void main() {
  test(
    'offline repository contract is explicitly local-authority only',
    () async {
      final initial = LearnerState(updatedAt: DateTime.utc(2026, 9, 30));
      final repo = _MemoryOfflineRepository(initial);

      expect(repo.authority, OfflineRepositoryAuthority.localOnly);
      expect(repo.load(), same(initial));

      final next = LearnerState(
        xp: 10,
        updatedAt: DateTime.utc(2026, 9, 30, 10),
      );
      await repo.save(next);

      expect(repo.reload(), same(next));
      expect(await repo.reloadPersisted(), same(next));
    },
  );
}
