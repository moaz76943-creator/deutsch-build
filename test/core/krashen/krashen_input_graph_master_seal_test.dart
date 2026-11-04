import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/krashen/krashen_input_graph_master_seal.dart';

void main() {
  group('KrashenInputGraphMasterSeal Suite', () {
    test('Reports the bounded local checks for all 19 components', () async {
      final seal = await KrashenInputGraphMasterSeal.executeFullCertification();

      expect(seal.isBktVerified, isTrue);
      expect(seal.isAffectiveFilterVerified, isTrue);
      expect(seal.isUdEvaluatorVerified, isTrue);
      expect(seal.isScaffolderVerified, isTrue);
      expect(seal.isFsrsVerified, isTrue);
      expect(seal.isLexicalPacerVerified, isTrue);
      expect(seal.isInputVerifierVerified, isTrue);
      expect(seal.isTransferFacilitatorVerified, isTrue);
      expect(seal.isFossilizationVerified, isTrue);
      expect(seal.isNaturalOrderVerified, isTrue);
      expect(seal.isNoticingHighlighterVerified, isTrue);
      expect(seal.isIncidentalTrackerVerified, isTrue);
      expect(seal.isClueInjectorVerified, isTrue);
      expect(seal.isNarrowReadingVerified, isTrue);
      expect(seal.isBimodalSyncVerified, isTrue);
      expect(seal.isIntonationFeedbackVerified, isTrue);
      expect(seal.isSpeechActVerified, isTrue);
      expect(seal.isImplicitGrammarVerified, isTrue);
      expect(seal.isStorySimulatorVerified, isTrue);
    });

    test('Local fixtures cannot certify the production end-to-end pipeline',
        () async {
      final seal = await KrashenInputGraphMasterSeal.executeFullCertification();

      // Smoke fixtures provide no licensed-content or connected-device evidence.
      expect(seal.isEndToEndPipelineVerified, isFalse);
      expect(seal.isPillarFullyCertified, isFalse);
      expect(KrashenInputGraphMasterSeal.sealCertificateId,
          equals('POLYGLOT_KRASHEN_INPUT_GRAPH_V2_MASTER_SEAL_CERTIFIED'));
    });
  });
}
