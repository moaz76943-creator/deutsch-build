import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/core_roots_lexemes_registry.dart';

void main() {
  group('CoreRootsLexemesRegistry Tests', () {
    late CoreRootsLexemesRegistry registry;

    setUp(() {
      registry = CoreRootsLexemesRegistry()..initialize();
    });

    test('Resolves Semitic triconsonantal root k-t-b across Arabic, Maltese, and Syriac', () {
      final root = registry.findRootForWord('ar', 'كتب');
      expect(root, isNotNull);
      expect(root!.protoForm, equals('k-t-b'));
      expect(root.languageLexemes['mt'], equals('kiteb'));
      expect(root.languageLexemes['syc'], equals('ܟܬܒ'));
    });
  });
}
