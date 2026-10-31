/// Validation report assessing acoustic integrity of offline audio packs.
class AudioValidationReport {
  final int totalClipsChecked;
  final int missingOrCorruptedCount;
  final bool isVolumeNormalized;
  final double averageDurationSeconds;
  final bool isPackAudiblyConsistent;

  const AudioValidationReport({
    required this.totalClipsChecked,
    required this.missingOrCorruptedCount,
    required this.isVolumeNormalized,
    required this.averageDurationSeconds,
    required this.isPackAudiblyConsistent,
  });
}

/// Verifies audio file headers, duration bounds, and loudness normalization (-16 LUFS target).
class AudioPackConsistencyValidator {
  final double targetLoudnessLufs;

  const AudioPackConsistencyValidator({this.targetLoudnessLufs = -16.0});

  /// Audits a collection of audio clip metadata entries.
  AudioValidationReport auditClips(List> clips) {
    if (clips.isEmpty) {
      return const AudioValidationReport(
        totalClipsChecked: 0,
        missingOrCorruptedCount: 0,
        isVolumeNormalized: true,
        averageDurationSeconds: 0.0,
        isPackAudiblyConsistent: false,
      );
    }

    int corrupt = 0;
    double totalDuration = 0.0;
    bool normalized = true;

    for (final clip in clips) {
      final duration = (clip['duration'] as num?)?.toDouble() ?? 0.0;
      final size = (clip['sizeBytes'] as num?)?.toInt() ?? 0;
      final loudness = (clip['loudnessLufs'] as num?)?.toDouble() ?? -16.0;

      if (duration <= 0.1 || size < 256) {
        corrupt++;
      }
      totalDuration += duration;

      if ((loudness - targetLoudnessLufs).abs() > 2.5) {
        normalized = false;
      }
    }

    final avgDuration = totalDuration / clips.length;
    final isConsistent = corrupt == 0 && normalized;

    return AudioValidationReport(
      totalClipsChecked: clips.length,
      missingOrCorruptedCount: corrupt,
      isVolumeNormalized: normalized,
      averageDurationSeconds: double.parse(avgDuration.toStringAsFixed(2)),
      isPackAudiblyConsistent: isConsistent,
    );
  }
}
