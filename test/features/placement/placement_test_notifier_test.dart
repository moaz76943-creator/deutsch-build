import 'package:deutsch_bilarabi/features/placement/application/placement_test_notifier.dart';
import 'package:deutsch_bilarabi/features/placement/domain/placement_models.dart';
import 'package:deutsch_bilarabi/features/placement/domain/placement_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakePlacementRepository implements PlacementRepository {
  @override
  Future<int> availableQuestionCount() async => 20;

  @override
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  }) async {
    final index = excludeIds.length;
    return PlacementQuestion(
      id: 'q-$index',
      promptArabic: 'سؤال',
      level: level,
      pattern: PlacementQuestionPattern.multipleChoice,
      options: const <PlacementOption>[
        PlacementOption(id: 'yes', text: 'نعم'),
        PlacementOption(id: 'no', text: 'لا'),
      ],
      correctOptionId: 'yes',
      skillTag: 'grammar',
      reviewItemId: 'w0745',
    );
  }
}

final class _FakeProfileRepository implements PlacementProfileRepository {
  PlacementResult? applied;

  @override
  Future<void> applyResult(PlacementResult result, {DateTime? at}) async {
    applied = result;
  }
}

void main() {
  test('notifier completes adaptive flow and applies final result', () async {
    final profile = _FakeProfileRepository();
    final notifier = PlacementTestNotifier(
      repository: _FakePlacementRepository(),
      profileRepository: profile,
      clock: () => DateTime.utc(2026, 10, 3),
    );

    await notifier.start();
    expect(notifier.state.currentQuestion?.level, PlacementLevel.a2);

    while (notifier.state.result == null) {
      await notifier.submitOption('yes');
    }

    expect(notifier.state.result?.level, PlacementLevel.b1);
    expect(profile.applied?.level, PlacementLevel.b1);
    expect(notifier.state.isApplyingResult, isFalse);
    notifier.dispose();
  });

  test('audio failure stays a presentation-safe state flag', () async {
    final notifier = PlacementTestNotifier(
      repository: _FakePlacementRepository(),
      profileRepository: _FakeProfileRepository(),
      clock: () => DateTime.utc(2026, 10, 3),
    );

    await notifier.start();
    final played = await notifier.replayCurrentAudio();

    expect(played, isFalse);
    expect(notifier.state.audioUnavailable, isFalse);
    notifier.dispose();
  });
}
