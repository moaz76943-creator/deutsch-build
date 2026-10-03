enum AssemblyIssue {
  instructions,
  tools,
  montageService,
  missingPart,
  wrongScrew,
  transportDamage,
}

final class AssemblyScenario {
  const AssemblyScenario({
    required this.id,
    required this.issue,
    required this.titleDe,
    required this.titleAr,
    required this.german,
    required this.arabic,
    this.keywords = const <String>[],
  });

  final String id;
  final AssemblyIssue issue;
  final String titleDe;
  final String titleAr;
  final String german;
  final String arabic;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final haystack = <String>[
      titleDe,
      titleAr,
      german,
      arabic,
      ...keywords,
    ].join(' ').toLowerCase();
    return haystack.contains(needle);
  }
}

final class ReplacementPartRequest {
  const ReplacementPartRequest({
    required this.orderNumber,
    required this.partNumber,
    required this.issue,
    required this.descriptionDe,
  });

  final String orderNumber;
  final String partNumber;
  final AssemblyIssue issue;
  final String descriptionDe;

  bool get isDefectCase =>
      issue == AssemblyIssue.missingPart ||
      issue == AssemblyIssue.wrongScrew ||
      issue == AssemblyIssue.transportDamage;
}
