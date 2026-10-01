import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/ui_v35/zen/zen_context_reader.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:deutsch_bilarabi/services/app_dependencies.dart';
import 'package:deutsch_bilarabi/core/content_contract.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/search_index.dart';
import 'package:deutsch_bilarabi/services/verb_index.dart';
import 'package:deutsch_bilarabi/language/language_text_normalizer.dart';
import 'package:deutsch_bilarabi/language/language_pack.dart';
import 'package:deutsch_bilarabi/services/ai_gateway.dart';
import 'package:deutsch_bilarabi/services/privacy_settings.dart';
import 'package:deutsch_bilarabi/services/neuro_accessibility_settings.dart';
import 'package:deutsch_bilarabi/language/german/german_language_pack.dart';
import 'package:deutsch_bilarabi/services/ai_contract.dart';
import 'package:deutsch_bilarabi/services/user_vocabulary_service.dart';

class MockPreferences implements PreferencesService {
  final Map<String, dynamic> _data = {};

  @override
  String? getString(String key) => _data[key];

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  List<String>? getStringList(String key) => _data[key];

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  bool getBool(String key) => _data[key] ?? false;

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }
}

class FakeUserVocabularyService implements UserVocabularyService {
  @override
  Future<void> addCustomEntry(Map<String, dynamic> entry) async {}
  @override
  Future<void> close() async {}
  @override
  get database => throw UnimplementedError();
  @override
  Future<void> deleteCustomEntry(String id) async {}
  @override
  Future<List<Map<String, dynamic>>> getCustomEntries({
    String? targetLanguage,
  }) async => [];
}

class FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<String>> getFavorites() async => {};
  @override
  Future<bool> isFavorite(String id) async => false;
  @override
  Future<void> toggleFavorite(String id) async {}
}

class TestItem implements LearningContent {
  @override
  final String id;
  @override
  final String exampleText;

  const TestItem(this.id, this.exampleText);

  @override
  String get sourceText => '';
  @override
  String get translationText => '';
  @override
  String get exampleTranslationText => '';
  @override
  String get grammaticalMarker => '';
  @override
  String get pluralForm => '';
  @override
  List<String> get acceptedForms => const [];
  @override
  String get topic => 'topic';
  @override
  String get skill => 'vocabulary';
}

class MockNormalizer implements LanguageTextNormalizer {
  @override
  String answer(String value) => value;
}

class MockAiGateway implements AiGateway {
  @override
  bool get enabled => false;

  @override
  Future<Map<String, dynamic>> evaluate({
    required String expected,
    required String prompt,
    required String answer,
    required Map<String, dynamic> schema,
  }) async => {};

  @override
  Future<String> generate({
    required String prompt,
    required Map<String, dynamic> schema,
    String? contextData,
  }) async => '';

  @override
  Future<bool> get isAvailable async => false;

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

class MockPrivacySettings implements PrivacySettingsStore {
  @override
  bool get telemetryEnabled => false;

  @override
  Future<void> updateTelemetry(bool v) async {}

  @override
  bool get personalDataProcessingEnabled => false;

  @override
  Future<void> updatePersonalDataProcessing(bool v) async {}

  @override
  bool get hasAcknowledgedPolicy => false;

  @override
  Future<void> acknowledgePolicy() async {}

  @override
  Future<bool> cloudAiEnabled() async => false;

  @override
  Future<bool> setCloudAi(bool value) async => true;

  @override
  Future<bool> speechEnabled() async => false;

  @override
  Future<bool> setSpeech(bool value) async => true;
}

void main() {
  testWidgets('ZenContextReader displays mastered vocabulary in paragraphs', (
    tester,
  ) async {
    final prefs = MockPreferences();
    final persistence = LearnerPersistence(prefs, 'test_key', 'test_legacy');
    final repo = LearnerRepository(prefs, persistence: persistence);

    // Seed some mastered vocabulary
    await repo.save(
      LearnerState(
        learned: {'word1', 'word2', 'word3', 'word4'},
        updatedAt: DateTime.now(),
      ),
    );

    final corpus = [
      const TestItem('word1', 'Ich esse einen Apfel.'),
      const TestItem('word2', 'Der Hund läuft schnell.'),
      const TestItem('word3', 'Wir lernen Deutsch.'),
      const TestItem('word4', 'Das Haus ist groß.'),
    ];

    final normalizer = MockNormalizer();
    final verbIndex = VerbIndex(textNormalizer: normalizer);

    // Create minimal mock dependencies
    final deps = AppDependencies<LearningContent>(
      searchIndex: SearchIndex(corpus, verbIndex, normalizer),
      verbIndex: verbIndex,
      corpus: corpus,
      languagePack: GermanLanguagePack(),
      aiGateway: MockAiGateway(),
      privacySettings: MockPrivacySettings(),
      neuroSettings: NeuroAccessibilitySettings(prefs),
      userVocabularyService: FakeUserVocabularyService(),
      favoritesRepository: FakeFavoritesRepository(),
      preferencesService: prefs,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ZenContextReader(repo: repo, dependencies: deps),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(
        'Ich esse einen Apfel. Der Hund läuft schnell. Wir lernen Deutsch.',
      ),
      findsOneWidget,
    );
    expect(find.text('Das Haus ist groß.'), findsOneWidget);
  });
}
