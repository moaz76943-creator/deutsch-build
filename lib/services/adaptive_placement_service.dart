import '../models/diagnostic_placement.dart';
import 'repository.dart';

final class AdaptivePlacementService {
  const AdaptivePlacementService(this.repository);

  final LearnerRepository repository;

  Future<void> recordResult(
    PlacementDiagnosticResult result, {
    DateTime? at,
  }) async {
    final timestamp = at ?? DateTime.now();
    await repository.recordPlacementDiagnostic(result.toRecord(at: timestamp));
  }
}
