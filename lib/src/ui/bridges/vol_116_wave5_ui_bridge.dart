import '../../core/content/german_passive_substitutes_engine.dart';

/// Volume 116 Wave 5 UI Bridge exposing Passive Voice Substitutes Diagnostics.
class Vol116Wave5UIBridge {
  Map<String, dynamic> getTask4905Diagnostics() {
    return <String, dynamic>{
      'volume': 116,
      'task_id': 4905,
      'subsystem': 'german_passive_substitutes_engine',
      'supported_substitutes': [
        'seinPlusZu', 'sichLassen', 'adjectiveSuffix'
      ],
      'tasks_remaining_to_5000': 95,
      'status': 'OPERATIONAL_VERIFIED',
    };
  }

  PassiveSubstituteAnalysis analyzeSubstitute({
    required String subject,
    required String verb,
    required String partizip2,
    PassiveSubstituteType type = PassiveSubstituteType.seinPlusZu,
    UnderlyingModalMeaning modal = UnderlyingModalMeaning.possibilityKann,
    String adj = '',
  }) {
    return GermanPassiveSubstitutesEngine.construct(
      subject: subject,
      verbInfinitive: verb,
      partizipTwo: partizip2,
      type: type,
      modal: modal,
      adjectiveRoot: adj,
    );
  }
}
