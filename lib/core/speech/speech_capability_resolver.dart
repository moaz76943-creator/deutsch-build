enum SpeechOfflineStatus {
  ready,
  unavailable,
}

enum SpeechPairOfflineStatus {
  ready,
  partial,
  unavailable,
}

final class LocalSpeechProbeResult {
  const LocalSpeechProbeResult.ready({
    required String locale,
  })  : available = true,
        locale = locale,
        reason = null;

  const LocalSpeechProbeResult.unavailable({
    required String reason,
  })  : available = false,
        locale = null,
        reason = reason;

  final bool available;
  final String? locale;
  final String? reason;
}

abstract interface class LocalSpeechCapabilityProbe {
  Future<LocalSpeechProbeResult> probe(String languageTag);
}

final class SpeechLanguageCapability {
  const SpeechLanguageCapability({
    required this.languageTag,
    required this.status,
    required this.locale,
    required this.reason,
  });

  final String languageTag;
  final SpeechOfflineStatus status;
  final String? locale;
  final String? reason;
}

final class SpeechPairCapability {
  const SpeechPairCapability({
    required this.source,
    required this.target,
    required this.status,
  });

  final SpeechLanguageCapability source;
  final SpeechLanguageCapability target;
  final SpeechPairOfflineStatus status;

  bool get isFullyOfflineReady =>
      status == SpeechPairOfflineStatus.ready;
}

final class SpeechCapabilityResolver {
  const SpeechCapabilityResolver({
    required LocalSpeechCapabilityProbe probe,
  }) : _probe = probe;

  final LocalSpeechCapabilityProbe _probe;

  Future<SpeechPairCapability> resolvePair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) async {
    final source = _languageTag(
      sourceLanguageTag,
      'sourceLanguageTag',
    );
    final target = _languageTag(
      targetLanguageTag,
      'targetLanguageTag',
    );
    if (source == target) {
      throw ArgumentError(
        'Source and target language must be different.',
      );
    }

    final sourceCapability = await _resolveLanguage(source);
    final targetCapability = await _resolveLanguage(target);
    final readyCount = <SpeechLanguageCapability>[
      sourceCapability,
      targetCapability,
    ].where((item) => item.status == SpeechOfflineStatus.ready).length;

    final status = switch (readyCount) {
      2 => SpeechPairOfflineStatus.ready,
      1 => SpeechPairOfflineStatus.partial,
      _ => SpeechPairOfflineStatus.unavailable,
    };

    return SpeechPairCapability(
      source: sourceCapability,
      target: targetCapability,
      status: status,
    );
  }

  Future<SpeechLanguageCapability> _resolveLanguage(
    String languageTag,
  ) async {
    try {
      final result = await _probe.probe(languageTag);
      if (!result.available) {
        return SpeechLanguageCapability(
          languageTag: languageTag,
          status: SpeechOfflineStatus.unavailable,
          locale: null,
          reason: _reason(result.reason, 'voice_not_installed'),
        );
      }

      final locale = result.locale?.trim();
      if (locale == null || locale.isEmpty) {
        return SpeechLanguageCapability(
          languageTag: languageTag,
          status: SpeechOfflineStatus.unavailable,
          locale: null,
          reason: 'offline_locale_missing',
        );
      }

      return SpeechLanguageCapability(
        languageTag: languageTag,
        status: SpeechOfflineStatus.ready,
        locale: locale.replaceAll('_', '-'),
        reason: null,
      );
    } on Object {
      return SpeechLanguageCapability(
        languageTag: languageTag,
        status: SpeechOfflineStatus.unavailable,
        locale: null,
        reason: 'local_probe_failed',
      );
    }
  }

  static String _languageTag(String raw, String field) {
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

  static String _reason(String? value, String fallback) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return fallback;
    return normalized.length <= 120
        ? normalized
        : normalized.substring(0, 120);
  }
}
