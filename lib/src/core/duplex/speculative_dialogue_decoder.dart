class SpeculativeDialogueDecoder {
  final Map<String, List<String>> _branchPredictions = {};
  const SpeculativeDialogueDecoder();

  List<String> predictLikelyUserFollowups(String tutorUtterance) {
    return _branchPredictions[tutorUtterance.trim().toLowerCase()] ?? ['نعم', 'لا', 'أعد من فضلك'];
  }
}
