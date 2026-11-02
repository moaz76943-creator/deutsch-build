import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/architecture/operation_result.dart';

void main() {
  group('DirectedPairId Tests', () {
    test('100 language identities and their reverse pairs (A->B != B->A)', () {
      final langs = [
        'en', 'de', 'ar', 'fr', 'es', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'tr', 'nl', 'pl', 'sv', 'da', 'fi', 'no', 'el', 'he',
      ];
      final List<String> hundredLangs = [];
      for (var i = 0; i < 5; i++) {
        hundredLangs.addAll(langs.map((l) => '$l$i'));
      }

      for (var i = 0; i < hundredLangs.length - 1; i++) {
        final langA = hundredLangs[i];
        final langB = hundredLangs[i + 1];

        final pairAB = DirectedPairId(
          sourceLocale: langA,
          targetLocale: langB,
          semanticVersion: '1.0.0',
        );
        final pairBA = DirectedPairId(
          sourceLocale: langB,
          targetLocale: langA,
          semanticVersion: '1.0.0',
        );

        expect(pairAB.isValidForLearning(), isTrue);
        expect(pairBA.isValidForLearning(), isTrue);
        expect(pairAB == pairBA, isFalse);
        expect(pairAB.hashCode == pairBA.hashCode, isFalse);
      }
    });

    test('isReflexive pairs return isValidForLearning() == false', () {
      const pair = DirectedPairId(
        sourceLocale: 'de',
        targetLocale: 'de',
        semanticVersion: '1.0.0',
      );

      expect(pair.isReflexive, isTrue);
      expect(pair.isValidForLearning(), isFalse);
    });

    test('parse() and serialize() works for 3-part and 2-part legacy IDs', () {
      const pair3Part = DirectedPairId(
        sourceLocale: 'de',
        targetLocale: 'ar',
        semanticVersion: '2.0.0',
      );
      final serialized3Part = pair3Part.serialize();
      expect(serialized3Part, 'de_ar_2.0.0');

      final parsed3Part = DirectedPairId.parse(serialized3Part);
      expect(parsed3Part, equals(pair3Part));

      final parsed2Part = DirectedPairId.parse('de_ar');
      expect(parsed2Part.sourceLocale, 'de');
      expect(parsed2Part.targetLocale, 'ar');
      expect(parsed2Part.semanticVersion, '1.0.0'); // Legacy default
    });

    test('FormatException when parsing empty strings or invalid IDs', () {
      expect(() => DirectedPairId.parse(''), throwsA(isA<FormatException>()));
      expect(() => DirectedPairId.parse('de'), throwsA(isA<FormatException>()));
      expect(() => DirectedPairId.parse('de_ar_1_extra'), throwsA(isA<FormatException>()));
      expect(() => DirectedPairId.parse('_ar'), throwsA(isA<FormatException>()));
      expect(() => DirectedPairId.parse('de_'), throwsA(isA<FormatException>()));
      expect(() => DirectedPairId.parse('de_ar_'), throwsA(isA<FormatException>()));
    });
  });

  group('OperationResult Tests', () {
    test('Creating typed OperationResult failures and retaining actionable cause objects', () {
      final cause = Exception('Connection timeout');

      final resultUnavailable = OperationResult<String>.unavailable('ERR_01', 'Network unavailable', cause);
      expect(resultUnavailable.isSuccess, isFalse);
      expect(resultUnavailable.failure, isA<UnavailableFailure>());
      expect(resultUnavailable.failure.code, 'ERR_01');
      expect(resultUnavailable.failure.message, 'Network unavailable');
      expect(resultUnavailable.failure.cause, equals(cause));

      final resultInvalidInput = OperationResult<int>.invalidInput('ERR_02', 'Invalid number', 'Details');
      expect(resultInvalidInput.isSuccess, isFalse);
      expect(resultInvalidInput.failure, isA<InvalidInputFailure>());
      expect(resultInvalidInput.failure.cause, equals('Details'));

      final resultCancelled = OperationResult<bool>.cancelled('ERR_03', 'User cancelled', 42);
      expect(resultCancelled.isSuccess, isFalse);
      expect(resultCancelled.failure, isA<CancelledFailure>());
      expect(resultCancelled.failure.cause, equals(42));

      final resultIncompatibleVersion = OperationResult<double>.incompatibleVersion('ERR_04', 'Version mismatch', {'version': '1.0.0'});
      expect(resultIncompatibleVersion.isSuccess, isFalse);
      expect(resultIncompatibleVersion.failure, isA<IncompatibleVersionFailure>());
      expect(resultIncompatibleVersion.failure.cause, isA<Map>());
    });
  });
}
// J028 Hardened Identity
