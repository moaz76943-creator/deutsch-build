import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/core/content_contract.dart';
import '../../lib/models/content.dart';
import '../../lib/services/app_dependencies.dart';
import '../../lib/services/preferences_service.dart';
import '../../lib/services/repository.dart';
import '../../lib/features/gamification/domain/gamification_review_sink.dart';
import '../../lib/language/german/german_language_pack.dart';
import '../../lib/services/search_index.dart';
import '../../lib/services/ai_gateway.dart';
import '../../lib/services/privacy_settings.dart';
import '../../lib/services/neuro_accessibility_settings.dart';
import '../../lib/services/user_vocabulary_service.dart';
import '../../lib/services/grammar_hub_service.dart';
import '../../lib/ui_v35/learning_pages.dart';
import '../../lib/models/learner.dart';
import '../../lib/services/learner_persistence.dart';
import '../../lib/models/assessment.dart';

import 'package:sqflite/sqflite.dart';

class FakeLearnerRepository implements LearnerRepository {
  @override
  Future<bool> clearLocalData() async => true;
  @override
  LearnerState load() => LearnerState(updatedAt: DateTime.now());
  @override
  Future<Set<String>> loadAndMigrateFavoriteVerbs() async => {};
  @override
  LearnerPersistence get persistence => throw UnimplementedError();
  @override
  PreferencesService get prefs => throw UnimplementedError();
  @override
  GamificationReviewSink get gamificationReviewSink =>
      const NoopGamificationReviewSink();
  @override
  Future<void> record({
    required LearningContent item,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
    String? skillOverride,
    DateTime? at,
  }) async {}
  @override
  Future<void> recordAssessment(AssessmentResult result) async {}
  @override
  Future<void> recordConversationAttempt({
    required String itemId,
    required String skill,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
  }) async {}
  @override
  Future<void> recordWritingMistake({
    required String issue,
    DateTime? at,
  }) async {}
  @override
  LearnerState reload() => load();
  @override
  Future<LearnerState> reloadPersisted() async => load();
  @override
  Future<void> save(LearnerState s) async {}
  @override
  Future<void> toggleFavoriteVerb(String infinitive) async {}
}

class FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<String>> getFavorites() async => {};
  @override
  Future<bool> isFavorite(String id) async => false;
  @override
  Future<void> toggleFavorite(String id) async {}
}

class FakeUserVocabularyService implements UserVocabularyService {
  @override
  Future<void> addCustomEntry(Map<String, dynamic> entry) async {}
  @override
  Future<void> close() async {}
  @override
  Future<Database> get database async => throw UnimplementedError();
  @override
  Future<void> deleteCustomEntry(String id) async {}
  @override
  Future<List<Map<String, dynamic>>> getCustomEntries({
    String? targetLanguage,
  }) async => [];
}

class FakeAiGateway implements AiGateway {
  @override
  bool get enabled => false;
  @override
  Future<AiReview> reviewWriting(String text, {String level = 'A1'}) async =>
      const AiReview(corrected: '', issues: [], explanation: '');
  @override
  Future<String> continueConversation({
    required String scenario,
    required String message,
    String level = 'A1',
  }) async => '';
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(List<ContentItem> corpus, PreferencesService prefs) {
    final languagePack = const GermanLanguagePack();
    final verbIndex = languagePack.contentPack.verbIndex;
    final searchIndex = SearchIndex(
      corpus,
      verbIndex,
      languagePack.textNormalizer,
    );

    final dependencies = AppDependencies<ContentItem>(
      searchIndex: searchIndex,
      verbIndex: verbIndex,
      corpus: corpus,
      languagePack: languagePack,
      aiGateway: FakeAiGateway(),
      privacySettings: LocalPrivacySettingsStore(prefs),
      neuroSettings: NeuroAccessibilitySettings(prefs),
      userVocabularyService: FakeUserVocabularyService(),
      favoritesRepository: FakeFavoritesRepository(),
      preferencesService: prefs,
      grammarHubService: GrammarHubService(),
    );

    return MaterialApp(
      home: ScaffoldMessenger(
        child: VocabularyV35(
          repo: FakeLearnerRepository(),
          corpus: corpus,
          onDone: () {},
          presentation: languagePack.presentation,
          contentQuality: languagePack.contentQuality,
          textNormalizer: languagePack.textNormalizer,
          dependencies: dependencies,
        ),
      ),
    );
  }

  testWidgets('renders list mode by default and saves view mode preference', (
    tester,
  ) async {
    final prefs = await PreferencesService.instance();
    final item = ContentItem(
      id: '1',
      german: 'der Apfel',
      arabic: 'تفاحة',
      sentence: 'Ich esse den Apfel.',
      sentenceAr: 'أنا آكل التفاحة.',
      topic: 'Food',
      skill: 'Nouns',
      article: 'der',
      plural: 'die Äpfel',
    );

    await tester.pumpWidget(createTestWidget([item], prefs));
    await tester.pumpAndSettle();

    // Verify list mode elements
    expect(find.text('der Apfel'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
    expect(find.byType(Card), findsWidgets);

    // Switch to Grid mode
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();

    // Check pref is saved
    expect(prefs.getString('vocabulary_view_mode'), 'grid');
    expect(find.byType(GridView), findsWidgets);

    // Switch to Flashcard mode
    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    // Check pref is saved
    expect(prefs.getString('vocabulary_view_mode'), 'flashcard');
    expect(find.byType(PageView), findsOneWidget);

    // Explicitly unmount and flush SafeTtsController.dispose(), which schedules
    // a zero-duration Future from the synchronous widget dispose callback.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
