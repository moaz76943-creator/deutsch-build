import 'declarative_language_engine.dart';
import 'directed_pair_matrix_engine.dart';
import 'offline_pack_dispatcher.dart';
import 'western_languages_registry.dart';
import 'romance_germanic_languages_registry.dart';
import 'slavic_languages_registry.dart';
import 'near_eastern_languages_registry.dart';
import 'east_asian_languages_registry.dart';
import '../typography/universal_script_shaper.dart';

/// Comprehensive end-to-end evaluation report for cross-pair matrix transitions.
class CrossPairBenchmarkResult {
  final int totalPairsTested;
  final int successfulTransitions;
  final Duration totalLatency;
  final double averageLatencyMs;
  final bool allBidiTransitionsValid;

  const CrossPairBenchmarkResult({
    required this.totalPairsTested,
    required this.successfulTransitions,
    required this.totalLatency,
    required this.averageLatencyMs,
    required this.allBidiTransitionsValid,
  });

  bool get isPassed =>
      totalPairsTested > 0 &&
      successfulTransitions == totalPairsTested &&
      averageLatencyMs < 50.0 &&
      allBidiTransitionsValid;
}

/// Evaluates language matrix integrity, bi-directional script transitions, and hot-swapping SLA.
class CrossPairE2EHarness {
  final DeclarativeLanguageEngine langEngine;
  final DirectedPairMatrixEngine matrixEngine;
  final OfflinePackDispatcher dispatcher;

  CrossPairE2EHarness({
    required this.langEngine,
    required this.matrixEngine,
    required this.dispatcher,
  });

  /// Factory initializing all regional registries across the 100-language spectrum.
  factory CrossPairE2EHarness.fullPlatform() {
    final langEngine = DeclarativeLanguageEngine()..initialize();
    WesternLanguagesRegistry.registerWesternProfiles(langEngine);
    RomanceGermanicLanguagesRegistry.registerProfiles(langEngine);
    SlavicLanguagesRegistry.registerProfiles(langEngine);
    NearEasternLanguagesRegistry.registerProfiles(langEngine);
    EastAsianLanguagesRegistry.registerProfiles(langEngine);

    final matrixEngine = DirectedPairMatrixEngine();
    final dispatcher = OfflinePackDispatcher(
      languageEngine: langEngine,
      matrixEngine: matrixEngine,
    );

    return CrossPairE2EHarness(
      langEngine: langEngine,
      matrixEngine: matrixEngine,
      dispatcher: dispatcher,
    );
  }

  /// Runs stress benchmark cycling across representative multi-directional pairs.
  Future<CrossPairBenchmarkResult> runBenchmark() async {
    final testPairs = [
      ('ar', 'de'), // RTL to LTR (Arabic -> German)
      ('de', 'ar'), // LTR to RTL (German -> Arabic)
      ('en', 'es'), // LTR to LTR (English -> Spanish)
      ('fr', 'ru'), // Latin to Cyrillic (French -> Russian)
      ('ru', 'uk'), // Cyrillic to Cyrillic (Russian -> Ukrainian)
      ('tr', 'fa'), // Latin Agglutinative to Perso-Arabic SOV (Turkish -> Persian)
      ('ur', 'en'), // Nastaliq RTL to Latin LTR (Urdu -> English)
      ('en', 'ja'), // Latin SVO to CJK SOV (English -> Japanese)
      ('ja', 'zh'), // CJK SOV to CJK Isolating SVO (Japanese -> Chinese)
      ('ko', 'ar'), // Hangul SOV to Arabic RTL VSO (Korean -> Arabic)
    ];

    int successCount = 0;
    bool bidiValid = true;
    final stopwatch = Stopwatch()..start();

    for (final pair in testPairs) {
      final ok = await dispatcher.switchPair(sourceIso: pair.$1, targetIso: pair.$2);
      if (ok) {
        successCount++;
        final state = dispatcher.currentState!;
        final sourceRtl = UniversalScriptShaper.isRtlText(state.sourceLanguage.autonym);
        final targetRtl = UniversalScriptShaper.isRtlText(state.targetLanguage.autonym);
        if (state.pairConfig.requiresBidiFlipping != (sourceRtl != targetRtl)) {
          bidiValid = false;
        }
      }
    }

    stopwatch.stop();

    final avgMs = testPairs.isNotEmpty ? stopwatch.elapsedMilliseconds / testPairs.length : 0.0;

    return CrossPairBenchmarkResult(
      totalPairsTested: testPairs.length,
      successfulTransitions: successCount,
      totalLatency: stopwatch.elapsed,
      averageLatencyMs: avgMs,
      allBidiTransitionsValid: bidiValid,
    );
  }
}
