import 'collaboration_models.dart';

final class ConflictResolutionEngine {
  const ConflictResolutionEngine();

  ConflictDecision resolve({
    required BranchChangeSet left,
    required BranchChangeSet right,
  }) {
    if (!_valid(left) || !_valid(right)) {
      return const ConflictDecision(
        action: ConflictAction.manualResolution,
        code: 'invalid_change_set',
        conflictingPaths: <String>[],
      );
    }

    if (left.headSha == right.headSha && left.branch == right.branch) {
      return const ConflictDecision(
        action: ConflictAction.noOp,
        code: 'same_branch_head',
        conflictingPaths: <String>[],
      );
    }

    final leftByPath = <String, BranchMutation>{
      for (final mutation in left.mutations) mutation.path: mutation,
    };
    final rightByPath = <String, BranchMutation>{
      for (final mutation in right.mutations) mutation.path: mutation,
    };

    final overlaps = leftByPath.keys
        .where(rightByPath.containsKey)
        .toList(growable: false)
      ..sort();

    if (overlaps.isEmpty) {
      return const ConflictDecision(
        action: ConflictAction.autoMerge,
        code: 'disjoint_scopes',
        conflictingPaths: <String>[],
      );
    }

    final divergent = <String>[];
    var allIdentical = true;
    for (final path in overlaps) {
      final a = leftByPath[path]!;
      final b = rightByPath[path]!;
      final sameMutation = a.operation == b.operation &&
          a.contentFingerprint == b.contentFingerprint;
      if (!sameMutation) {
        allIdentical = false;
        divergent.add(path);
      }
    }

    if (allIdentical) {
      final leftOnly = leftByPath.keys.where((path) => !rightByPath.containsKey(path));
      final rightOnly =
          rightByPath.keys.where((path) => !leftByPath.containsKey(path));
      if (leftOnly.isEmpty && rightOnly.isEmpty) {
        return ConflictDecision(
          action: ConflictAction.noOp,
          code: 'identical_mutations',
          conflictingPaths: List<String>.unmodifiable(overlaps),
        );
      }
      return const ConflictDecision(
        action: ConflictAction.autoMerge,
        code: 'identical_overlap_with_disjoint_changes',
        conflictingPaths: <String>[],
      );
    }

    if (left.baseSha != right.baseSha) {
      return ConflictDecision(
        action: ConflictAction.rebaseRequired,
        code: 'divergent_base_with_overlap',
        conflictingPaths: List<String>.unmodifiable(divergent),
      );
    }

    return ConflictDecision(
      action: ConflictAction.manualResolution,
      code: left.ownerId == right.ownerId
          ? 'same_owner_divergent_content'
          : 'cross_owner_divergent_content',
      conflictingPaths: List<String>.unmodifiable(divergent),
    );
  }

  static bool _valid(BranchChangeSet set) {
    if (set.branch.trim().isEmpty ||
        set.ownerId.trim().isEmpty ||
        set.baseSha.trim().isEmpty ||
        set.headSha.trim().isEmpty) {
      return false;
    }
    final seen = <String>{};
    for (final mutation in set.mutations) {
      if (mutation.path.trim().isEmpty ||
          mutation.contentFingerprint.trim().isEmpty ||
          !seen.add(mutation.path)) {
        return false;
      }
    }
    return true;
  }
}
