export 'verb_index.dart' show VerbIndex;
import '../core/content_contract.dart';
import '../language/language_pack.dart';
import 'search_index.dart';
import 'ai_gateway.dart';
import 'verb_index.dart';
import 'privacy_settings.dart';
import 'neuro_accessibility_settings.dart';
import 'user_vocabulary_service.dart';
import 'preferences_service.dart';

/// Composition-root dependencies shared by the application surface.
/// Concrete language models remain outside this shared dependency contract.
final class AppDependencies<T extends LearningContent> {
  const AppDependencies({
    required this.searchIndex,
    required this.verbIndex,
    required this.corpus,
    required this.languagePack,
    required this.aiGateway,
    required this.privacySettings,
    required this.neuroSettings,
    required this.userVocabularyService,
    required this.favoritesRepository,
    required this.preferencesService,
  });

  final SearchIndex<T> searchIndex;
  final VerbIndex verbIndex;
  final List<T> corpus;
  final LanguagePack languagePack;
  final AiGateway aiGateway;
  final PrivacySettingsStore privacySettings;
  final NeuroAccessibilitySettings neuroSettings;
  final UserVocabularyService userVocabularyService;
  final FavoritesRepository favoritesRepository;
  final PreferencesService preferencesService;
}
