import 'package:test/test.dart';
import 'package:deutsch_build/src/core/krashen/krashen_input_graph_master_seal.dart';

void main() {
  group('KrashenInputGraphMasterSeal Suite', () {
    test('Certifies all 20 subsystems of Volume 2 - Pillar 3 under Master Seal', () async {
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
      expect(seal.isEndToEndPipelineVerified, isTrue);

      expect(seal.isPillarFullyCertified, isTrue);
      expect(KrashenInputGraphMasterSeal.sealCertificateId, equals('POLYGLOT_KRASHEN_INPUT_GRAPH_V2_MASTER_SEAL_CERTIFIED'));
    });
  });
}
