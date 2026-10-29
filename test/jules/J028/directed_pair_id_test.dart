import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

void main() {
  test('directed pairs are distinct and serialize without losing versions', () {
    const ab = DirectedPairId(
      sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0',
    );
    const ba = DirectedPairId(
      sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0',
    );
    expect(ab, isNot(ba));
    expect(ab.isValidForLearning(), isTrue);
    expect(DirectedPairId.fromJson(ab.toJson()), ab);
    expect(DirectedPairId.fromLegacyString(ab.uniqueKey), ab);
  });

  test('missing versions and ambiguous identifiers never silently migrate', () {
    expect(() => DirectedPairId.fromLegacyString('ar_de'), throwsFormatException);
    expect(
      DirectedPairId.fromLegacyString('ar_de', missingVersion: '1.0.0'),
      const DirectedPairId(
        sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0',
      ),
    );
    expect(() => DirectedPairId.fromLegacyString('zh_Hant_ar_v1'), throwsFormatException);
    expect(() => DirectedPairId.fromLegacyString('ar_de_v_2'), throwsFormatException);
    expect(() => DirectedPairId.fromJson({'sourceLocale': 1}), throwsFormatException);
  });

  test('invalid locales and reflexive pairs cannot be learned', () {
    for (final pair in [
      const DirectedPairId(sourceLocale: 'ar', targetLocale: 'ar', semanticVersion: '1.0.0'),
      const DirectedPairId(sourceLocale: '', targetLocale: 'de', semanticVersion: '1.0.0'),
      const DirectedPairId(sourceLocale: 'de', targetLocale: 'en', semanticVersion: ''),
      const DirectedPairId(sourceLocale: 'zh_Hant', targetLocale: 'de', semanticVersion: '1.0.0'),
    ]) {
      expect(pair.isValidForLearning(), isFalse);
    }
    expect(
      const DirectedPairId(sourceLocale: 'zh-Hant', targetLocale: 'de', semanticVersion: '1.0.0')
          .isValidForLearning(),
      isTrue,
    );
  });
}
