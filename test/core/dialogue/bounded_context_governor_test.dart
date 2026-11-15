import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/local_llm_engine.dart';
import 'package:deutsch_build/src/core/dialogue/bounded_context_governor.dart';

void main() {
  group('BoundedContextGovernor Tests', () {
    const governor = BoundedContextGovernor(
      budget: ContextMemoryBudget(maxTokens: 100, maxTurns: 5, maxKvCacheMb: 16.0),
    );

    test('KV-Cache footprint accurately calculated under 10MB for 512 tokens', () {
      final mb = governor.calculateKvCacheMemoryMb(activeTokens: 512);
      expect(mb, lessThan(10.0));
      expect(mb, greaterThan(0.0));
    });

    test('Prunes long conversational backlog into pinned system prompt and recent turns', () {
      final longHistory = [
        DialogueMessage(role: DialogueRole.system, content: 'Act as a cafe waiter.'),
        for (int i = 0; i < 15; i++) ...[
          DialogueMessage(role: DialogueRole.user, content: 'Message from user turn $i with detailed sentences.'),
          DialogueMessage(role: DialogueRole.assistant, content: 'Response from waiter turn $i with polite remarks.'),
        ]
      ];

      final pruned = governor.pruneContext(longHistory);

      expect(pruned.length, lessThanOrEqualTo(6));
      expect(pruned.first.content, equals('Act as a cafe waiter.'));
      expect(pruned.any((m) => m.content.contains('[Recap:')), isTrue);
      expect(pruned.last.content, equals(longHistory.last.content));
    });
  });
}
