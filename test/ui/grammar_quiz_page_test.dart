import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';
import 'package:deutsch_bilarabi/services/app_dependencies.dart';
import 'package:deutsch_bilarabi/ui_v35/grammar/grammar_quiz_page.dart';
import 'package:deutsch_bilarabi/services/user_vocabulary_service.dart';
import 'package:deutsch_bilarabi/services/privacy_settings.dart';
import 'package:deutsch_bilarabi/services/neuro_accessibility_settings.dart';
import 'package:deutsch_bilarabi/services/search_index.dart';

import 'package:deutsch_bilarabi/language/german/german_language_pack.dart';
import 'package:deutsch_bilarabi/services/ai_gateway_factory.dart';
import 'package:deutsch_bilarabi/models/ai_runtime_config.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late GrammarHubService service;
  late AppDependencies<ContentItem> dependencies;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    service = GrammarHubService(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    // ensure db is initialized
    await service.database;

    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.instance();
    final languagePack = const GermanLanguagePack();
    final contentPack = languagePack.contentPack;
    final corpus = contentPack.items;
    final verbIndex = contentPack.verbIndex;
    final searchIndex = SearchIndex(
      corpus,
      verbIndex,
      languagePack.textNormalizer,
    );

    dependencies = AppDependencies<ContentItem>(
      searchIndex: searchIndex,
      verbIndex: verbIndex,
      corpus: corpus,
      languagePack: languagePack,
      aiGateway: AiGatewayFactory.fromRuntimeConfig(
        AiRuntimeConfig.fromEnvironment(),
      ),
      privacySettings: LocalPrivacySettingsStore(prefs),
      neuroSettings: NeuroAccessibilitySettings(prefs),
      userVocabularyService: UserVocabularyService.instance,
      favoritesRepository: FavoritesRepository.instance,
      preferencesService: prefs,
      grammarHubService: service,
    );
  });

  tearDown(() async {
    await service.close();
  });

  testWidgets('GrammarQuizPage loads and displays quiz questions', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
            child: GrammarQuizPage(
              topicId: 'a1_nominativ',
              dependencies: dependencies,
            ),
          ),
        ),
      );

      // Wait for the async _loadQuizzes to complete
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // The question should be rendered
      expect(
        find.text('Welcher Artikel steht im Nominativ für maskulin?'),
        findsOneWidget,
      );
      // Verify options exist
      expect(find.text('der'), findsOneWidget);
      expect(find.text('den'), findsOneWidget);
    });
  });

  testWidgets('GrammarQuizPage allows answering and gives feedback', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
            child: GrammarQuizPage(
              topicId: 'a1_nominativ',
              dependencies: dependencies,
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap the correct answer (index 0 is 'der')
      await tester.tap(find.text('der').first);
      await tester.pumpAndSettle();

      // Feedback and next button should appear
      expect(
        find.text('"der" ist der maskuline Artikel im Nominativ.'),
        findsOneWidget,
      );
      expect(find.text('Next Question'), findsOneWidget);
    });
  });
}
