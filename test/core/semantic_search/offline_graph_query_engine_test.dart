import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/offline_graph_query_engine.dart';

void main() {
  group('OfflineGraphQueryEngine Unit Tests (N055)', () {
    final engine = OfflineGraphQueryEngine();

    setUp(() {
      engine.addEdges([
        const GraphEdge(sourceNode: 'helfen', relation: 'GOVERNS_CASE', targetNode: 'Dative'),
        const GraphEdge(sourceNode: 'danken', relation: 'GOVERNS_CASE', targetNode: 'Dative'),
        const GraphEdge(sourceNode: 'Dative', relation: 'HAS_ARTICLE_MASC', targetNode: 'dem'),
        const GraphEdge(sourceNode: 'Dative', relation: 'HAS_PRONOUN_1ST', targetNode: 'mir'),
      ]);
    });

    test('Queries 1-hop outgoing and incoming edges accurately', () {
      final cases = engine.queryTargets(source: 'helfen', relation: 'GOVERNS_CASE');
      expect(cases, equals(['Dative']));

      final verbs = engine.querySources(target: 'Dative', relation: 'GOVERNS_CASE');
      expect(verbs, contains('helfen'));
      expect(verbs, contains('danken'));
    });

    test('Traverses 2-hop graph relation: verb -> case -> pronoun', () {
      final pronouns = engine.queryTwoHop(
        source: 'helfen',
        firstRelation: 'GOVERNS_CASE',
        secondRelation: 'HAS_PRONOUN_1ST',
      );

      expect(pronouns, equals(['mir']));
    });

    test('Returns empty list for non-existent pathways', () {
      expect(engine.queryTargets(source: 'rennen', relation: 'GOVERNS_CASE'), isEmpty);
    });
  });
}
