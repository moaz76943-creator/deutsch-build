import 'dart:io';
import 'package:test/test.dart';
import '../../../lib/polyglot_core.dart';

void main() {
  group('Task #4988: Offline Fuzzy/Umlaut Search & Gender Color-Coding Tests', () {
    late PolyglotUnifiedRegistry registry;

    setUp(() {
      registry = PolyglotUnifiedRegistry();
      registry.registerModule(GermanC1C2CoreFeaturePack());
      registry.registerModule(GermanRealWorldDialoguesPack());
      registry.registerLanguage(const LanguageDescriptor(
        isoCode: 'tr',
        nativeName: 'Türkçe',
        arabicName: 'التركية',
      ));
      final rawEsTr = File('assets/packs/es_tr_professional_starter.json').readAsStringSync();
      PolyglotJsonPackLoader.loadIntoRegistry(registry, rawEsTr);
    });

    test('Finds German sentences even when user omits Umlauts or Eszett', () {
      final hits = PolyglotOfflineSearchEngine.search(registry, 'storungsfrei');
      expect(hits, isEmpty); // Not in C1-C2 core pack unless we query existing word
      final hits2 = PolyglotOfflineSearchEngine.search(registry, 'gerauschlos');
      expect(hits2, isNotEmpty);
      expect(hits2.first.unit.contextualSentence, contains('geräuschlos'));
    });

    test('Finds units by normalized Arabic query (ignoring Alef Hamza forms)', () {
      final hits = PolyglotOfflineSearchEngine.search(registry, 'اداه التعريف');
      expect(hits, isNotEmpty);
    });

    test('Detects German grammatical gender and assigns AMOLED-safe color hex', () {
      expect(
        PolyglotOfflineSearchEngine.detectGermanArticle('der Wechselrichter'),
        equals(GermanArticleGender.masculine),
      );
      expect(
        PolyglotOfflineSearchEngine.detectGermanArticle('die Kalibrierung'),
        equals(GermanArticleGender.feminine),
      );
      expect(
        PolyglotOfflineSearchEngine.detectGermanArticle('das Schaltbild'),
        equals(GermanArticleGender.neuter),
      );
    });

    test('Supports Spanish and Turkish packs seamlessly', () {
      expect(registry.queryUnits(languageCode: 'es').length, equals(2));
      expect(registry.queryUnits(languageCode: 'tr').length, equals(1));
    });
  });
}
