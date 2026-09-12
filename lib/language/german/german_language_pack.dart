import '../language_pack.dart';
import '../language_content_pack.dart';
import 'german_content_pack.dart';
import 'german_content_quality.dart';
import 'german_content_intelligence.dart';
import 'german_language_exercise_strategy.dart';
import 'german_language_presentation.dart';
import 'german_text_normalizer.dart';

/// Canonical learning-language configuration for the German build.
final class GermanLanguagePack implements LanguagePack {
  const GermanLanguagePack();

  @override
  String get languageCode => 'de';

  @override
  String get displayName => 'German';

  @override
  String get targetLocale => 'de-DE';

  @override
  String get sourceLocale => 'ar';

  @override
  LanguageContentPack get contentPack => const GermanContentPack();

  @override
  LanguageExerciseStrategy get exerciseStrategy => const GermanLanguageExerciseStrategy();

  @override
  LanguagePresentation get presentation => const GermanLanguagePresentation();

  @override
  LanguageTextNormalizer get textNormalizer => const GermanTextNormalizer();

  @override
  LanguageContentQuality get contentQuality => const GermanContentQuality();

  @override
  LanguageContentIntelligence get contentIntelligence => const GermanContentIntelligence();
}
