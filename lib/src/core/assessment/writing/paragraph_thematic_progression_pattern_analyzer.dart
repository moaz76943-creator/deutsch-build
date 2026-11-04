/// Task 1454: Thematic progression analyzer (constant theme vs linear theme)
class ThematicProgressionAnalyzer {
  String detectPattern(List<String> sentenceThemes) => sentenceThemes.toSet().length == 1 ? 'CONSTANT_THEME' : 'LINEAR_THEME';
}
