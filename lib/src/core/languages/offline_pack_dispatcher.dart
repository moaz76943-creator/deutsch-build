import 'dart:async';
import 'declarative_language_profile.dart';
import 'declarative_language_engine.dart';
import 'directed_pair_config.dart';
import 'directed_pair_matrix_engine.dart';

/// State of currently active language learning pair.
class ActivePairState {
  final LanguageProfile sourceLanguage;
  final LanguageProfile targetLanguage;
  final DirectedPairConfig pairConfig;
  final DateTime activatedAt;

  const ActivePairState({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.pairConfig,
    required this.activatedAt,
  });

  String get pairId => pairConfig.pairId;
}

/// Dispatches offline packs and hot-swaps active language pairs in-memory without app restart.
class OfflinePackDispatcher {
  final DeclarativeLanguageEngine languageEngine;
  final DirectedPairMatrixEngine matrixEngine;

  ActivePairState? _currentState;
  final StreamController<ActivePairState> _stateController =
      StreamController<ActivePairState>.broadcast();

  OfflinePackDispatcher({
    required this.languageEngine,
    required this.matrixEngine,
  });

  ActivePairState? get currentState => _currentState;
  Stream<ActivePairState> get stateStream => _stateController.stream;
  bool get hasActivePair => _currentState != null;

  /// Hot-swaps the active language pair in-memory.
  Future<bool> switchPair({
    required String sourceIso,
    required String targetIso,
  }) async {
    final sProfile = languageEngine.getProfile(sourceIso);
    final tProfile = languageEngine.getProfile(targetIso);

    if (sProfile == null || tProfile == null) {
      return false; // Requested language profile not found in registry
    }

    final previousState = _currentState;

    try {
      final config = matrixEngine.getOrCreatePairConfig(sProfile, tProfile);

      _currentState = ActivePairState(
        sourceLanguage: sProfile,
        targetLanguage: tProfile,
        pairConfig: config,
        activatedAt: DateTime.now(),
      );

      _stateController.add(_currentState!);
      return true;
    } catch (_) {
      // Atomic rollback on failure
      _currentState = previousState;
      return false;
    }
  }

  void dispose() {
    _stateController.close();
  }
}
