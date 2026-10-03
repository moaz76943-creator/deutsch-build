enum MutationOperation { add, modify, delete }

enum ConflictAction {
  autoMerge,
  noOp,
  rebaseRequired,
  manualResolution,
}

final class AgentMessage {
  AgentMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.topic,
    required Map<String, String> payload,
    required this.createdAt,
  }) : payload = Map<String, String>.unmodifiable(payload);

  final String id;
  final String senderId;
  final String recipientId;
  final String topic;
  final Map<String, String> payload;
  final DateTime createdAt;
}

final class BranchMutation {
  const BranchMutation({
    required this.path,
    required this.operation,
    required this.contentFingerprint,
  });

  final String path;
  final MutationOperation operation;
  final String contentFingerprint;
}

final class BranchChangeSet {
  const BranchChangeSet({
    required this.branch,
    required this.ownerId,
    required this.baseSha,
    required this.headSha,
    required this.mutations,
  });

  final String branch;
  final String ownerId;
  final String baseSha;
  final String headSha;
  final List<BranchMutation> mutations;
}

final class ConflictDecision {
  const ConflictDecision({
    required this.action,
    required this.code,
    required this.conflictingPaths,
  });

  final ConflictAction action;
  final String code;
  final List<String> conflictingPaths;

  bool get isSafeToIntegrate =>
      action == ConflictAction.autoMerge || action == ConflictAction.noOp;
}

final class SyncEvaluation {
  const SyncEvaluation({
    required this.decision,
    required this.messageIds,
  });

  final ConflictDecision decision;
  final List<String> messageIds;
}
