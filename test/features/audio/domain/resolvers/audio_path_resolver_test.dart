import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/audio/domain/resolvers/audio_path_resolver.dart';

void main() {
  group('AudioPathResolver', () {
    late AudioPathResolver resolver;

    setUp(() {
      resolver = AudioPathResolver();
    });

    test('should resolve valid canonical concept IDs to expected asset URIs', () {
      final path = resolver.resolvePath('zug', 'de');
      expect(path, 'assets/audio/de/zug.mp3');

      final path2 = resolver.resolvePath('auto', 'ar');
      expect(path2, 'assets/audio/ar/auto.mp3');
    });

    test('should sanitize path against irregular characters', () {
      final path = resolver.resolvePath('z\u00FCg/test', 'de');
      expect(path, 'assets/audio/de/zgtest.mp3');

      final path2 = resolver.resolvePath('..\\auto!@#\$%', 'de-DE');
      expect(path2, 'assets/audio/de-de/auto.mp3');
    });

    test('should return null for null or empty inputs (graceful fallback)', () {
      expect(resolver.resolvePath(null, 'de'), isNull);
      expect(resolver.resolvePath('zug', null), isNull);
      expect(resolver.resolvePath('', 'de'), isNull);
      expect(resolver.resolvePath('zug', '   '), isNull);
      expect(resolver.resolvePath(null, null), isNull);
    });

    test('should return null if sanitization results in an empty string', () {
      expect(resolver.resolvePath('!@#\$%', 'de'), isNull);
      expect(resolver.resolvePath('zug', '///'), isNull);
    });
  });
}
