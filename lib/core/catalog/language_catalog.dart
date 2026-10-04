import '../models/language_catalog_models.dart';
import '../packs/pack_acquisition_router.dart';

final class LanguageCatalog {
  LanguageCatalog({
    required PackAcquisitionRouter packRouter,
    Iterable<LanguageMetadata> languages =
        const <LanguageMetadata>[],
  }) : _packRouter = packRouter {
    registerAll(languages);
  }

  static const int maxLanguages = 100;

  final PackAcquisitionRouter _packRouter;
  final Map<String, LanguageMetadata> _languages =
      <String, LanguageMetadata>{};

  ResolvedLanguagePair? _activePair;
  int _resolutionGeneration = 0;

  int get languageCount => _languages.length;

  int get directedPairCapacity =>
      languageCount * (languageCount - 1);

  int get residentPairCount => _activePair == null ? 0 : 1;

  ResolvedLanguagePair? get activePair => _activePair;

  List<LanguageMetadata> get languages =>
      List<LanguageMetadata>.unmodifiable(_languages.values);

  void register(LanguageMetadata metadata) {
    final id = _normalizeLanguageId(metadata.id);
    final name = metadata.name.trim();
    if (name.isEmpty || name.length > 120) {
      throw ArgumentError.value(
        metadata.name,
        'metadata.name',
        'must be 1..120 characters',
      );
    }
    if (_languages.containsKey(id)) {
      throw StateError('language_already_registered:$id');
    }
    if (_languages.length >= maxLanguages) {
      throw StateError(
        'language_catalog_capacity_exceeded:$maxLanguages',
      );
    }

    _languages[id] = LanguageMetadata(
      id: id,
      name: name,
      isRtl: metadata.isRtl,
    );
  }

  void registerAll(Iterable<LanguageMetadata> languages) {
    for (final language in languages) {
      register(language);
    }
  }

  LanguageMetadata? find(String languageId) =>
      _languages[_normalizeLanguageId(languageId)];

  LanguageMetadata require(String languageId) {
    final id = _normalizeLanguageId(languageId);
    final language = _languages[id];
    if (language == null) {
      throw StateError('language_not_registered:$id');
    }
    return language;
  }

  Future<ResolvedLanguagePair> resolvePair(
    String sourceId,
    String targetId,
  ) async {
    final sourceKey = _normalizeLanguageId(sourceId);
    final targetKey = _normalizeLanguageId(targetId);
    if (sourceKey == targetKey) {
      throw ArgumentError(
        'Source and target language must be different.',
      );
    }

    final source = _languages[sourceKey];
    final target = _languages[targetKey];
    if (source == null) {
      throw StateError('language_not_registered:$sourceKey');
    }
    if (target == null) {
      throw StateError('language_not_registered:$targetKey');
    }

    final generation = ++_resolutionGeneration;
    final request = PackPairRequest(
      sourceLanguageTag: source.id,
      targetLanguageTag: target.id,
    );
    final route = await _packRouter.route(request);
    final resolved = ResolvedLanguagePair(
      source: source,
      target: target,
      pairKey: request.pairKey,
      generation: generation,
      route: route,
    );

    if (generation == _resolutionGeneration) {
      _activePair = resolved;
    }
    return resolved;
  }

  static String _normalizeLanguageId(String raw) {
    final normalized =
        raw.trim().replaceAll('_', '-').toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
        .hasMatch(normalized)) {
      throw ArgumentError.value(
        raw,
        'languageId',
        'must be a valid language tag',
      );
    }
    return normalized;
  }
}
