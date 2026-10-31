import 'package:test/test.dart';
import '../../lib/src/content/post_paket_scenario.dart';

void main() {
  group('PostPaketScenario Unit Tests (L028)', () {
    test('Contains realistic postal branch dialogue with certified mail and tracking expressions', () {
      expect(PostPaketScenario.turns.length, equals(5));

      final mailTurn = PostPaketScenario.turns[1];
      expect(mailTurn.utteranceDe, contains('Paket nach München'));
      expect(mailTurn.utteranceDe, contains('per Einschreiben'));

      final receiptTurn = PostPaketScenario.turns.last;
      expect(receiptTurn.utteranceDe, contains('Einlieferungsbeleg'));
      expect(receiptTurn.utteranceAr, contains('إيصال الإيداع'));
    });
  });
}
