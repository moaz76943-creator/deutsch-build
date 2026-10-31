import 'agent_messaging_system.dart';
import 'collaboration_models.dart';
import 'conflict_resolution_engine.dart';

final class AiSyncHub {
  AiSyncHub({
    AgentMessagingSystem? messaging,
    ConflictResolutionEngine conflictEngine =
        const ConflictResolutionEngine(),
  })  : messaging = messaging ?? AgentMessagingSystem(),
        _conflictEngine = conflictEngine;

  final AgentMessagingSystem messaging;
  final ConflictResolutionEngine _conflictEngine;

  SyncEvaluation evaluatePair({
    required BranchChangeSet left,
    required BranchChangeSet right,
    required String coordinatorId,
    required int sequence,
  }) {
    final decision = _conflictEngine.resolve(left: left, right: right);
    final messageIds = <String>[];

    for (final changeSet in <BranchChangeSet>[left, right]) {
      final messageId =
          'sync:$sequence:${changeSet.ownerId}:${left.headSha}:${right.headSha}';
      final sent = messaging.send(
        AgentMessage(
          id: messageId,
          senderId: coordinatorId,
          recipientId: changeSet.ownerId,
          topic: 'sync-decision',
          payload: <String, String>{
            'action': decision.action.name,
            'code': decision.code,
            'left_branch': left.branch,
            'right_branch': right.branch,
            'left_head': left.headSha,
            'right_head': right.headSha,
            'conflicting_paths': decision.conflictingPaths.join(','),
          },
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            sequence,
            isUtc: true,
          ),
        ),
      );
      if (sent) messageIds.add(messageId);
    }

    return SyncEvaluation(
      decision: decision,
      messageIds: List<String>.unmodifiable(messageIds),
    );
  }

  bool handoff({
    required String id,
    required String fromAgent,
    required String toAgent,
    required String scope,
    required String headSha,
    required int sequence,
  }) =>
      messaging.send(
        AgentMessage(
          id: id,
          senderId: fromAgent,
          recipientId: toAgent,
          topic: 'handoff',
          payload: <String, String>{
            'scope': scope,
            'head_sha': headSha,
          },
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            sequence,
            isUtc: true,
          ),
        ),
      );
}
