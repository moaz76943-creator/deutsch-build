import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a2_b1_social_neighbor_ethics_bank.dart';

void main() {
  group('A2B1SocialNeighborEthicsBank Unit Tests (L018)', () {
    test('Contains core social ethics, hospitality, and neighborly duty terms', () {
      expect(A2B1SocialNeighborEthicsBank.neighborEntries.length, greaterThanOrEqualTo(5));

      final hospitality = A2B1SocialNeighborEthicsBank.neighborEntries.firstWhere((e) => e.germanWord == 'die Gastfreundschaft');
      expect(hospitality.arabicMeaning, contains('إكرام الضيف'));

      final respect = A2B1SocialNeighborEthicsBank.neighborEntries.firstWhere((e) => e.germanWord == 'der gegenseitige Respekt');
      expect(respect.arabicMeaning, contains('الاحترام المتبادل'));
    });
  });
}
