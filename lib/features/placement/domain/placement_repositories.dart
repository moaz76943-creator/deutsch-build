import 'placement_models.dart';

abstract interface class PlacementRepository {
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  });

  Future<int> availableQuestionCount();
}

abstract interface class PlacementProfileRepository {
  Future<void> applyResult(PlacementResult result, {DateTime? at});
}

abstract interface class PlacementAudioGateway {
  Future<bool> play(PlacementQuestion question);
}

final class UnavailablePlacementAudioGateway implements PlacementAudioGateway {
  const UnavailablePlacementAudioGateway();

  @override
  Future<bool> play(PlacementQuestion question) async => false;
}
