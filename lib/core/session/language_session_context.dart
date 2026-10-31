/// سياق جلسة لغوية ثابت غير قابل للتعديل يمنع تداخل الحالات عند التبديل
class LanguageSessionContext {
  final String userLocale;
  final String sourceLocale;
  final String targetLocale;
  final int pairEpoch;
  final DateTime createdAt;

  const LanguageSessionContext({
    required this.userLocale,
    required this.sourceLocale,
    required this.targetLocale,
    required this.pairEpoch,
    required this.createdAt,
  });

  bool isValidFor(int currentEpoch) => pairEpoch == currentEpoch;

  LanguageSessionContext copyWithNextEpoch({
    String? targetLocale,
  }) {
    return LanguageSessionContext(
      userLocale: userLocale,
      sourceLocale: sourceLocale,
      targetLocale: targetLocale ?? this.targetLocale,
      pairEpoch: pairEpoch + 1,
      createdAt: DateTime.now(),
    );
  }
}
