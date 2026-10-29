import '../models/content.dart';
import '../services/verb_index.dart';
import 'language_content_intelligence.dart';
import 'language_content_pack.dart';
import 'language_content_quality.dart';
import 'language_exercise_strategy.dart';
import 'language_identity.dart';
import 'language_pack.dart';
import 'language_presentation.dart';
import 'language_text_normalizer.dart';
import 'language_speech_profile.dart';

/// Immutable content view admitted from an active offline pack.
final class RuntimeLanguageContentPack implements LanguageContentPack {
  const RuntimeLanguageContentPack({
    required this.items,
    required this.verbIndex,
  });

  @override
  final List<ContentItem> items;

  @override
  final VerbIndex verbIndex;
}

/// Preserves language-specific intelligence while replacing only its content
/// source with a verified runtime pack.
final class RuntimeLanguagePack implements LanguagePack {
  const RuntimeLanguagePack({
    required this.base,
    required this.runtimeContentPack,
  });

  final LanguagePack base;
  final LanguageContentPack runtimeContentPack;

  @override
  LanguageIdentity get identity => base.identity;

  @override
  String get languageCode => base.languageCode;

  @override
  String get displayName => base.displayName;

  @override
  String get targetLocale => base.targetLocale;

  @override
  String get sourceLocale => base.sourceLocale;

  @override
  LanguageContentPack get contentPack => runtimeContentPack;

  @override
  LanguageExerciseStrategy get exerciseStrategy => base.exerciseStrategy;

  @override
  LanguagePresentation get presentation => base.presentation;

  @override
  LanguageTextNormalizer get textNormalizer => base.textNormalizer;

  @override
  LanguageContentQuality get contentQuality => base.contentQuality;

  @override
  LanguageContentIntelligence get contentIntelligence =>
      base.contentIntelligence;

  @override
  LanguageSpeechProfile get speechProfile => base.speechProfile;
}
