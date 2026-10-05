import 'package:deutsch_bilarabi/core/content_contract.dart';
import 'package:deutsch_bilarabi/core/explainer/explainer.dart';
import 'package:deutsch_bilarabi/core/memory.dart';
import 'package:deutsch_bilarabi/core/quick_review/quick_review.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/i_audio_runtime.dart';
import 'package:deutsch_bilarabi/features/audio/hybrid_pronunciation_service.dart';
import 'package:deutsch_bilarabi/features/daily_drill/domain/daily_drill_models.dart';
import 'package:deutsch_bilarabi/features/daily_drill/domain/daily_drill_repository.dart';
import 'package:deutsch_bilarabi/features/quick_review/presentation/v11_quick_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _AudioRuntime implements IAudioRuntime {
  final List<AudioRequest> requests = <AudioRequest>[];

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      const Stream<AudioPlaybackState>.empty();

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async {
    requests.add(request);
    return const AudioPlaybackResult.offlineTts();
  }

  @override
  Future<void> shutdown() async {}

  @override
  Future<void> stop() async {}
}

final class _ReviewSink implements DailyDrillReviewSink {
  int calls = 0;
  String? lastId;

  @override
  Future<DailyDrillReviewReceipt> record({
    required LearningContent item,
    required bool correct,
    required int seconds,
  }) async {
    calls += 1;
    lastId = item.id;
    return const DailyDrillReviewReceipt(
      currentStreak: 8,
      sessionXp: 14,
    );
  }
}

final class _ExplainerReader implements ExplainerCorpusReader {
  @override
  Future<ExplainerCorpusEntry?> fetchById(String contentId) async =>
      ExplainerCorpusEntry(
        id: contentId,
        sourceText: 'Haus',
        translationText: 'بيت',
        sentence: 'Das Haus ist groß.',
        sentenceTranslation: 'البيت كبير.',
        grammaticalMarker: 'das',
        pluralForm: 'Häuser',
      );

  @override
  Future<List<ExplainerVerbEvidence>> fetchVerbForms(
    String infinitive, {
    int limit = 6,
  }) async =>
      const <ExplainerVerbEvidence>[];
}

void main() {
  testWidgets(
    'production quick review wires indexed card, hybrid audio, explanation, and canonical review sink',
    (tester) async {
      final audio = _AudioRuntime();
      final sink = _ReviewSink();
      final session = QuickReviewSession(
        createdAt: DateTime.utc(2026, 10, 5, 8),
        limit: 12,
        cards: <QuickReviewCard>[
          QuickReviewCard(
            contentId: 'noun.haus',
            sourceText: 'Haus',
            translationText: 'بيت',
            exampleText: 'Das Haus ist groß.',
            exampleTranslationText: 'البيت كبير.',
            grammaticalMarker: 'das',
            pluralForm: 'Häuser',
            topic: 'home',
            skill: 'vocabulary',
            acceptedForms: const <String>['Haus'],
            dueAt: DateTime.utc(2026, 10, 5, 7),
            memoryState: MemoryState.learning,
            reason: MemoryReviewReason.due,
            intervalDays: 1,
            lapses: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: V11QuickReviewScreen(
            session: session,
            reviewSink: sink,
            pronunciationAudio: HybridPronunciationService(audioRuntime: audio),
            explainerService: ExplainerService(
              corpusReader: _ExplainerReader(),
            ),
            sourceLanguageCode: 'de',
            translationLanguageCode: 'ar',
          ),
        ),
      );

      expect(find.text('Haus'), findsOneWidget);

      await tester.tap(find.byKey(const Key('quick-review-audio')));
      await tester.pump();
      expect(audio.requests, hasLength(1));
      expect(audio.requests.single.conceptId, 'noun.haus');
      expect(audio.requests.single.variant, AudioVariant.pronunciation);

      await tester.tap(find.byKey(const Key('quick-review-reveal')));
      await tester.pump();
      expect(find.text('بيت'), findsOneWidget);

      await tester.tap(find.byKey(const Key('quick-review-explain')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quick-review-explanation-card')), findsOneWidget);
      expect(find.textContaining('Häuser'), findsWidgets);

      await tester.tap(find.byKey(const Key('quick-review-remembered')));
      await tester.pumpAndSettle();
      expect(sink.calls, 1);
      expect(sink.lastId, 'noun.haus');
      expect(find.textContaining('8'), findsWidgets);
      expect(find.textContaining('14'), findsWidgets);
    },
  );
}
