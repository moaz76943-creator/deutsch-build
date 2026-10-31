import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_time_calendar_bank.dart';

void main() {
  group('A1A2TimeCalendarBank Unit Tests (L005)', () {
    test('Contains foundational calendar terms and 7 weekdays alignment', () {
      expect(A1A2TimeCalendarBank.calendarEntries.length, greaterThanOrEqualTo(6));
      expect(A1A2TimeCalendarBank.weekdaysDe.length, equals(7));
      expect(A1A2TimeCalendarBank.weekdaysAr.length, equals(7));
      expect(A1A2TimeCalendarBank.weekdaysDe.first, equals('Montag'));
      expect(A1A2TimeCalendarBank.weekdaysAr.first, equals('الإثنين'));

      final punct = A1A2TimeCalendarBank.calendarEntries.firstWhere((e) => e.germanWord == 'pünktlich');
      expect(punct.arabicMeaning, contains('منضبط في الموعد'));
    });
  });
}
