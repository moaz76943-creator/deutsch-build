import '../core/content_contract.dart';
import '../core/srs_facets.dart';
import '../models/grammar_microscope.dart';
import '../models/learner.dart';
import 'grammar_hub_service.dart';

final class GrammarMicroscopeSnapshot {
  const GrammarMicroscopeSnapshot({
    required this.topic,
    required this.rules,
    required this.linkedFacets,
    required this.facetEvidence,
    required this.weakItems,
  });

  final GrammarTopic topic;
  final List<GrammarRuleDetail> rules;
  final List<ReviewFacetType> linkedFacets;
  final List<GrammarFacetEvidence> facetEvidence;
  final List<GrammarEvidenceItem> weakItems;

  bool get hasPersonalEvidence => facetEvidence.isNotEmpty;
}

final class GrammarMicroscopeService {
  const GrammarMicroscopeService(this.repository);

  final GrammarHubRepository repository;

  Future<GrammarMicroscopeSnapshot?> load({
    required String topicId,
    required LearnerState state,
    required Iterable<LearningContent> corpus,
  }) async {
    final safeTopicId = topicId.trim();
    if (safeTopicId.isEmpty || safeTopicId.length > 160) return null;

    final topic = await repository.getTopicDetail(safeTopicId);
    if (topic == null) return null;

    List<GrammarRuleDetail> rules = const <GrammarRuleDetail>[];
    final source = repository;
    if (source is GrammarMicroscopeRepository) {
      rules = await (source as GrammarMicroscopeRepository).getRulesForTopic(
        safeTopicId,
      );
    }

    final linkedFacets = _linkedFacets(topic, rules);
    final evidence = _facetEvidence(state, linkedFacets);
    final weakItems = _weakItems(
      state: state,
      linkedFacets: linkedFacets,
      corpus: corpus,
    );

    return GrammarMicroscopeSnapshot(
      topic: topic,
      rules: List<GrammarRuleDetail>.unmodifiable(rules),
      linkedFacets: List<ReviewFacetType>.unmodifiable(linkedFacets),
      facetEvidence: List<GrammarFacetEvidence>.unmodifiable(evidence),
      weakItems: List<GrammarEvidenceItem>.unmodifiable(weakItems),
    );
  }

  static List<ReviewFacetType> _linkedFacets(
    GrammarTopic topic,
    List<GrammarRuleDetail> rules,
  ) {
    final haystack = <String>[
      topic.id,
      topic.titleDe,
      for (final rule in rules) rule.id,
      for (final rule in rules) rule.title,
    ].join(' ').toLowerCase();

    final facets = <ReviewFacetType>{};

    if (haystack.contains('nominativ') || haystack.contains('artikel')) {
      facets
        ..add(ReviewFacetType.gender)
        ..add(ReviewFacetType.caseForm);
    }
    if (haystack.contains('akkusativ') ||
        haystack.contains('dativ') ||
        haystack.contains('genitiv') ||
        haystack.contains('relativ') ||
        haystack.contains('pronoun')) {
      facets.add(ReviewFacetType.caseForm);
    }
    if (haystack.contains('plural')) {
      facets.add(ReviewFacetType.plural);
    }
    if (haystack.contains('präposition') || haystack.contains('preposition')) {
      facets.add(ReviewFacetType.prepositionCase);
    }
    if (haystack.contains('valenz') || haystack.contains('valency')) {
      facets.add(ReviewFacetType.verbValency);
    }
    if (haystack.contains('trenn') || haystack.contains('separable')) {
      facets.add(ReviewFacetType.separablePrefix);
    }
    if (haystack.contains('perfekt') || haystack.contains('passiv')) {
      facets.add(ReviewFacetType.auxiliary);
    }
    if (haystack.contains('nomen_verb') ||
        haystack.contains('nomen-verb') ||
        haystack.contains('kollok') ||
        haystack.contains('colloc')) {
      facets.add(ReviewFacetType.collocation);
    }
    if (haystack.contains('konjunktiv') ||
        haystack.contains('nominal') ||
        haystack.contains('partizip')) {
      facets.add(ReviewFacetType.production);
    }

    return facets.toList(growable: false);
  }

  static List<GrammarFacetEvidence> _facetEvidence(
    LearnerState state,
    List<ReviewFacetType> linkedFacets,
  ) {
    final result = <GrammarFacetEvidence>[];
    for (final facet in linkedFacets) {
      var cardCount = 0;
      var failures = 0;
      var lapses = 0;
      for (final card in state.reviewCards.values) {
        if (card.facetType != facet) continue;
        final pressure = card.failures * 2 + card.lapses;
        if (pressure <= 0) continue;
        cardCount++;
        failures += card.failures;
        lapses += card.lapses;
      }
      final pressure = failures * 2 + lapses;
      if (pressure <= 0) continue;
      result.add(
        GrammarFacetEvidence(
          facetType: facet,
          cardCount: cardCount,
          failures: failures,
          lapses: lapses,
          pressure: pressure,
        ),
      );
    }
    result.sort((a, b) => b.pressure.compareTo(a.pressure));
    return result;
  }

  static List<GrammarEvidenceItem> _weakItems({
    required LearnerState state,
    required List<ReviewFacetType> linkedFacets,
    required Iterable<LearningContent> corpus,
  }) {
    if (linkedFacets.isEmpty) return const <GrammarEvidenceItem>[];

    final contentById = <String, LearningContent>{
      for (final item in corpus)
        if (item.id.trim().isNotEmpty) item.id: item,
    };
    final items = <GrammarEvidenceItem>[];

    for (final card in state.reviewCards.values) {
      if (!linkedFacets.contains(card.facetType)) continue;
      final pressure = card.failures * 2 + card.lapses;
      if (pressure <= 0) continue;
      final content = contentById[card.itemId];
      if (content == null) continue;
      items.add(
        GrammarEvidenceItem(
          itemId: card.itemId,
          sourceText: content.sourceText,
          translationText: content.translationText,
          facetType: card.facetType,
          failures: card.failures,
          lapses: card.lapses,
          pressure: pressure,
        ),
      );
    }

    items.sort((a, b) {
      final pressure = b.pressure.compareTo(a.pressure);
      if (pressure != 0) return pressure;
      return a.itemId.compareTo(b.itemId);
    });
    return items.take(8).toList(growable: false);
  }
}
