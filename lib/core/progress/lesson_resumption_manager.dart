import 'dart:convert';
import 'dart:io';

class LessonCheckpoint {
  final String pairId;
  final String lessonId;
  final int currentStepIndex;
  final int totalSteps;
  final Map<String, dynamic> stepState;
  final DateTime updatedAt;

  const LessonCheckpoint({
    required this.pairId,
    required this.lessonId,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.stepState,
    required this.updatedAt,
  });

  bool get isCompleted => currentStepIndex >= totalSteps;

  Map<String, dynamic> toJson() => {
        'pair_id': pairId,
        'lesson_id': lessonId,
        'current_step_index': currentStepIndex,
        'total_steps': totalSteps,
        'step_state': stepState,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory LessonCheckpoint.fromJson(Map<String, dynamic> json) {
    return LessonCheckpoint(
      pairId: json['pair_id'] as String? ?? 'de_ar',
      lessonId: json['lesson_id'] as String? ?? '',
      currentStepIndex: json['current_step_index'] as int? ?? 0,
      totalSteps: json['total_steps'] as int? ?? 1,
      stepState: (json['step_state'] as Map<String, dynamic>?) ?? {},
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// LessonResumptionManager - Master Constitution Section 07 Compliant:
/// Preserves exact lesson progress across unexpected app terminations or backgrounding.
class LessonResumptionManager {
  final File checkpointFile;
  final File tempFile;

  LessonResumptionManager(String storagePath)
      : checkpointFile = File(storagePath),
        tempFile = File('$storagePath.tmp');

  Future<void> recordCheckpoint(LessonCheckpoint checkpoint) async {
    final payload = jsonEncode(checkpoint.toJson());
    await tempFile.writeAsString(payload, flush: true);
    await tempFile.rename(checkpointFile.path);
  }

  Future<LessonCheckpoint?> getActiveCheckpoint(String expectedPairId) async {
    if (!await checkpointFile.exists() || (await checkpointFile.length()) == 0) {
      return null;
    }
    try {
      final content = await checkpointFile.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final checkpoint = LessonCheckpoint.fromJson(decoded);

      if (checkpoint.pairId != expectedPairId || checkpoint.isCompleted) {
        return null;
      }
      return checkpoint;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCompletedLesson() async {
    if (await checkpointFile.exists()) {
      await checkpointFile.delete();
    }
  }
}
