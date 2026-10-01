import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fake_async/fake_async.dart';

import '../../lib/services/user_vocabulary_service.dart';
import '../../lib/ui_v35/learning_pages.dart';
import '../../lib/models/content.dart';
import '../../lib/services/repository.dart';
import '../../lib/services/learner_persistence.dart';
import '../../lib/services/preferences_service.dart';
import '../../lib/language/german/german_language_presentation.dart';
import '../../lib/language/german/german_content_quality.dart';
import '../../lib/language/german/german_text_normalizer.dart';
import '../../lib/services/app_dependencies.dart';
import '../../lib/services/search_index.dart';
import '../../lib/services/verb_index.dart';
import '../../lib/services/ai_gateway.dart';
import '../../lib/services/privacy_settings.dart';
import '../../lib/services/neuro_accessibility_settings.dart';
import '../../lib/language/german/german_language_pack.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

import 'package:path/path.dart' as p;

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

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await UserVocabularyService.instance.close();
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'user_vocabulary.db');
    if (await File(path).exists()) {
      await databaseFactory.deleteDatabase(path);
    }
  });

  testWidgets('VocabularyV35 SegmentedButton toggles correctly between views', (
    WidgetTester tester,
  ) async {
    fakeAsync((async) {
      tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        final sharedPrefs = await SharedPreferences.getInstance();
        final prefs = await PreferencesService.instance();
        final persistence = LearnerPersistence(
          prefs,
          LearnerRepository.key,
          LearnerRepository.legacyFavoriteKey,
        );
        final repo = LearnerRepository(prefs, persistence: persistence);

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
          favoritesRepository: FavoritesRepository.instance,
          preferencesService: prefs,
        );

        final corpus = [
          ContentItem(
            id: '1',
            german: 'Hund',
            arabic: 'كلب',
            sentence: 'Der Hund bellt.',
            sentenceAr: 'الكلب ينبح.',
            topic: 'Animals',
            skill: 'vocab',
            article: 'der',
            plural: 'Hunde',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: ScaffoldMessenger(
              child: VocabularyV35(
                repo: repo,
                corpus: corpus,
                onDone: () {},
                presentation: const GermanLanguagePresentation(),
                contentQuality: const GermanContentQuality(),
                textNormalizer: const GermanTextNormalizer(),
                dependencies: deps,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Default mode is List
        expect(find.byType(ListView), findsWidgets);
        expect(find.text('Hund'), findsWidgets);

        // Tap Grid view icon
        await tester.tap(find.byIcon(Icons.grid_view_outlined));
        await tester.pumpAndSettle();

        // Verify Grid is showing
        expect(find.byType(GridView), findsOneWidget);
        expect(prefs.getString('vocabulary_view_mode'), 'grid');

        // Tap Flashcard view icon
        await tester.tap(find.byIcon(Icons.style_outlined));
        await tester.pumpAndSettle();

        // Verify Flashcard (PageView) is showing
        expect(find.byType(PageView), findsOneWidget);
        expect(find.text('اضغط للقلب'), findsOneWidget);
        expect(prefs.getString('vocabulary_view_mode'), 'flashcard');

        // Tap card to flip
        await tester.tap(find.text('اضغط للقلب'));
        await tester.pumpAndSettle();

        // Verify back of flashcard
        expect(find.text('كلب'), findsOneWidget);

        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();
      });
      async.flushTimers();
    });
  });
}
