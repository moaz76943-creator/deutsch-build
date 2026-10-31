import 'dart:convert';
import 'dart:io';

class PlacementDraft {
  final String pairId;
  final int currentQuestionIndex;
  final Map<int, String> answers;
  final DateTime lastSaved;

  const PlacementDraft({
    required this.pairId,
    required this.currentQuestionIndex,
    required this.answers,
    required this.lastSaved,
  });

  Map<String, dynamic> toJson() => {
        'pair_id': pairId,
        'current_index': currentQuestionIndex,
        'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
        'last_saved': lastSaved.toIso8601String(),
      };

  factory PlacementDraft.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as Map<String, dynamic>? ?? {};
    final parsedAnswers = rawAnswers.map(
      (k, v) => MapEntry(int.tryParse(k) ?? 0, v.toString()),
    );

    return PlacementDraft(
      pairId: json['pair_id'] as String? ?? 'de_ar',
      currentQuestionIndex: json['current_index'] as int? ?? 0,
      answers: parsedAnswers,
      lastSaved: DateTime.tryParse(json['last_saved'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// PlacementDraftStore guarantees Master Constitution Section 09:
/// Placement drafts are saved atomically and never lost if the app terminates mid-test.
class PlacementDraftStore {
  final File draftFile;
  final File tempFile;

  PlacementDraftStore(String storagePath)
      : draftFile = File(storagePath),
        tempFile = File('$storagePath.tmp');

  Future<void> saveDraft(PlacementDraft draft) async {
    final jsonStr = jsonEncode(draft.toJson());
    // Write-then-rename atomic persistence
    await tempFile.writeAsString(jsonStr, flush: true);
    await tempFile.rename(draftFile.path);
  }

  Future<PlacementDraft?> loadDraft() async {
    if (!await draftFile.exists() || (await draftFile.length()) == 0) {
      return null;
    }
    try {
      final content = await draftFile.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      return PlacementDraft.fromJson(decoded);
    } catch (_) {
      return null; // Gracefully handles corrupted draft without crash
    }
  }

  Future<void> clearDraft() async {
    if (await draftFile.exists()) {
      await draftFile.delete();
    }
  }
}
