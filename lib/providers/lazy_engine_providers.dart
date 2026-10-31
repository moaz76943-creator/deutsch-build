import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/offline_audio_manager.dart';
import '../services/concept_disambiguation_service.dart';
import '../services/deck_export_service.dart';
import '../services/embedded_audio_streamer.dart';
import '../services/fts_search_service.dart';
import '../services/user_vault_security_service.dart';
import '../utils/agglutinative_suffix_stripper.dart';
import '../utils/fuzzy_search_engine.dart';
import '../utils/transliteration_engine.dart';

/// Providers are registered without running their factories. Read only from
/// the feature that needs the corresponding service; never watch in MyApp.
final agglutinativeSuffixStripperProvider =
    Provider<AgglutinativeSuffixStripper>(
        (ref) => const AgglutinativeSuffixStripper());

typedef LazyDictionaryLookup = Future<List<Map<String, dynamic>>> Function(
    String query, String languageCode);

/// Allocates suffix analysis only for explicit Turkic/Uralic dictionary searches.
/// Non-agglutinative languages use the normal FTS/SQLite lookup directly.
final lazyDictionaryLookupProvider = Provider<LazyDictionaryLookup>((ref) {
  final fts = FtsSearchService();
  return (query, languageCode) {
    final code =
        languageCode.trim().toLowerCase().replaceAll('_', '-').split('-').first;
    if (!const <String>{'tr', 'az', 'fi', 'hu'}.contains(code)) {
      return fts.searchDictionary(query, languageCode);
    }
    return ref
        .read(agglutinativeSuffixStripperProvider)
        .searchWithSuffixFallback(query,
            languageCode: code,
            search: (text, lang) => fts.searchDictionary(text, lang));
  };
});

/// Read the callback when a user selects recorded Opus playback. Neither
/// source nor streamer is opened/allocated until the callback is invoked.
typedef PlayEmbeddedOpus = Future<bool> Function(
    EmbeddedOpusSource source, String clipId);
final playEmbeddedOpusProvider = Provider<PlayEmbeddedOpus>((ref) =>
    (source, clipId) => EmbeddedAudioStreamer(source: source).playClip(clipId));

/// Same opt-in boundary for callers that already have an Opus BLOB.
typedef PlayEmbeddedOpusBytes = Future<bool> Function(Uint8List opusBytes);
final playEmbeddedOpusBytesProvider = Provider<PlayEmbeddedOpusBytes>((ref) =>
    (bytes) => EmbeddedAudioStreamer(source: const _UnusedOpusSource())
        .playBytes(bytes));

class _UnusedOpusSource implements EmbeddedOpusSource {
  const _UnusedOpusSource();

  @override
  Future<Uint8List?> read(String clipId) async => null;
}

final conceptDisambiguationProvider = Provider<ConceptDisambiguationService>(
    (ref) => ConceptDisambiguationService());

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
        input,
        candidates,
      ),
);
