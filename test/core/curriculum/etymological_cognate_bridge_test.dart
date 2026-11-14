import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/etymological_cognate_bridge.dart';

void main() {
  group('EtymologicalCognateBridge Unit Tests (N026)', () {
    final bridge = EtymologicalCognateBridge();

    test('Resolves English cognate bridge for German Wasser', () {
      final matches = bridge.findBridges('Wasser', userKnownLanguage: 'en');
      expect(matches.length, equals(1));
      expect(matches.first.bridgeWord, equals('Water'));
      expect(matches.first.isFalseFriend, isFalse);
      expect(bridge.calculateCognitiveDiscount(matches), greaterThan(0.4));
    });

    test('Correctly flags critical false friend (bekommen vs become)', () {
      final matches = bridge.findBridges('bekommen');
      expect(matches.isNotEmpty, isTrue);
      expect(matches.first.isFalseFriend, isTrue);
      expect(matches.first.mnemonicNote, contains('FALSE FRIEND'));
      // Cognitive discount should be negative due to interference penalty
      expect(bridge.calculateCognitiveDiscount(matches), lessThan(0.0));
    });

    test('Identifies Arabic etymological transmission for Zucker', () {
      final matches = bridge.findBridges('Zucker', userKnownLanguage: 'ar');
      expect(matches.length, equals(1));
      expect(matches.first.bridgeLanguage, equals('ar'));
      expect(matches.first.bridgeWord, contains('Sukkar'));
    });
  });
}
