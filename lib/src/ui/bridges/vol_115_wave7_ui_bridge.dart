import '../../core/content/german_indirect_speech_engine.dart';

/// Volume 115 Wave 7 UI Bridge exposing Indirect Speech Diagnostics.
class Vol115Wave7UIBridge {
  Map<String, dynamic> getTask4893Diagnostics() {
    return <String, dynamic>{
      'volume': 115,
      'task_id': 4893,
      'subsystem': 'german_indirect_speech_engine',
      'supported_moods': ['konjunktiv1', 'fallbackKonjunktiv2'],
      'status': 'OPERATIONAL_VERIFIED',
    };
  }

  IndirectSpeechReport reportSpeech({
    required String speaker,
    required String verbInfinitive,
    required String quote,
    bool isPlural = false,
  }) {
    return GermanIndirectSpeechEngine.reportUtterance(
      speaker: speaker,
      verbInfinitive: verbInfinitive,
      directQuote: quote,
      isPluralSpeaker: isPlural,
    );
  }
}
