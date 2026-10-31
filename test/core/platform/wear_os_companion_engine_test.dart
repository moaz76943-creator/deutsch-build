import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/wear_os_companion_engine.dart';

void main() {
  group('WearOsCompanionEngine Tests', () {
    const engine = WearOsCompanionEngine();

    final testSnapshot = WearOsTileSnapshot(
      streakDays: 42,
      dailyProgressRatio: 0.85,
      wordOfTheDay: 'der Schmetterling',
      wordMeaning: 'butterfly',
      phoneticIpa: 'ˈʃmɛtɐlɪŋ',
      dueReviewCardsCount: 4,
    );

    test('Encodes wear packet strictly under 512 bytes for low-energy BLE transmission', () {
      final packet = engine.encodeWearPacket(testSnapshot);

      expect(packet.isNotEmpty, isTrue);
      expect(packet.length, lessThan(512));
      expect(packet.length, lessThan(200)); // Highly optimized JSON payload
    });

    test('Packet round-trip serialization preserves all wrist telemetry accurately', () {
      final packet = engine.encodeWearPacket(testSnapshot);
      final decoded = engine.decodeWearPacket(packet);

      expect(decoded.streakDays, equals(42));
      expect(decoded.wordOfTheDay, equals('der Schmetterling'));
      expect(decoded.wordMeaning, equals('butterfly'));
      expect(decoded.dueReviewCardsCount, equals(4));
    });

    test('Processes wrist gesture actions for rapid flashcard triage on the go', () {
      final res = engine.processWristReviewGesture(WristSwipeAction.remembered, 'der Baum');
      expect(res, contains('FSRS interval scheduled'));
    });
  });
}
