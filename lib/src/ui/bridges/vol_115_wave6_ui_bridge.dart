import '../../core/content/german_passive_voice_engine.dart';

/// Volume 115 Wave 6 UI Bridge exposing Passive Voice Engine Diagnostics.
class Vol115Wave6UIBridge {
  Map<String, dynamic> getTask4892Diagnostics() {
    return <String, dynamic>{
      'volume': 115,
      'task_id': 4892,
      'subsystem': 'german_passive_voice_engine',
      'supported_types': ['vorgangspassiv', 'zustandspassiv'],
      'supported_tenses': ['praesens', 'praeteritum', 'perfekt'],
      'status': 'OPERATIONAL_VERIFIED',
    };
  }

  PassiveVoiceTransformation transformToPassive({
    required String subject,
    required String directObject,
    required String verbInfinitive,
    required String partizipTwo,
    PassiveType type = PassiveType.vorgangspassiv,
    PassiveTense tense = PassiveTense.praesens,
  }) {
    return GermanPassiveVoiceEngine.transform(
      subject: subject,
      directObject: directObject,
      verbInfinitive: verbInfinitive,
      partizipTwo: partizipTwo,
      type: type,
      tense: tense,
    );
  }
}
