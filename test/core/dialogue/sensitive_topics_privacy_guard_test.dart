import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/sensitive_topics_privacy_guard.dart';

void main() {
  group('SensitiveTopicsPrivacyGuard Tests', () {
    const guard = SensitiveTopicsPrivacyGuard();

    test('Redacts private email and phone numbers from utterance', () {
      const input = 'Meine Email ist user@example.com und Telefon ist +49 170 12345678.';
      final report = guard.inspectAndSanitize(input);

      expect(report.isClean, isTrue);
      expect(report.flaggedCategory, equals(SensitiveCategory.personallyIdentifiableInfo));
      expect(report.sanitizedText, contains('[E-MAIL REDAKTIERT]'));
      expect(report.sanitizedText, contains('[TELEFONNUMMER REDAKTIERT]'));
      expect(report.sanitizedText, isNot(contains('user@example.com')));
    });

    test('Redacts credit card numbers automatically', () {
      const input = 'Hier ist meine Nummer: 4111-2222-3333-4444 für das Ticket.';
      final report = guard.inspectAndSanitize(input);

      expect(report.sanitizedText, contains('[KREDITKARTE REDAKTIERT]'));
      expect(report.sanitizedText, isNot(contains('4111-2222-3333-4444')));
    });

    test('Intercepts abusive profanity and redirects with polite educational pivot', () {
      const input = 'Du bist ein Idiot und ich hasse dich!';
      final report = guard.inspectAndSanitize(input);

      expect(report.isClean, isFalse);
      expect(report.flaggedCategory, equals(SensitiveCategory.profanityOrHarassment));
      expect(report.educationalPivotResponse, contains('respektvolles Sprachtraining'));
    });

    test('Passes clean conversational phrases untouched', () {
      const input = 'Ich möchte bitte einen Kaffee mit Milch bestellen.';
      final report = guard.inspectAndSanitize(input);

      expect(report.isClean, isTrue);
      expect(report.flaggedCategory, isNull);
      expect(report.sanitizedText, equals(input));
    });
  });
}
