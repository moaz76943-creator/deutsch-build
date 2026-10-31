import 'dart:io';
import 'package:test/test.dart';
import 'package:deutsch_app/core/placement/placement_draft_store.dart';

void main() {
  group('PlacementDraftStore Tests', () {
    late Directory tempDir;
    late String draftPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('placement_test_');
      draftPath = '${tempDir.path}/placement_draft.json';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Saves and restores placement test draft after simulated app kill', () async {
      final store = PlacementDraftStore(draftPath);

      final originalDraft = PlacementDraft(
        pairId: 'de_ar',
        currentQuestionIndex: 12,
        answers: {1: 'B', 2: 'A', 3: 'C', 12: 'D'},
        lastSaved: DateTime.now(),
      );

      await store.saveDraft(originalDraft);

      // Simulate app restart by loading from fresh instance
      final restartedStore = PlacementDraftStore(draftPath);
      final restored = await restartedStore.loadDraft();

      expect(restored, isNotNull);
      expect(restored!.pairId, equals('de_ar'));
      expect(restored.currentQuestionIndex, equals(12));
      expect(restored.answers[12], equals('D'));
      expect(restored.answers.length, equals(4));
    });

    test('Clears draft cleanly upon test completion', () async {
      final store = PlacementDraftStore(draftPath);
      await store.saveDraft(PlacementDraft(
        pairId: 'de_ar',
        currentQuestionIndex: 1,
        answers: {1: 'A'},
        lastSaved: DateTime.now(),
      ));

      expect(await store.loadDraft(), isNotNull);

      await store.clearDraft();
      expect(await store.loadDraft(), isNull);
    });
  });
}
