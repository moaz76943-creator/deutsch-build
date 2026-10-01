import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';
import 'package:deutsch_bilarabi/services/app_dependencies.dart';
import 'package:deutsch_bilarabi/ui_v35/grammar/grammar_hub_page.dart';
import 'package:deutsch_bilarabi/services/user_vocabulary_service.dart';
import 'package:deutsch_bilarabi/services/privacy_settings.dart';
import 'package:deutsch_bilarabi/services/neuro_accessibility_settings.dart';
import 'package:deutsch_bilarabi/services/search_index.dart';
import 'package:deutsch_bilarabi/services/verb_index.dart';
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
    final searchIndex = SearchIndex(corpus, verbIndex, languagePack.textNormalizer);

    dependencies = AppDependencies<ContentItem>(
        searchIndex: searchIndex,
        verbIndex: verbIndex,
        corpus: corpus,
        languagePack: languagePack,
        aiGateway: AiGatewayFactory.fromRuntimeConfig(AiRuntimeConfig.fromEnvironment()),
        privacySettings: LocalPrivacySettingsStore(prefs),
        neuroSettings: NeuroAccessibilitySettings(prefs),
        userVocabularyService: UserVocabularyService.instance,
        favoritesRepository: FavoritesRepository.instance,
        grammarHubService: service,
      );
  });

  tearDown(() async {
    await service.close();
  });

  testWidgets('GrammarHubPage loads and displays topics for default level A1', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
             child: GrammarHubPage(dependencies: dependencies),
          )
        ),
      );

      // Wait for the async _loadTopics to complete
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();

      // The A1 topic (Nominativ) should be rendered
      expect(find.text('Nominativ'), findsOneWidget);
      expect(find.text('حالة الرفع'), findsOneWidget);
    });
  });

  testWidgets('GrammarHubPage switches levels and displays correct topics', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
             child: GrammarHubPage(dependencies: dependencies),
          )
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();

      // Tap on the B1 level chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'B1'));

      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();

      // The B1 topic (Passiv) should be rendered
      expect(find.text('Passiv'), findsOneWidget);
      expect(find.text('Nominativ'), findsNothing); // A1 topic should be gone
    });
  });
}
