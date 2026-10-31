import 'language_content_pack.dart';
import 'language_content_quality.dart';
import 'language_content_intelligence.dart';
import 'language_exercise_strategy.dart';
import 'language_identity.dart';
import 'language_presentation.dart';
import 'language_text_normalizer.dart';
import 'language_speech_profile.dart';

/// Language configuration selected by the Composition Root.
///
/// A LanguagePack contains only language-facing configuration. It must not
/// own learner state, authentication, subscription authority, secure storage,
/// or other application-wide mutable state.
abstract interface class LanguagePack {
  LanguageIdentity get identity;
  String get languageCode;
  String get displayName;
  String get targetLocale;
  String get sourceLocale;
  LanguageContentPack get contentPack;
  LanguageExerciseStrategy get exerciseStrategy;
  LanguagePresentation get presentation;
  LanguageTextNormalizer get textNormalizer;
  LanguageContentQuality get contentQuality;
  LanguageContentIntelligence get contentIntelligence;
  LanguageSpeechProfile get speechProfile;
}
