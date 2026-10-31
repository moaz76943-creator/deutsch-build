enum SuffixCategory {
  nounSuffix,
  adjectiveSuffix,
  verbPrefixDerivation,
}

final class WordDerivationItem {
  const WordDerivationItem({
    required this.id,
    required this.rootWord,
    required this.rootWordType,
    required this.suffix,
    required this.derivedWord,
    required this.category,
    required this.arabicMeaning,
    required this.semanticShiftAr,
    required this.exercisePromptAr,
  });

  final String id;
  final String rootWord;
  final String rootWordType;
  final String suffix;
  final String derivedWord;
  final SuffixCategory category;
  final String arabicMeaning;
  final String semanticShiftAr;
  final String exercisePromptAr;

  String? get article => articleForAffix(
        suffix,
        category: category,
      );

  bool get isPrefixDerivation =>
      category == SuffixCategory.verbPrefixDerivation;

  String composeAttempt(String selectedAffix) {
    final normalized = normalizeAffix(selectedAffix);
    if (normalized == normalizeAffix(suffix)) return derivedWord;

    if (normalized.endsWith('-')) {
      final prefix = normalized.substring(0, normalized.length - 1);
      return '$prefix$rootWord';
    }

    final ending =
        normalized.startsWith('-') ? normalized.substring(1) : normalized;
    return '$rootWord$ending';
  }

  static String? articleForAffix(
    String affix, {
    required SuffixCategory category,
  }) {
    if (category != SuffixCategory.nounSuffix) return null;

    return switch (normalizeAffix(affix)) {
      '-ung' || '-heit' || '-keit' || '-schaft' => 'die',
      _ => null,
    };
  }

  static String normalizeAffix(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    if (trimmed.endsWith('-')) return trimmed;
    return trimmed.startsWith('-') ? trimmed : '-$trimmed';
  }
}
