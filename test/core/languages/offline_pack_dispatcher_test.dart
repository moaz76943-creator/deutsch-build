import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/directed_pair_matrix_engine.dart';
import 'package:deutsch_build/src/core/languages/offline_pack_dispatcher.dart';
import 'package:deutsch_build/src/core/languages/western_languages_registry.dart';

void main() {
  group('OfflinePackDispatcher Tests', () {
    late DeclarativeLanguageEngine langEngine;
    late DirectedPairMatrixEngine matrixEngine;
    late OfflinePackDispatcher dispatcher;

    setUp(() {
      langEngine = DeclarativeLanguageEngine()..initialize();
      WesternLanguagesRegistry.registerWesternProfiles(langEngine);
      matrixEngine = DirectedPairMatrixEngine();
      dispatcher = OfflinePackDispatcher(
        languageEngine: langEngine,
        matrixEngine: matrixEngine,
      );
    });

    tearDown(() {
      dispatcher.dispose();
    });

    test('Hot-swaps from ar_de to en_es in-memory without error', () async {
      expect(dispatcher.hasActivePair, isFalse);

      final success1 = await dispatcher.switchPair(sourceIso: 'ar', targetIso: 'de');
      expect(success1, isTrue);
      expect(dispatcher.currentState!.pairId, equals('ar_de'));
      expect(dispatcher.currentState!.pairConfig.requiresBidiFlipping, isTrue);

      // Instant hot-swap to English -> Spanish
      final success2 = await dispatcher.switchPair(sourceIso: 'en', targetIso: 'es');
      expect(success2, isTrue);
      expect(dispatcher.currentState!.pairId, equals('en_es'));
      expect(dispatcher.currentState!.pairConfig.requiresBidiFlipping, isFalse);
    });

    test('Rejects non-existent language pair gracefully', () async {
      final success = await dispatcher.switchPair(sourceIso: 'non_existent', targetIso: 'de');
      expect(success, isFalse);
    });
  });
}
