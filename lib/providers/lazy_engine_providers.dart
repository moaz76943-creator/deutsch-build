import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/offline_audio_manager.dart';
import '../services/concept_disambiguation_service.dart';
import '../services/deck_export_service.dart';
import '../services/user_vault_security_service.dart';
import '../utils/agglutinative_suffix_stripper.dart';
import '../utils/fuzzy_search_engine.dart';
import '../utils/transliteration_engine.dart';

/// Providers are registered without running their factories. Read only from
/// the feature that needs the corresponding service; never watch in MyApp.
final agglutinativeSuffixStripperProvider =
    Provider<AgglutinativeSuffixStripper>((ref) => AgglutinativeSuffixStripper());

final conceptDisambiguationProvider =
    Provider<ConceptDisambiguationService>((ref) => ConceptDisambiguationService());

final deckExportServiceProvider =
    Provider<DeckExportService>((ref) => DeckExportService());

final userVaultSecurityProvider =
    Provider<UserVaultSecurityService>((ref) => UserVaultSecurityService());

/// The plugin itself is still constructed only by the first speak() call.
final offlineWordAudioProvider =
    Provider<OfflineAudioManager>((ref) => OfflineAudioManager.instance);

typedef TransliterationLookup = String? Function(
    String input, String scriptFamily);

final transliterationLookupProvider = Provider<TransliterationLookup>(
  (ref) => TransliterationEngine.transliterateToLatin,
);

typedef FuzzySuggestionLookup = List<String> Function(
    String input, Iterable<String> candidates);

final fuzzySuggestionLookupProvider = Provider<FuzzySuggestionLookup>(
  (ref) => (input, candidates) => FuzzySearchEngine.didYouMean(
    input, candidates,
  ),
);
