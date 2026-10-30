import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/semantic_pii_scrubber.dart';

void main() {
  group('SemanticPiiScrubber Unit Tests (N058)', () {
    final scrubber = SemanticPiiScrubber();

    test('Redacts email addresses and telephone numbers completely', () {
      const sensitive = 'Schreib mir an user@example.com oder ruf unter +49 170 1234567 an.';
      final result = scrubber.scrub(sensitive);

      expect(result.sanitizedText, contains('[EMAIL_REDACTED]'));
      expect(result.sanitizedText, contains('[PHONE_REDACTED]'));
      expect(result.sanitizedText, isNot(contains('user@example.com')));
      expect(result.redactedItemsCount, equals(2));
      expect(result.detectedPiiTypes, contains('email'));
      expect(result.detectedPiiTypes, contains('phone_number'));
    });

    test('Leaves harmless language learning input completely intact', () {
      const clean = 'Das Wetter in Berlin ist heute sehr schön und sonnig.';
      final result = scrubber.scrub(clean);

      expect(result.sanitizedText, equals(clean));
      expect(result.redactedItemsCount, equals(0));
      expect(result.detectedPiiTypes, isEmpty);
    });

    test('Empty string handles safely', () {
      final result = scrubber.scrub('');
      expect(result.sanitizedText, isEmpty);
      expect(result.redactedItemsCount, equals(0));
    });
  });
}
