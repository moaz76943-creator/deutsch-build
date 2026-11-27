/// Pure domain entity — no Flutter or infrastructure dependencies.
/// Part of the modular feature structure for fast, independent development.
class VocabularyItem {
  final String id;
  final String german;
  final String arabic;
  final String? audioPath;
  final int? level;

  const VocabularyItem({
    required this.id,
    required this.german,
    required this.arabic,
    this.audioPath,
    this.level,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
