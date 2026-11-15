import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/conversational_memory_graph.dart';

void main() {
  group('ConversationalMemoryGraph Unit Tests (N071)', () {
    final memory = ConversationalMemoryGraph();

    test('Remembers learner hobby and profession and builds personal prompt context', () {
      memory.rememberFact(category: 'hobby', key: 'sports', value: 'Fußball spielen');
      memory.rememberFact(category: 'profession', key: 'job', value: 'Softwareentwickler');

      expect(memory.totalFacts, equals(2));

      final snippet = memory.buildPersonalizationSnippet();
      expect(snippet, contains('hobby: Fußball spielen'));
      expect(snippet, contains('profession: Softwareentwickler'));

      final relevant = memory.getRelevantFacts('fußball');
      expect(relevant.length, equals(1));
      expect(relevant.first.factValue, equals('Fußball spielen'));
    });

    test('Repeated facts increment confidence score', () {
      memory.rememberFact(category: 'travel', key: 'destination', value: 'München');
      memory.rememberFact(category: 'travel', key: 'destination', value: 'München');

      final facts = memory.getRelevantFacts('münchen');
      expect(facts.first.confidenceScore, equals(2));
    });

    test('Empty memory returns empty snippet', () {
      final empty = ConversationalMemoryGraph();
      expect(empty.buildPersonalizationSnippet(), isEmpty);
    });
  });
}
