import 'package:test/test.dart';
import '../../lib/src/platform/android_ambient_tile_engine.dart';

void main() {
  group('AndroidAmbientTileEngine Unit Tests (N082)', () {
    final engine = AndroidAmbientTileEngine();

    test('Toggles Quick Settings Tile state properly', () {
      expect(engine.isTileActive, isFalse);
      engine.setTileActive(true);
      expect(engine.isTileActive, isTrue);
    });

    test('Builds ambient glance card with complete vocabulary and example data', () {
      final card = engine.buildGlanceCard(
        word: 'Entscheidung',
        pos: 'die (Nomen)',
        example: 'Das war eine kluge Entscheidung.',
        translation: 'Decision',
        dueTotal: 7,
      );

      expect(card.targetWord, equals('Entscheidung'));
      expect(card.partOfSpeech, equals('die (Nomen)'));
      expect(card.dueCountToday, equals(7));
      expect(engine.getTileSubtitle(card.dueCountToday), equals('7 Vokabeln fällig'));
    });

    test('Displays celebratory subtitle when zero reviews are due', () {
      expect(engine.getTileSubtitle(0), contains('Alles erledigt'));
    });
  });
}
