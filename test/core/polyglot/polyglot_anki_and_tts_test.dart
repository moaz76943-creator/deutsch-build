import 'dart:io';
import 'package:test/test.dart';
import '../../../lib/polyglot_core.dart';

void main() {
  group('Task #4990: Offline Anki Exporter & TTS Pronunciation Helper Tests', () {
    late PolyglotAppBootstrap app;

    setUp(() {
      final extra = File('assets/packs/de_daily_tech_troubleshooting.json').readAsStringSync();
      app = PolyglotAppBootstrap.initialize(extraJsonPacks: [extra]);
    });

    tearDown(() async {
      await app.dispose();
    });

    test('Resolves BCP-47 TTS locales and sanitizes spoken sentences', () {
      expect(PolyglotTtsHelper.resolveBcp47Locale('de'), equals('de-DE'));
      expect(PolyglotTtsHelper.resolveBcp47Locale('ar'), equals('ar-SA'));
      expect(
        PolyglotTtsHelper.sanitizeForSpeech('„Der Wechselrichter [Typ A] läuft stabil.“'),
        equals('Der Wechselrichter läuft stabil.'),
      );
    });

    test('Exports Anki CSV with Arabic-first columns and AMOLED-safe article HTML colors', () {
      const sampleUnits = [
        PolyglotLearningUnit(
          id: 'anki_test_01',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'engineering',
          categoryId: 'hardware',
          title: 'العاكس الكهربائي',
          targetExpression: 'der Wechselrichter',
          contextualSentence: 'Der Wechselrichter wandelt Gleichstrom in Wechselstrom um.',
          commonPitfall: 'die Wechselrichter (خطأ في الجنس)',
          arabicExplanation: 'العاكس الكهربائي (اسم مذكر)',
          tags: ['Ingenieurwesen', 'C1'],
        ),
      ];

      final csv = PolyglotAnkiExporter.exportAnkiCsv(sampleUnits, arabicFirst: true);
      expect(csv, startsWith('Arabic_Front,Target_Expression_HTML'));
      expect(csv, contains('#4DA6FF'));
      expect(csv, contains('der Wechselrichter'));
      expect(csv, contains('مذكر'));
    });

    test('Loads daily tech and medical appointment JSON pack cleanly', () {
      expect(
        app.registry.queryUnits(searchQuery: 'Router neu starten'),
        isNotEmpty,
      );
      expect(
        app.registry.queryUnits(searchQuery: 'Kontrolltermin'),
        isNotEmpty,
      );
    });
  });
}
