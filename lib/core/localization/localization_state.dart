import 'locale_provider.dart';

/// Keeps interface, source, and target language identities separate.
///
/// Equal values are allowed because a user's UI language can legitimately be
/// the target language. The fields remain semantically distinct so no implicit
/// German/English pivot or reverse-pair assumption is introduced.
final class LocalizationState implements LocaleProvider {
  @override
  final AppLocale userLocale;

  @override
  final AppLocale sourceLocale;

  @override
  final AppLocale targetLocale;

  const LocalizationState({
    required this.userLocale,
    required this.sourceLocale,
    required this.targetLocale,
  });

  factory LocalizationState.fromLanguageTags({
    required String userLanguageTag,
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) =>
      LocalizationState(
        userLocale: AppLocale.parse(userLanguageTag),
        sourceLocale: AppLocale.parse(sourceLanguageTag),
        targetLocale: AppLocale.parse(targetLanguageTag),
      );

  LocalizationState switchUserLocale(String languageTag) => LocalizationState(
        userLocale: AppLocale.parse(languageTag),
        sourceLocale: sourceLocale,
        targetLocale: targetLocale,
      );

  LocalizationState switchLearningPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) =>
      LocalizationState(
        userLocale: userLocale,
        sourceLocale: AppLocale.parse(sourceLanguageTag),
        targetLocale: AppLocale.parse(targetLanguageTag),
      );
}
