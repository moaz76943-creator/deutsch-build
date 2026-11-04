import 'bayesian_knowledge_tracing_engine_v2.dart';
import 'affective_filter_monitor.dart';
import 'universal_dependency_complexity_evaluator.dart';
import 'dynamic_i_plus_one_scaffolder.dart';
import 'fsrs_v5_spaced_repetition_engine.dart';
import 'lexical_frequency_pacer_zipf.dart';
import 'comprehensible_input_verifier.dart';
import 'cross_lingual_transfer_facilitator.dart';
import 'fossilization_remediation_engine.dart';
import 'natural_order_curriculum_sequencer.dart';
import 'noticing_hypothesis_feature_highlighter.dart';
import 'incidental_vocabulary_tracker.dart';
import 'dynamic_contextual_clue_injector.dart';
import 'narrow_reading_curriculum_generator.dart';
import 'bimodal_input_synchronizer.dart';
import 'speech_intonation_feedback_aligner.dart';
import 'pragmatic_speech_act_classifier.dart';
import 'implicit_grammar_induction_engine.dart';
import 'dynamic_story_world_simulator.dart';

/// Local component self-check results for the Krashen input graph.
///
/// These checks use ephemeral fixtures, not licensed production content or a
/// connected learning pipeline, and cannot certify end-to-end readiness.
class KrashenInputGraphMasterSeal {
  // Legacy identifier retained for callers; its value is not proof of certification.
  static const String sealCertificateId =
      'POLYGLOT_KRASHEN_INPUT_GRAPH_V2_MASTER_SEAL_CERTIFIED';
  static const int totalTasksInPillar = 20; // Tasks 541 to 560
  static const String version = '2.0.0-krashen-graph';

  final bool isBktVerified;
  final bool isAffectiveFilterVerified;
  final bool isUdEvaluatorVerified;
  final bool isScaffolderVerified;
  final bool isFsrsVerified;
  final bool isLexicalPacerVerified;
  final bool isInputVerifierVerified;
  final bool isTransferFacilitatorVerified;
  final bool isFossilizationVerified;
  final bool isNaturalOrderVerified;
  final bool isNoticingHighlighterVerified;
  final bool isIncidentalTrackerVerified;
  final bool isClueInjectorVerified;
  final bool isNarrowReadingVerified;
  final bool isBimodalSyncVerified;
  final bool isIntonationFeedbackVerified;
  final bool isSpeechActVerified;
  final bool isImplicitGrammarVerified;
  final bool isStorySimulatorVerified;
  final bool isEndToEndPipelineVerified;

  const KrashenInputGraphMasterSeal({
    required this.isBktVerified,
    required this.isAffectiveFilterVerified,
    required this.isUdEvaluatorVerified,
    required this.isScaffolderVerified,
    required this.isFsrsVerified,
    required this.isLexicalPacerVerified,
    required this.isInputVerifierVerified,
    required this.isTransferFacilitatorVerified,
    required this.isFossilizationVerified,
    required this.isNaturalOrderVerified,
    required this.isNoticingHighlighterVerified,
    required this.isIncidentalTrackerVerified,
    required this.isClueInjectorVerified,
    required this.isNarrowReadingVerified,
    required this.isBimodalSyncVerified,
    required this.isIntonationFeedbackVerified,
    required this.isSpeechActVerified,
    required this.isImplicitGrammarVerified,
    required this.isStorySimulatorVerified,
    required this.isEndToEndPipelineVerified,
  });

  bool get isPillarFullyCertified =>
      isBktVerified &&
      isAffectiveFilterVerified &&
      isUdEvaluatorVerified &&
      isScaffolderVerified &&
      isFsrsVerified &&
      isLexicalPacerVerified &&
      isInputVerifierVerified &&
      isTransferFacilitatorVerified &&
      isFossilizationVerified &&
      isNaturalOrderVerified &&
      isNoticingHighlighterVerified &&
      isIncidentalTrackerVerified &&
      isClueInjectorVerified &&
      isNarrowReadingVerified &&
      isBimodalSyncVerified &&
      isIntonationFeedbackVerified &&
      isSpeechActVerified &&
      isImplicitGrammarVerified &&
      isStorySimulatorVerified &&
      isEndToEndPipelineVerified;

  /// Runs local smoke checks against the current component APIs.
  ///
  /// The method name is retained for compatibility. Component flags describe
  /// only these bounded checks; end-to-end verification needs real evidence.
  static Future<KrashenInputGraphMasterSeal> executeFullCertification() async {
    // All fixtures remain local to this call and are never production content.
    const bkt = BayesianKnowledgeTracingEngineV2();
    final bktOk = bkt.updateMastery(bkt.pL0, true) > bkt.pL0 &&
        bkt.updateMastery(bkt.pL0, true) > bkt.updateMastery(bkt.pL0, false);

    const aff = AffectiveFilterMonitor();
    final affOk = aff
            .evaluateState(const InteractionMetrics(
              responseLatencyMs: 1000,
              expectedBaselineLatencyMs: 1000,
              hesitationFillerCount: 0,
              consecutiveErrorCount: 0,
              sessionDurationSeconds: 100,
            ))
            .isOptimalReception &&
        !aff
            .evaluateState(const InteractionMetrics(
              responseLatencyMs: 3000,
              expectedBaselineLatencyMs: 1000,
              hesitationFillerCount: 4,
              consecutiveErrorCount: 3,
              sessionDurationSeconds: 2000,
            ))
            .isOptimalReception;

    const ud = UniversalDependencyComplexityEvaluator();
    final udOk = ud.evaluateDepth([0, 1, 2]) == 2 && ud.evaluateDepth([]) == 0;

    const scaff = DynamicIPlusOneScaffolder();
    final scaffOk = scaff.scaffold('ذهب الطالب.', 'ar') ==
        'ذهب الطالب في هدوء وسكينة تامة.';

    const fsrs = FsrsV5SpacedRepetitionEngine();
    final item = fsrs.initializeNewItem('item1', FsrsRating.good, 1000);
    final lapse = fsrs.reviewItem(item, FsrsRating.again, item.dueEpochMs);
    final fsrsOk = item.stability > 0 &&
        item.dueEpochMs > 1000 &&
        lapse.lapses == item.lapses + 1 &&
        lapse.state == CardState.relearning &&
        lapse.stability < item.stability;

    final pacer = LexicalFrequencyPacerZipf();
    pacer.registerRank('كتاب', 100);
    final pacerOk = pacer.getTier('كتاب') == 1 && pacer.getTier('unknown') == 4;

    const verifier = ComprehensibleInputVerifier();
    final verOk = verifier.isComprehensible('سلام عليكم', {'سلام', 'عليكم'}) &&
        !verifier.isComprehensible('سلام عليكم', {'سلام'});

    final trans = CrossLingualTransferFacilitator();
    trans.registerPair(const CrossLingualTransferPair(
      sourceLemma: 'علم',
      targetLemma: 'ilim',
      sourceLang: 'ar',
      targetLang: 'tr',
      type: CrossLingualTransferType.positiveCognateLoan,
      pedagogicalExplanationAr: 'local smoke fixture',
      exampleUsage: 'ilim',
    ));
    final transOk = trans.analyzeTransfer(
              targetWord: 'ilim',
              targetLang: 'tr',
              learnerKnownLanguages: {'ar'},
            ).length ==
            1 &&
        trans.analyzeTransfer(
          targetWord: 'علم',
          targetLang: 'ar',
          learnerKnownLanguages: {'tr'},
        ).isEmpty;

    final foss = FossilizationRemediationEngine();
    for (var i = 0; i < 4; i++) {
      foss.recordMistake('p1');
    }
    final belowFossilizationThreshold = !foss.isFossilized('p1');
    foss.recordMistake('p1');
    final fossOk = belowFossilizationThreshold &&
        foss.isFossilized('p1') &&
        !foss.isFossilized('unseen');

    final ord = NaturalOrderCurriculumSequencer();
    ord.registerPrereq('m1');
    final ordOk = !ord.isAdmissible('m2', {}) && ord.isAdmissible('m2', {'m1'});

    const notic = NoticingHypothesisFeatureHighlighter();
    final highlighted = notic.highlightTargetFeatures(
      sentence: 'ذهب',
      targetMorphemes: ['ذ'],
      grammarRuleTitle: 'r',
    );
    final noticOk = highlighted.spans.length == 1 &&
        highlighted.renderedMarkup == '**ذ**هب' &&
        notic
            .highlightTargetFeatures(
              sentence: 'ذهب',
              targetMorphemes: ['x'],
              grammarRuleTitle: 'r',
            )
            .spans
            .isEmpty;

    final inc = IncidentalVocabularyTracker();
    for (var i = 0; i < 9; i++) {
      inc.recordEncounter('word');
    }
    final belowProductiveThreshold = !inc.isProductiveReady('word');
    inc.recordEncounter('word');
    final incOk = belowProductiveThreshold &&
        inc.isProductiveReady('word') &&
        !inc.isProductiveReady('unseen');

    final clue = DynamicContextualClueInjector();
    clue.registerClue('x', 'c');
    final clueOk = clue.inject('base', 'x') == 'base (c)' &&
        clue.inject('base', 'unknown') == 'base';

    final nr = NarrowReadingCurriculumGenerator();
    nr.registerArticle(const NarrowReadingArticle(
      id: 'a1',
      domain: ThematicDomain.travelAndGeography,
      title: 'local fixture',
      passageText: 'p',
      targetThematicLemmas: ['w'],
      languageCode: 'ar',
    ));
    final cluster = nr.buildCluster(
      domain: ThematicDomain.travelAndGeography,
      languageCode: 'ar',
    );
    final nrOk = cluster.articles.length == 1 &&
        cluster.articles.first.id == 'a1' &&
        nr
            .buildCluster(
              domain: ThematicDomain.travelAndGeography,
              languageCode: 'tr',
            )
            .articles
            .isEmpty;

    const sync =
        BimodalInputSynchronizer(words: ['w', 'x'], timestampsMs: [100, 200]);
    const emptySync = BimodalInputSynchronizer(words: [], timestampsMs: []);
    final syncOk = sync.getActiveIndex(50) == 0 &&
        sync.getActiveIndex(150) == 1 &&
        emptySync.getActiveIndex(50) == null;

    const into = SpeechIntonationFeedbackAligner();
    final intoOk = into.isRisingQuestion([100.0, 150.0]) &&
        !into.isRisingQuestion([150.0, 100.0]) &&
        !into.isRisingQuestion([]);

    const act = PragmaticSpeechActClassifier();
    final actOk = act
                .classifyUtterance(
                  text: 'شكراً',
                  languageCode: 'ar',
                )
                .primaryAct ==
            SpeechActCategory.gratitudeAppreciation &&
        act
                .classifyUtterance(
                  text: 'unmarked fixture',
                  languageCode: 'ar',
                )
                .primaryAct ==
            SpeechActCategory.assertionFact;

    final imp = ImplicitGrammarInductionEngine();
    imp.observe('A', 'B');
    final impOk = imp.frequency('A', 'B') == 1 && imp.frequency('B', 'A') == 0;

    final story = DynamicStoryWorldSimulator();
    story.registerScene('s1', 'local narrative fixture');
    final storyOk = story.getScene('s1') == 'local narrative fixture' &&
        story.getScene('missing') == null;

    return KrashenInputGraphMasterSeal(
      isBktVerified: bktOk,
      isAffectiveFilterVerified: affOk,
      isUdEvaluatorVerified: udOk,
      isScaffolderVerified: scaffOk,
      isFsrsVerified: fsrsOk,
      isLexicalPacerVerified: pacerOk,
      isInputVerifierVerified: verOk,
      isTransferFacilitatorVerified: transOk,
      isFossilizationVerified: fossOk,
      isNaturalOrderVerified: ordOk,
      isNoticingHighlighterVerified: noticOk,
      isIncidentalTrackerVerified: incOk,
      isClueInjectorVerified: clueOk,
      isNarrowReadingVerified: nrOk,
      isBimodalSyncVerified: syncOk,
      isIntonationFeedbackVerified: intoOk,
      isSpeechActVerified: actOk,
      isImplicitGrammarVerified: impOk,
      isStorySimulatorVerified: storyOk,
      // No licensed content, connected pipeline, or device evidence is checked.
      isEndToEndPipelineVerified: false,
    );
  }
}
