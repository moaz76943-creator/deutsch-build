import 'dart:async';

import '../localization/locale_provider.dart';
import '../localization/localization_state.dart';
import 'l10n_models.dart';

final class DynamicL10nEngine {
  DynamicL10nEngine({
    required LocalizationState initialState,
    required String fallbackLanguageTag,
    Iterable<L10nDictionary> dictionaries = const <L10nDictionary>[],
  })  : _state = initialState,
        _fallbackLocale = AppLocale.parse(fallbackLanguageTag) {
    for (final dictionary in dictionaries) {
      final key = dictionary.locale.languageTag;
      if (_dictionaries.containsKey(key)) {
        throw ArgumentError(
          'Duplicate localization dictionary for $key.',
        );
      }
      _dictionaries[key] = dictionary;
    }
  }

  final Map<String, L10nDictionary> _dictionaries =
      <String, L10nDictionary>{};
  final StreamController<L10nEngineChange> _changes =
      StreamController<L10nEngineChange>.broadcast(sync: true);

  LocalizationState _state;
  AppLocale _fallbackLocale;
  int _revision = 0;
  bool _closed = false;

  L10nRuntimeSnapshot get snapshot => L10nRuntimeSnapshot(
        state: _state,
        fallbackLocale: _fallbackLocale,
        revision: _revision,
        loadedLocales: _dictionaries.keys.toSet(),
      );

  Stream<L10nEngineChange> get changes => _changes.stream;

  bool get isClosed => _closed;

  void setUserLanguage(String languageTag) {
    _ensureOpen();
    final next = _state.switchUserLocale(languageTag);
    if (next.userLocale.languageTag == _state.userLocale.languageTag) {
      return;
    }
    final previous = snapshot;
    _state = next;
    _commit(
      reason: L10nChangeReason.userLanguage,
      previous: previous,
    );
  }

  void setLearningPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) {
    _ensureOpen();
    final next = _state.switchLearningPair(
      sourceLanguageTag: sourceLanguageTag,
      targetLanguageTag: targetLanguageTag,
    );
    if (next.sourceLocale.languageTag == _state.sourceLocale.languageTag &&
        next.targetLocale.languageTag == _state.targetLocale.languageTag) {
      return;
    }
    final previous = snapshot;
    _state = next;
    _commit(
      reason: L10nChangeReason.learningPair,
      previous: previous,
    );
  }

  void setFallbackLanguage(String languageTag) {
    _ensureOpen();
    final next = AppLocale.parse(languageTag);
    if (next.languageTag == _fallbackLocale.languageTag) return;
    final previous = snapshot;
    _fallbackLocale = next;
    _commit(
      reason: L10nChangeReason.fallbackLanguage,
      previous: previous,
    );
  }

  void registerDictionary(
    L10nDictionary dictionary, {
    bool replace = true,
  }) {
    _ensureOpen();
    final localeTag = dictionary.locale.languageTag;
    if (!replace && _dictionaries.containsKey(localeTag)) {
      throw StateError(
        'Localization dictionary already registered for $localeTag.',
      );
    }
    final previous = snapshot;
    _dictionaries[localeTag] = dictionary;
    _commit(
      reason: L10nChangeReason.dictionaryRegistered,
      previous: previous,
      dictionaryLocale: localeTag,
    );
  }

  void registerAll(
    Iterable<L10nDictionary> dictionaries, {
    bool replace = true,
  }) {
    _ensureOpen();
    final incoming = dictionaries.toList(growable: false);
    if (incoming.isEmpty) return;

    final seen = <String>{};
    for (final dictionary in incoming) {
      final localeTag = dictionary.locale.languageTag;
      if (!seen.add(localeTag)) {
        throw ArgumentError(
          'Duplicate localization dictionary in batch for $localeTag.',
        );
      }
      if (!replace && _dictionaries.containsKey(localeTag)) {
        throw StateError(
          'Localization dictionary already registered for $localeTag.',
        );
      }
    }

    final previous = snapshot;
    for (final dictionary in incoming) {
      _dictionaries[dictionary.locale.languageTag] = dictionary;
    }
    _commit(
      reason: L10nChangeReason.dictionaryRegistered,
      previous: previous,
    );
  }

  bool removeDictionary(String languageTag) {
    _ensureOpen();
    final localeTag = AppLocale.parse(languageTag).languageTag;
    if (!_dictionaries.containsKey(localeTag)) return false;
    final previous = snapshot;
    _dictionaries.remove(localeTag);
    _commit(
      reason: L10nChangeReason.dictionaryRemoved,
      previous: previous,
      dictionaryLocale: localeTag,
    );
    return true;
  }

  bool hasDictionary(String languageTag) {
    _ensureOpen();
    final localeTag = AppLocale.parse(languageTag).languageTag;
    return _dictionaries.containsKey(localeTag);
  }

  String text(
    String key, {
    Map<String, Object?> arguments = const <String, Object?>{},
  }) =>
      resolve(key, arguments: arguments).value;

  L10nResolvedText resolve(
    String key, {
    Map<String, Object?> arguments = const <String, Object?>{},
  }) {
    _ensureOpen();
    final normalizedKey = key.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be empty');
    }

    final requested = _state.userLocale;
    for (final localeTag in _lookupOrder(requested, _fallbackLocale)) {
      final dictionary = _dictionaries[localeTag];
      final message = dictionary?.find(normalizedKey);
      if (message == null) continue;
      return L10nResolvedText(
        key: normalizedKey,
        value: message.render(arguments: arguments),
        requestedLocale: requested.languageTag,
        resolvedLocale: localeTag,
        usedFallback: localeTag != requested.languageTag,
      );
    }

    return L10nResolvedText(
      key: normalizedKey,
      value: normalizedKey,
      requestedLocale: requested.languageTag,
      resolvedLocale: requested.languageTag,
      usedFallback: true,
    );
  }

  L10nMessage? findMessage(
    String key, {
    String? languageTag,
  }) {
    _ensureOpen();
    final locale = languageTag == null
        ? _state.userLocale
        : AppLocale.parse(languageTag);
    for (final candidate in _localeCandidates(locale)) {
      final message = _dictionaries[candidate]?.find(key);
      if (message != null) return message;
    }
    return null;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _changes.close();
  }

  void _commit({
    required L10nChangeReason reason,
    required L10nRuntimeSnapshot previous,
    String? dictionaryLocale,
  }) {
    _revision += 1;
    _changes.add(
      L10nEngineChange(
        reason: reason,
        previous: previous,
        current: snapshot,
        dictionaryLocale: dictionaryLocale,
      ),
    );
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('DynamicL10nEngine is closed.');
    }
  }

  static List<String> _lookupOrder(
    AppLocale requested,
    AppLocale fallback,
  ) {
    final ordered = <String>[];
    void add(String value) {
      if (!ordered.contains(value)) ordered.add(value);
    }

    for (final value in _localeCandidates(requested)) {
      add(value);
    }
    for (final value in _localeCandidates(fallback)) {
      add(value);
    }
    return List<String>.unmodifiable(ordered);
  }

  static List<String> _localeCandidates(AppLocale locale) {
    final result = <String>[locale.languageTag];
    if (locale.regionCode != null) {
      result.add(locale.languageCode);
    }
    return List<String>.unmodifiable(result);
  }
}
