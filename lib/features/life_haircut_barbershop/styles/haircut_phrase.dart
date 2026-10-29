enum HaircutTopic {
  appointment,
  haircut,
  beardMoustache,
  washing,
  care,
  payment,
}

enum HaircutLevel {
  a1a2,
  b1,
  b2,
}

extension HaircutLevelLabel on HaircutLevel {
  String get label => switch (this) {
        HaircutLevel.a1a2 => 'A1/A2',
        HaircutLevel.b1 => 'B1',
        HaircutLevel.b2 => 'B2',
      };
}

final class HaircutPhrase {
  const HaircutPhrase({
    required this.id,
    required this.topic,
    required this.level,
    required this.german,
    required this.arabic,
    required this.noteArabic,
    this.quick = false,
  });

  final String id;
  final HaircutTopic topic;
  final HaircutLevel level;
  final String german;
  final String arabic;
  final String noteArabic;
  final bool quick;

  bool matches(String query) {
    final normalized = _normalize(query);
    if (normalized.isEmpty) return true;
    final haystack = _normalize('$german $arabic $noteArabic');
    return haystack.contains(normalized);
  }
}

String _normalize(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[.!?,;:()\[\]{}"“”„]'), '')
    .replaceAll(RegExp(r'\s+'), ' ');
