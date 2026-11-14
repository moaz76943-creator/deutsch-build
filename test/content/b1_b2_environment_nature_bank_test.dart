import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/b1_b2_environment_nature_bank.dart';

void main() {
  group('B1B2EnvironmentNatureBank Unit Tests (L011)', () {
    test('Contains core environmental, sustainability, and recycling terms', () {
      expect(B1B2EnvironmentNatureBank.ecoEntries.length, greaterThanOrEqualTo(5));

      final pfand = B1B2EnvironmentNatureBank.ecoEntries.firstWhere((e) => e.germanWord == 'das Pfand');
      expect(pfand.arabicMeaning, contains('الوديعة المالية المستردة'));

      final sustain = B1B2EnvironmentNatureBank.ecoEntries.firstWhere((e) => e.germanWord == 'die Nachhaltigkeit');
      expect(sustain.cefrLevel, equals('B2'));
    });
  });
}
