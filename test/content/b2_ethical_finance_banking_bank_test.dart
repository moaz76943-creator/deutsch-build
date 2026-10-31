import 'package:test/test.dart';
import '../../lib/src/content/b2_ethical_finance_banking_bank.dart';

void main() {
  group('B2EthicalFinanceBankingBank Unit Tests (L013)', () {
    test('Contains ethical banking terms emphasizing financial honesty and zero usury', () {
      expect(B2EthicalFinanceBankingBank.financeEntries.length, greaterThanOrEqualTo(5));

      final transfer = B2EthicalFinanceBankingBank.financeEntries.firstWhere((e) => e.germanWord == 'die Überweisung');
      expect(transfer.arabicMeaning, contains('التحويل المالي'));

      final trade = B2EthicalFinanceBankingBank.financeEntries.firstWhere((e) => e.germanWord == 'der ehrliche Handel');
      expect(trade.arabicMeaning, contains('التجارة النزيهة'));
    });
  });
}
