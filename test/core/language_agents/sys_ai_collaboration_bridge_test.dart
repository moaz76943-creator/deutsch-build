import 'package:deutsch_bilarabi/core/language_agents/sys_ai_collaboration_bridge/agent_messaging_system.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_ai_collaboration_bridge/ai_sync_hub.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_ai_collaboration_bridge/collaboration_models.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_ai_collaboration_bridge/conflict_resolution_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messaging system deduplicates ids and preserves mailbox order', () {
    final bus = AgentMessagingSystem();

    final first = AgentMessage(
      id: 'm1',
      senderId: 'master',
      recipientId: 'worker-a',
      topic: 'claim',
      payload: const <String, String>{'scope': 'lib/a'},
      createdAt: DateTime.utc(2026, 10, 4, 0, 0),
    );
    final second = AgentMessage(
      id: 'm2',
      senderId: 'master',
      recipientId: 'worker-a',
      topic: 'handoff',
      payload: const <String, String>{'sha': 'abc'},
      createdAt: DateTime.utc(2026, 10, 4, 0, 1),
    );

    expect(bus.send(first), isTrue);
    expect(bus.send(first), isFalse);
    expect(bus.send(second), isTrue);
    expect(bus.pendingFor('worker-a').map((m) => m.id), <String>['m1', 'm2']);

    expect(bus.acknowledge(recipientId: 'worker-a', messageId: 'm1'), isTrue);
    expect(bus.pendingFor('worker-a').map((m) => m.id), <String>['m2']);
  });

  test('conflict engine auto-merges disjoint mutations', () {
    const engine = ConflictResolutionEngine();
    const left = BranchChangeSet(
      branch: 'feature/a',
      ownerId: 'agent-a',
      baseSha: 'base',
      headSha: 'head-a',
      mutations: <BranchMutation>[
        BranchMutation(
          path: 'lib/a.dart',
          operation: MutationOperation.modify,
          contentFingerprint: 'hash-a',
        ),
      ],
    );
    const right = BranchChangeSet(
      branch: 'feature/b',
      ownerId: 'agent-b',
      baseSha: 'base',
      headSha: 'head-b',
      mutations: <BranchMutation>[
        BranchMutation(
          path: 'lib/b.dart',
          operation: MutationOperation.modify,
          contentFingerprint: 'hash-b',
        ),
      ],
    );

    final decision = engine.resolve(left: left, right: right);
    expect(decision.action, ConflictAction.autoMerge);
    expect(decision.conflictingPaths, isEmpty);
  });

  test('conflict engine blocks divergent writes on the same path', () {
    const engine = ConflictResolutionEngine();
    const left = BranchChangeSet(
      branch: 'feature/a',
      ownerId: 'agent-a',
      baseSha: 'base',
      headSha: 'head-a',
      mutations: <BranchMutation>[
        BranchMutation(
          path: 'lib/shared.dart',
          operation: MutationOperation.modify,
          contentFingerprint: 'left',
        ),
      ],
    );
    const right = BranchChangeSet(
      branch: 'feature/b',
      ownerId: 'agent-b',
      baseSha: 'base',
      headSha: 'head-b',
      mutations: <BranchMutation>[
        BranchMutation(
          path: 'lib/shared.dart',
          operation: MutationOperation.modify,
          contentFingerprint: 'right',
        ),
      ],
    );

    final decision = engine.resolve(left: left, right: right);
    expect(decision.action, ConflictAction.manualResolution);
    expect(decision.conflictingPaths, <String>['lib/shared.dart']);
  });

  test('sync hub emits a deterministic resolution message', () {
    final hub = AiSyncHub();
    const left = BranchChangeSet(
      branch: 'feature/a',
      ownerId: 'agent-a',
      baseSha: 'base',
      headSha: 'head-a',
      mutations: <BranchMutation>[
        BranchMutation(
          path: 'lib/a.dart',
          operation: MutationOperation.add,
          contentFingerprint: 'a',
        ),
      ],
    );
    const right = BranchChangeSet(
      branch: 'feature/b',
      ownerId: 'agent-b',
      baseSha: 'base',
      headSha: 'head-b',
      mutations: <BranchMutation>[
        BranchMutation(
          path: 'lib/b.dart',
          operation: MutationOperation.add,
          contentFingerprint: 'b',
        ),
      ],
    );

    final result = hub.evaluatePair(
      left: left,
      right: right,
      coordinatorId: 'master',
      sequence: 7,
    );

    expect(result.decision.action, ConflictAction.autoMerge);
    expect(hub.messaging.pendingFor('agent-a'), hasLength(1));
    expect(hub.messaging.pendingFor('agent-b'), hasLength(1));
    expect(hub.messaging.pendingFor('agent-a').single.topic, 'sync-decision');
  });
}
