import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/supported_language.dart';

void main() {
  group('AppTargetLanguage Architecture Invariants', () {
    test('defaults to German when code is unrecognized', () {
      expect(AppTargetLanguage.fromCode('unknown'), AppTargetLanguage.german);
    });

    test('correctly resolves supported languages', () {
      expect(AppTargetLanguage.fromCode('de'), AppTargetLanguage.german);
      expect(AppTargetLanguage.fromCode('en'), AppTargetLanguage.english);
      expect(AppTargetLanguage.fromCode('fr'), AppTargetLanguage.french);
      expect(AppTargetLanguage.fromCode('es'), AppTargetLanguage.spanish);
    });
  });
}
