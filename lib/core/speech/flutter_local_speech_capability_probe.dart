import '../../features/audio/domain/services/offline_tts_engine.dart';
import '../../language/language_speech_profile.dart';
import '../infrastructure/audio/flutter_tts_audio_engine.dart';
import 'speech_capability_resolver.dart';

final class FlutterLocalSpeechCapabilityProbe
    implements LocalSpeechCapabilityProbe {
  FlutterLocalSpeechCapabilityProbe({
    FlutterOfflineTtsEngine? engine,
  }) : _engine = engine ?? FlutterOfflineTtsEngine();

  final FlutterOfflineTtsEngine _engine;
  bool _closed = false;

  bool get isClosed => _closed;

  @override
  Future<LocalSpeechProbeResult> probe(String languageTag) async {
    if (_closed) {
      return const LocalSpeechProbeResult.unavailable(
        reason: 'local_probe_closed',
      );
    }

    final profile = _ProbeSpeechProfile(languageTag);
    try {
      final availability = await _engine.probe(profile);
      if (availability != OfflineTtsAvailability.ready) {
        return const LocalSpeechProbeResult.unavailable(
          reason: 'offline_voice_not_installed',
        );
      }

      return LocalSpeechProbeResult.ready(
        locale: profile.preferredTtsLocales.first,
      );
    } on Object {
      return const LocalSpeechProbeResult.unavailable(
        reason: 'local_probe_failed',
      );
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _engine.shutdown();
  }
}

final class _ProbeSpeechProfile implements LanguageSpeechProfile {
  _ProbeSpeechProfile(String languageTag)
      : _languageTag = _normalize(languageTag);

  final String _languageTag;

  @override
  String get languageCode => _languageTag;

  @override
  List<String> get preferredTtsLocales {
    final base = _languageTag.split('-').first;
    return List<String>.unmodifiable(
      <String>{
        _languageTag,
        if (base.isNotEmpty) base,
      },
    );
  }

  @override
  double get defaultSpeechRate => 0.46;

  @override
  String get offlineVoiceUnavailableMessage =>
      'offline_voice_unavailable';

  static String _normalize(String value) =>
      value.trim().replaceAll('_', '-').toLowerCase();
}
