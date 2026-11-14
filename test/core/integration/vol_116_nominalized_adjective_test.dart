import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_nominalized_adjective_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave4_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4904 Nominalized Adjective Engine Tests', () {
    test('LING-027: Definite vs Indefinite person noun inflects correctly', () {
      // der Bekannte (Definite Maskulin Nom)
      final resDef = GermanNominalizedAdjectiveEngine.inflect(
        adjective: 'bekannt',
        determinerType: DeterminerType.definiteArticle,
        gramCase: NominalizedCase.nominativ,
        gender: PersonGender.maskulin,
      );
      expect(resDef.fullPhrase, equals('der Bekannte'));
      expect(resDef.inflectedNounForm, equals('Bekannte'));

      // ein Bekannter (Indefinite Maskulin Nom)
      final resIndef = GermanNominalizedAdjectiveEngine.inflect(
        adjective: 'bekannt',
        determinerType: DeterminerType.indefiniteArticle,
        gramCase: NominalizedCase.nominativ,
        gender: PersonGender.maskulin,
      );
      expect(resIndef.fullPhrase, equals('ein Bekannter'));
      expect(resIndef.inflectedNounForm, equals('Bekannter'));
    });

    test('LING-027: Indefinite pronouns govern -es suffix on abstract neuter', () {
      final resEtwas = GermanNominalizedAdjectiveEngine.inflect(
        adjective: 'neu',
        determinerType: DeterminerType.indefinitePronoun,
        gramCase: NominalizedCase.nominativ,
        gender: PersonGender.abstractNeuter,
        explicitDeterminer: 'etwas',
      );
      expect(resEtwas.fullPhrase, equals('etwas Neues'));
      expect(resEtwas.inflectedNounForm, equals('Neues'));

      final resNichts = GermanNominalizedAdjectiveEngine.inflect(
        adjective: 'schlecht',
        determinerType: DeterminerType.indefinitePronoun,
        gramCase: NominalizedCase.nominativ,
        gender: PersonGender.abstractNeuter,
        explicitDeterminer: 'nichts',
      );
      expect(resNichts.fullPhrase, equals('nichts Schlechtes'));
    });

    test('LING-027: alles Gute follows weak ending -e', () {
      final resAlles = GermanNominalizedAdjectiveEngine.inflect(
        adjective: 'gut',
        determinerType: DeterminerType.indefinitePronoun,
        gramCase: NominalizedCase.nominativ,
        gender: PersonGender.abstractNeuter,
        explicitDeterminer: 'alles',
      );
      expect(resAlles.fullPhrase, equals('alles Gute'));
      expect(resAlles.inflectedNounForm, equals('Gute'));
    });

    test('UI Bridge generates accurate Task 4904 diagnostics report', () {
      final bridge = Vol116Wave4UIBridge();
      final report = bridge.getTask4904Diagnostics();

      expect(report['task_id'], equals(4904));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(96));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
