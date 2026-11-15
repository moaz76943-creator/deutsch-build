import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/lifecycle/feature_readiness_gate.dart';

void main() {
  group('FeatureReadinessGate Capability Tests', () {
    late FeatureReadinessGate gate;

    setUp(() {
      gate = const FeatureReadinessGate({
        'de_ar': PairCapabilities(
          pairId: 'de_ar',
          hasVocabulary: true,
          hasAudioPronunciation: true,
          hasGrammarModules: true,
          hasPlacementAssessment: true,
          hasSpacedRepetition: true,
        ),
        'es_ar': PairCapabilities(
          pairId: 'es_ar',
          hasVocabulary: true,
          hasAudioPronunciation: false, // Text-only mode
          hasGrammarModules: false,
          hasPlacementAssessment: false,
          hasSpacedRepetition: true,
        ),
      });
    });

    test('Accurately reports all available features for fully provisioned pairs', () {
      expect(gate.isFeatureAvailable('de_ar', 'audio'), isTrue);
      expect(gate.isFeatureAvailable('de_ar', 'grammar'), isTrue);
      expect(gate.isFeatureAvailable('de_ar', 'placement'), isTrue);
      expect(gate.isFeatureAvailable('de_ar', 'srs'), isTrue);
    });

    test('Gracefully disables missing optional features without throwing', () {
      // Spanish-Arabic audio is not downloaded yet
      expect(gate.isFeatureAvailable('es_ar', 'audio'), isFalse);
      expect(gate.isFeatureAvailable('es_ar', 'grammar'), isFalse);

      // Core vocabulary and SRS remain functional
      expect(gate.isFeatureAvailable('es_ar', 'vocabulary'), isTrue);
      expect(gate.isFeatureAvailable('es_ar', 'srs'), isTrue);
    });

    test('Unknown language pairs default safely to offline vocabulary and SRS', () {
      expect(gate.isFeatureAvailable('tr_ar', 'vocabulary'), isTrue);
      expect(gate.isFeatureAvailable('tr_ar', 'srs'), isTrue);
      expect(gate.isFeatureAvailable('tr_ar', 'audio'), isFalse);
    });
  });
}
