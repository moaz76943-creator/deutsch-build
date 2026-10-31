import 'package:test/test.dart';
import '../../lib/src/content/offline_phonetic_index_builder.dart';

void main() {
  group('OfflinePhoneticIndexBuilder Unit Tests (L088)', () {
    final builder = OfflinePhoneticIndexBuilder();

    test('Registers and resolves phonetic IPA record with audio offset timestamps', () {
      builder.registerRecord(const PhoneticIndexRecord(
        lemma: 'Wasser',
        ipaTranscription: '[ˈvasɐ]',
        audioStartSeconds: 1.25,
        audioEndSeconds: 1.85,
        primaryStressSyllable: 'Was',
      ));

      expect(builder.indexedCount, equals(1));

      final result = builder.resolvePhonetics('Wasser');
      expect(result, isNotNull);
      expect(result!.ipaTranscription, equals('[ˈvasɐ]'));
      expect(result.primaryStressSyllable, equals('Was'));
      expect(result.audioStartSeconds, equals(1.25));
    });

    test('Returns null for unindexed terms', () {
      expect(builder.resolvePhonetics('unbekannt'), isNull);
    });
  });
}
