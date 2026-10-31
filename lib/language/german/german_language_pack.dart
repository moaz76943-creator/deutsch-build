import '../language_pack.dart';
import '../language_content_pack.dart';
import '../language_content_intelligence.dart';
import '../language_content_quality.dart';
import '../language_exercise_strategy.dart';
import '../language_identity.dart';
import '../language_presentation.dart';
import '../language_text_normalizer.dart';
import '../language_speech_profile.dart';
import 'german_content_pack.dart';
import 'german_content_quality.dart';
import 'german_content_intelligence.dart';
import 'german_language_exercise_strategy.dart';
import 'german_language_presentation.dart';
import 'german_text_normalizer.dart';
import 'german_speech_profile.dart';

/// Canonical learning-language configuration for the German build.
final class GermanLanguagePack implements LanguagePack {
  const GermanLanguagePack();

  @override
  LanguageIdentity get identity => LanguageIdentity(
        languageId: 'de',
        displayName: 'German',
        primaryLocale: 'de-DE',
      );

  @override
  String get languageCode => identity.languageId;

  @override
  String get displayName => identity.displayName;

  @override
  String get targetLocale => identity.primaryLocale;

  @override
  String get sourceLocale => 'ar';

  @override
  LanguageContentPack get contentPack => const GermanContentPack();

  @override
  LanguageExerciseStrategy get exerciseStrategy =>
      const GermanLanguageExerciseStrategy();

  @override
  LanguagePresentation get presentation => const GermanLanguagePresentation();

  @override
  LanguageTextNormalizer get textNormalizer => const GermanTextNormalizer();

  @override
  LanguageContentQuality get contentQuality => const GermanContentQuality();

  @override
  LanguageContentIntelligence get contentIntelligence =>
      const GermanContentIntelligence();

  @override
  LanguageSpeechProfile get speechProfile => const GermanSpeechProfile();
}
