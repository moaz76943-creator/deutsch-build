enum DentistCategory {
  checkup,
  cleaning,
  appointment;

  String get german => switch (this) {
        DentistCategory.checkup => 'Kontrolluntersuchung',
        DentistCategory.cleaning => 'Zahnreinigung',
        DentistCategory.appointment => 'Termin & Empfang',
      };

  String get arabic => switch (this) {
        DentistCategory.checkup => 'الفحص الدوري',
        DentistCategory.cleaning => 'تنظيف الأسنان والجير',
        DentistCategory.appointment => 'المواعيد والاستقبال',
      };
}

final class DentistPhrase {
  const DentistPhrase({
    required this.id,
    required this.category,
    required this.german,
    required this.arabic,
    required this.tags,
  });

  final String id;
  final DentistCategory category;
  final String german;
  final String arabic;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}
