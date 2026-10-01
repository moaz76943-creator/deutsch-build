import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/ui_v35/conversation_pages.dart';
import '../../lib/ui_v35/grammar/grammar_hub_page.dart';
import '../../lib/services/app_dependencies.dart';
import '../../lib/services/repository.dart';
import '../../lib/services/preferences_service.dart';
import '../../lib/services/learner_persistence.dart';
import '../../lib/core/content_contract.dart';
import '../../lib/services/search_index.dart';
import '../../lib/services/ai_gateway.dart';
import '../../lib/services/privacy_settings.dart';
import '../../lib/services/neuro_accessibility_settings.dart';
import '../../lib/services/user_vocabulary_service.dart';
import '../../lib/services/grammar_hub_service.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../lib/language/german/german_language_pack.dart';
import '../../lib/language/german/german_text_normalizer.dart';
import '../../lib/models/content.dart';
import '../../lib/models/learner.dart';
import '../../lib/models/assessment.dart';
import '../../lib/language/german/german_language_presentation.dart';
import '../../lib/language/german/german_language_exercise_strategy.dart';

class _MockAiGateway implements AiGateway {
  @override
  bool get enabled => false;

  @override
  Future<AiReview> reviewWriting(String text, {String level = 'A1'}) async {
    return AiReview(corrected: text, explanation: '', issues: []);
  }

  @override
  Future<String> continueConversation({
    required String scenario,
    required String message,
    String level = 'A1',
  }) async {
    return '';
  }
}

class FakeLearnerRepository implements LearnerRepository {
  @override
  Future<bool> clearLocalData() async => true;
  @override
  LearnerState load() => LearnerState(updatedAt: DateTime.now());
  @override
  LearnerState reload() => LearnerState(updatedAt: DateTime.now());
  @override
  Future<LearnerState> reloadPersisted() async =>
      LearnerState(updatedAt: DateTime.now());
  @override
  Future<Set<String>> loadAndMigrateFavoriteVerbs() async => {};
  @override
  LearnerPersistence get persistence => throw UnimplementedError();
  @override
  PreferencesService get prefs => throw UnimplementedError();
  @override
  Future<void> record({
    required LearningContent item,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
    String? skillOverride,
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
  Future<void> toggleFavoriteVerb(String infinitive) async {}
  @override
  Future<void> save(LearnerState state) async {}
  void debugUpdateStats({
    required int wordsLearned,
    required int minutesStudied,
    required int streakDays,
  }) {}
}

class FakeFavoritesRepository implements FavoritesRepository {
  Future<void> addFavorite(String itemId) async {}
  Future<void> removeFavorite(String itemId) async {}
  @override
  Future<void> toggleFavorite(String itemId) async {}
  @override
  Future<Set<String>> getFavorites() async => {};
  @override
  Future<bool> isFavorite(String itemId) async => false;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Smoke test for Conversation & Grammar Screens', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    final prefs = await PreferencesService.instance();
    LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    final repo = FakeLearnerRepository();

    final grammarHubService = GrammarHubService();

    final deps = AppDependencies<ContentItem>(
      searchIndex: SearchIndex<ContentItem>(
        const [],
        VerbIndex(textNormalizer: const GermanTextNormalizer()),
        const GermanTextNormalizer(),
      ),
      verbIndex: VerbIndex(textNormalizer: const GermanTextNormalizer()),
      corpus: const [],
      languagePack: const GermanLanguagePack(),
      aiGateway: _MockAiGateway(),
      privacySettings: LocalPrivacySettingsStore(prefs),
      neuroSettings: NeuroAccessibilitySettings(prefs),
      userVocabularyService: UserVocabularyService.instance,
      favoritesRepository: FakeFavoritesRepository(),
      preferencesService: prefs,
      grammarHubService: grammarHubService,
    );

    // Test GrammarHubPage
    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(child: GrammarHubPage(dependencies: deps)),
      ),
    );
    for (int i = 0; i < 50; i++)
      await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GrammarHubPage), findsOneWidget);

    // Test ConversationPage
    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          child: ConversationPage(
            repo: repo,
            onDone: () {},
            exerciseStrategy: GermanLanguageExerciseStrategy(),
            presentation: GermanLanguagePresentation(),
            textNormalizer: GermanTextNormalizer(),
            aiGateway: _MockAiGateway(),
            privacySettings: LocalPrivacySettingsStore(prefs),
          ),
        ),
      ),
    );
    for (int i = 0; i < 50; i++)
      await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ConversationPage), findsOneWidget);

    // Clean up
    await grammarHubService.close();
  });
}
