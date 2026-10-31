import '../models/learner.dart';

enum OfflineRepositoryAuthority { localOnly }

abstract interface class OfflineLearnerRepository {
  OfflineRepositoryAuthority get authority;

  LearnerState load();

  LearnerState reload();

  Future<LearnerState> reloadPersisted();

  Future<void> save(LearnerState state);
}
