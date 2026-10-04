import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/speech/speech_capability_resolver.dart';

void main() {
  test('pair is offline-ready only when both local voices are ready', () async {
    final probe = _FakeProbe(<String, LocalSpeechProbeResult>{
      'ar': const LocalSpeechProbeResult.ready(locale: 'ar-SA'),
      'sv': const LocalSpeechProbeResult.ready(locale: 'sv-SE'),
    });
    final resolver = SpeechCapabilityResolver(probe: probe);

    final result = await resolver.resolvePair(
      sourceLanguageTag: 'ar',
      targetLanguageTag: 'sv',
    );

    expect(result.status, SpeechPairOfflineStatus.ready);
    expect(result.source.status, SpeechOfflineStatus.ready);
    expect(result.target.status, SpeechOfflineStatus.ready);
    expect(probe.queries, <String>['ar', 'sv']);
  });

  test('missing target voice returns partial without any network fallback', () async {
    final probe = _FakeProbe(<String, LocalSpeechProbeResult>{
      'ar': const LocalSpeechProbeResult.ready(locale: 'ar-SA'),
      'sv': const LocalSpeechProbeResult.unavailable(
        reason: 'voice_not_installed',
      ),
    });
    final resolver = SpeechCapabilityResolver(probe: probe);

    final result = await resolver.resolvePair(
      sourceLanguageTag: 'AR',
      targetLanguageTag: 'sv_SE',
    );

    expect(result.status, SpeechPairOfflineStatus.partial);
    expect(result.source.languageTag, 'ar');
    expect(result.target.languageTag, 'sv-se');
    expect(result.target.status, SpeechOfflineStatus.unavailable);
    expect(result.target.reason, 'voice_not_installed');
    expect(probe.networkCalls, 0);
  });

  test('production local probe has no network dependency', () {
    final source = File(
      'lib/core/speech/flutter_local_speech_capability_probe.dart',
    ).readAsStringSync();

    expect(source, contains('FlutterOfflineTtsEngine'));
    expect(source, contains('_engine.probe(profile)'));
    expect(source, isNot(contains('package:http/')));
    expect(source, isNot(contains('dart:io')));
    expect(source, isNot(contains('.speak(')));
  });

  test('local probe failures fail closed as unavailable', () async {
    final resolver = SpeechCapabilityResolver(
      probe: _ThrowingProbe(),
    );

    final result = await resolver.resolvePair(
      sourceLanguageTag: 'de',
      targetLanguageTag: 'sv',
    );

    expect(result.status, SpeechPairOfflineStatus.unavailable);
    expect(result.source.status, SpeechOfflineStatus.unavailable);
    expect(result.target.status, SpeechOfflineStatus.unavailable);
    expect(result.source.reason, 'local_probe_failed');
    expect(result.target.reason, 'local_probe_failed');
  });
}

final class _FakeProbe implements LocalSpeechCapabilityProbe {
  _FakeProbe(this.results);

  final Map<String, LocalSpeechProbeResult> results;
  final List<String> queries = <String>[];
  int networkCalls = 0;

  @override
  Future<LocalSpeechProbeResult> probe(String languageTag) async {
    queries.add(languageTag);
    return results[languageTag] ??
        const LocalSpeechProbeResult.unavailable(
          reason: 'voice_not_installed',
        );
  }
}

final class _ThrowingProbe implements LocalSpeechCapabilityProbe {
  @override
  Future<LocalSpeechProbeResult> probe(String languageTag) async {
    throw StateError('local engine unavailable');
  }
}
