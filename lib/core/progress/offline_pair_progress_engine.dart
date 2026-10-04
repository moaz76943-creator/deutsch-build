import '../models/language_catalog_models.dart';
import '../packs/pack_models.dart';
import '../storage/local_db/pair_progress_database.dart';
import 'pair_progress_models.dart';

final class OfflinePairProgressEngine {
  const OfflinePairProgressEngine(this._store);

  final PairProgressDatabase _store;

  Future<void> recordCard({
    required ResolvedLanguagePair pair,
    required String cardId,
    required bool learned,
    required int level,
    required int achievementDelta,
    required bool correct,
    required DateTime reviewedAt,
  }) async {
    final context = _validatePair(pair);
    final normalizedCardId = cardId.trim();
    if (normalizedCardId.isEmpty || normalizedCardId.length > 160) {
      throw ArgumentError.value(
        cardId,
        'cardId',
        'must be 1..160 characters',
      );
    }
    if (level < 0 || level > 100) {
      throw ArgumentError.value(level, 'level', 'must be 0..100');
    }
    if (achievementDelta < 0 || achievementDelta > 100000) {
      throw ArgumentError.value(
        achievementDelta,
        'achievementDelta',
        'must be 0..100000',
      );
    }

    await _store.recordCard(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      cardId: normalizedCardId,
      learned: learned,
      level: level,
      achievementDelta: achievementDelta,
      correct: correct,
      reviewedAt: reviewedAt,
    );
  }

  Future<PairProgressSnapshot> loadPair(
    ResolvedLanguagePair pair,
  ) {
    final context = _validatePair(pair);
    return _store.loadPair(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
    );
  }

  Future<PairProgressCard?> loadCard(
    ResolvedLanguagePair pair,
    String cardId,
  ) {
    final context = _validatePair(pair);
    final normalizedCardId = cardId.trim();
    if (normalizedCardId.isEmpty || normalizedCardId.length > 160) {
      throw ArgumentError.value(
        cardId,
        'cardId',
        'must be 1..160 characters',
      );
    }
    return _store.loadCard(
      sourceLanguageId: context.source,
      targetLanguageId: context.target,
      cardId: normalizedCardId,
    );
  }

  _PairContext _validatePair(ResolvedLanguagePair pair) {
    final source = _language(pair.source.id, 'pair.source.id');
    final target = _language(pair.target.id, 'pair.target.id');
    if (source == target) {
      throw ArgumentError('Pair source and target must differ.');
    }

    final request = PackPairRequest(
      sourceLanguageTag: source,
      targetLanguageTag: target,
    );
    if (pair.pairKey != request.pairKey ||
        pair.route.request.pairKey != request.pairKey) {
      throw StateError('resolved_pair_context_mismatch');
    }

    return _PairContext(source: source, target: target);
  }

  static String _language(String raw, String field) {
    final normalized =
        raw.trim().replaceAll('_', '-').toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$')
        .hasMatch(normalized)) {
      throw ArgumentError.value(
        raw,
        field,
        'must be a valid language tag',
      );
    }
    return normalized;
  }
}

final class _PairContext {
  const _PairContext({
    required this.source,
    required this.target,
  });

  final String source;
  final String target;
}
