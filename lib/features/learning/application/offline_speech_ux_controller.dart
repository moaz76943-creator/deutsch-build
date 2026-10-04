import '../../../core/agents/system_agent_runtime.dart';
import '../../../core/settings/speech_rate_settings.dart';

final class OfflineSpeechUxController {
  const OfflineSpeechUxController({
    required SystemAgentRuntime runtime,
    required SpeechRateSettingsController rateSettings,
  })  : _runtime = runtime,
        _rateSettings = rateSettings;

  final SystemAgentRuntime _runtime;
  final SpeechRateSettingsController _rateSettings;

  double get speedMultiplier => _rateSettings.speedMultiplier;

  Future<void> speak({
    required String text,
    required String targetLanguageTag,
  }) async {
    final normalizedText = text.trim();
    final normalizedTag = targetLanguageTag.trim();
    if (normalizedText.isEmpty || normalizedTag.isEmpty) {
      throw ArgumentError(
        'Speech text and target language tag must not be empty.',
      );
    }

    await _runtime.prepareSpeech(
      text: normalizedText,
      targetLanguageTag: normalizedTag,
      speed: _rateSettings.speedMultiplier,
    );
  }
}
