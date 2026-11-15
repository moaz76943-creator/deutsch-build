import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/progress/lesson_resumption_manager.dart';

void main() {
  group('LessonResumptionManager Tests', () {
    late Directory tempDir;
    late String checkpointPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('lesson_resumption_test_');
      checkpointPath = '${tempDir.path}/active_lesson_checkpoint.json';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Restores active lesson checkpoint after app termination mid-exercise', () async {
      final manager = LessonResumptionManager(checkpointPath);

      final initial = LessonCheckpoint(
        pairId: 'de_ar',
        lessonId: 'lesson_a1_verbs_01',
        currentStepIndex: 4,
        totalSteps: 10,
        stepState: {'answered_card_ids': ['card_1', 'card_2', 'card_3']},
        updatedAt: DateTime.now(),
      );

      await manager.recordCheckpoint(initial);

      // Re-instantiate manager simulating app restart
      final restartedManager = LessonResumptionManager(checkpointPath);
      final restored = await restartedManager.getActiveCheckpoint('de_ar');

      expect(restored, isNotNull);
      expect(restored!.lessonId, equals('lesson_a1_verbs_01'));
      expect(restored.currentStepIndex, equals(4));
      expect(restored.stepState['answered_card_ids'].length, equals(3));
      expect(restored.isCompleted, isFalse);
    });

    test('Discards checkpoint if user switches to a different language pair', () async {
      final manager = LessonResumptionManager(checkpointPath);
      await manager.recordCheckpoint(LessonCheckpoint(
        pairId: 'de_ar',
        lessonId: 'lesson_01',
        currentStepIndex: 2,
        totalSteps: 5,
        stepState: {},
        updatedAt: DateTime.now(),
      ));

      // Attempt loading for Spanish-Arabic
      final esArCheckpoint = await manager.getActiveCheckpoint('es_ar');
      expect(esArCheckpoint, isNull);
    });
  });
}
