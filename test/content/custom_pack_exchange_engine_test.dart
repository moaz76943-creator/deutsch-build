import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/custom_pack_exchange_engine.dart';

void main() {
  group('CustomPackExchangeEngine Unit Tests (L093)', () {
    final engine = CustomPackExchangeEngine();

    test('Creates valid custom pack export header with ethical declaration', () {
      final header = engine.createExportHeader(
        title: 'Medizinischer Fachwortschatz A2/B1',
        author: 'Teacher_Omar',
        language: 'de',
        cards: 75,
        withAudio: true,
      );

      expect(header.packTitle, contains('Medizinischer'));
      expect(header.cardCount, equals(75));
      expect(header.ethicalDeclaration, contains('100% Ethical'));

      final isValid = engine.validateCustomPack(header);
      expect(isValid, isTrue);
    });

    test('Rejects custom packs containing prohibited language codes', () {
      final tainted = engine.createExportHeader(
        title: 'Tainted Deck',
        author: 'Unknown',
        language: 'he', // Prohibited
        cards: 10,
        withAudio: false,
      );

      expect(engine.validateCustomPack(tainted), isFalse);
    });
  });
}
