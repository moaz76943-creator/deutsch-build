import 'tekamolo_engine.dart';
import 'adjective_declension_engine.dart';
import 'mittelfeld_order_engine.dart';
import 'modalpartikeln_engine.dart';
import 'fvg_engine.dart';
import 'konjunktiv_ii_engine.dart';
import 'passiv_engine.dart';
import 'epistemic_modal_engine.dart';
import 'pronominal_adverb_engine.dart';
import 'n_declension_engine.dart';
import 'prepositional_valency_engine.dart';
import 'relative_clause_engine.dart';
import 'participial_attribute_engine.dart';
import 'connectors_engine.dart';
import 'irregular_verb_engine.dart';
import 'prefix_verb_engine.dart';
import 'infinitiv_mit_zu_engine.dart';
import 'cefr_difficulty_calculator_engine.dart';
import 'compound_splitter_engine.dart';

class SentenceAnalysisReport {
  final String originalText;
  final CefrComplexityMetrics cefrMetrics;
  final List<CompoundDecomposition> decomposedCompounds;
  final List<String> linguisticNotes;

  const SentenceAnalysisReport({
    required this.originalText,
    required this.cefrMetrics,
    required this.decomposedCompounds,
    required this.linguisticNotes,
  });
}

/// Master Unified Facade coordinating all 19 offline German linguistic engines.
/// Adheres strictly to Chapter 8.3: thread-safe, immutable transfer objects, zero UI lag.
class LinguisticsCoordinator {
  final TeKaMoLoEngine tekamolo = TeKaMoLoEngine();
  final AdjectiveDeclensionEngine adjectives = AdjectiveDeclensionEngine();
  final MittelfeldOrderEngine mittelfeld = MittelfeldOrderEngine();
  final ModalpartikelnEngine modalpartikeln = ModalpartikelnEngine();
  final FunktionsverbgefuegeEngine fvg = FunktionsverbgefuegeEngine();
  final KonjunktivIiEngine konjunktivIi = KonjunktivIiEngine();
  final PassivAndPassiversatzEngine passiv = PassivAndPassiversatzEngine();
  final EpistemicModalEngine epistemic = EpistemicModalEngine();
  final PronominaladverbienEngine pronominal = PronominaladverbienEngine();
  final NDeklinationEngine nDeclension = NDeklinationEngine();
  final PrepositionalValencyEngine valency = PrepositionalValencyEngine();
  final RelativeClauseEngine relativeClause = RelativeClauseEngine();
  final ParticipialAttributeEngine participial = ParticipialAttributeEngine();
  final KonnektorenSatzverbindungEngine connectors = KonnektorenSatzverbindungEngine();
  final IrregularVerbEngine irregularVerbs = IrregularVerbEngine();
  final PrefixVerbEngine prefixVerbs = PrefixVerbEngine();
  final InfinitivMitZuEngine infinitivZu = InfinitivMitZuEngine();
  final CefrDifficultyCalculatorEngine cefr = CefrDifficultyCalculatorEngine();
  final CharSplitCompoundEngine compoundSplitter = CharSplitCompoundEngine();

  /// تحليل شامل فوري وموحد لأي جملة أو نص ألماني
  SentenceAnalysisReport analyze(String text) {
    // 1. تقييم مستوى الصعوبة ومؤشرات CEFR
    final cefrResult = cefr.analyze(text);

    // 2. تجزئة الكلمات المركبة الطويلة في النص
    final tokens = text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final compounds = <CompoundDecomposition>[];
    final notes = <String>[];

    for (final token in tokens) {
      final clean = token.replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜß]'), '');
      final decomp = compoundSplitter.split(clean);
      if (decomp != null) compounds.add(decomp);

      // فحص أسماء N-Deklination
      if (nDeclension.isNDeclension(clean)) {
        notes.add('تم رصد اسم مذكر ضعيف (N-Deklination): $clean');
      }

      // فحص أدوات الخطاب التداولية
      for (final p in Modalparticle.values) {
        if (p.name == clean.toLowerCase()) {
          final exp = modalpartikeln.explain(p);
          if (exp != null) notes.add('أداة خطاب (${exp.particle.name}): ${exp.arabicGloss}');
        }
      }
    }

    return SentenceAnalysisReport(
      originalText: text,
      cefrMetrics: cefrResult,
      decomposedCompounds: compounds,
      linguisticNotes: notes,
    );
  }
}
