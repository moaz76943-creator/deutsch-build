import 'package:flutter/foundation.dart';

import '../../../core/packs/pack_models.dart';
import '../domain/pack_passport_models.dart';

enum PackPassportLoadState {
  idle,
  loading,
  ready,
  failed,
}

final class PackPassportController extends ChangeNotifier {
  PackPassportController({
    required PackPassportAssembler assembler,
  }) : _assembler = assembler;

  final PackPassportAssembler _assembler;

  PackPassportLoadState _state = PackPassportLoadState.idle;
  List<PackPassportEntry> _entries = const <PackPassportEntry>[];
  Object? _lastError;
  int _generation = 0;

  PackPassportLoadState get state => _state;
  List<PackPassportEntry> get entries => _entries;
  Object? get lastError => _lastError;

  Future<void> refresh(
    Iterable<PackPairRequest> requests,
  ) async {
    final generation = ++_generation;
    final unique = <String, PackPairRequest>{};

    for (final request in requests) {
      final pairKey = request.pairKey;
      unique.putIfAbsent(pairKey, () => request);
    }

    _state = PackPassportLoadState.loading;
    _lastError = null;
    notifyListeners();

    try {
      final next = await Future.wait(
        unique.values.map(_assembler.build),
        eagerError: true,
      );
      if (generation != _generation) return;

      next.sort((a, b) => a.pairKey.compareTo(b.pairKey));
      _entries = List<PackPassportEntry>.unmodifiable(next);
      _state = PackPassportLoadState.ready;
      notifyListeners();
    } on Object catch (error) {
      if (generation != _generation) return;
      _entries = const <PackPassportEntry>[];
      _lastError = error;
      _state = PackPassportLoadState.failed;
      notifyListeners();
    }
  }

  Future<void> refreshDirection(
    String sourceLanguageCode,
    String targetLanguageCode,
  ) =>
      refresh(
        <PackPairRequest>[
          PackPairRequest(
            sourceLanguageTag: sourceLanguageCode,
            targetLanguageTag: targetLanguageCode,
          ),
        ],
      );

  void invalidatePendingRefresh() {
    _generation += 1;
  }
}
