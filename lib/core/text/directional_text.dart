import '../language/app_text_direction.dart';

enum LinguisticSemanticRole {
  word,
  translation,
  example,
  grammarLabel,
  article,
  caseMarker,
  phonetic,
  number,
  punctuation,
  explanation,
  generic,
}

final class DirectionalText {
  const DirectionalText._({
    required this.text,
    required this.languageCode,
    required this.direction,
    required this.semanticRole,
  });

  factory DirectionalText.forLanguage(
    String text, {
    required String languageCode,
    LinguisticSemanticRole semanticRole = LinguisticSemanticRole.generic,
  }) =>
      DirectionalText._(
        text: text,
        languageCode: languageCode,
        direction: AppTextDirection.forLanguage(languageCode),
        semanticRole: semanticRole,
      );

  factory DirectionalText.german(
    String text, {
    LinguisticSemanticRole semanticRole = LinguisticSemanticRole.generic,
  }) =>
      DirectionalText._(
        text: text,
        languageCode: 'de',
        direction: AppTextDirection.ltr,
        semanticRole: semanticRole,
      );

  factory DirectionalText.arabic(
    String text, {
    LinguisticSemanticRole semanticRole = LinguisticSemanticRole.generic,
  }) =>
      DirectionalText._(
        text: text,
        languageCode: 'ar',
        direction: AppTextDirection.rtl,
        semanticRole: semanticRole,
      );

  final String text;
  final String languageCode;
  final AppTextDirection direction;
  final LinguisticSemanticRole semanticRole;
}
