import '../../../services/repository.dart';
import '../domain/settings_repository.dart';

final class CanonicalLearningProgressResetter
    implements LearningProgressResetter {
  CanonicalLearningProgressResetter(this._repository);

  final LearnerRepository _repository;

  @override
  Future<bool> resetLearningProgress() => _repository.clearLocalData();
}
