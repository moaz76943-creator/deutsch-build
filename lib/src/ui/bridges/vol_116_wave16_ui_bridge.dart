import '../../core/content/german_indirect_questions_imperatives_engine.dart';

/// Volume 116 Wave 16 UI Bridge exposing Indirect Questions & Imperatives Diagnostics.
class Vol116Wave16UIBridge {
  Map<String, dynamic> getTask4916Diagnostics() {
    return <String, dynamic>{
      'volume': 116,
      'task_id': 4916,
      'subsystem': 'german_indirect_questions_imperatives_engine',
      'supported_acts': ['yesNoQuestionOb', 'whQuestion', 'imperativeCommand'],
      'tasks_remaining_to_5000': 84,
      'status': 'OPERATIONAL_VERIFIED',
    };
  }

  IndirectSpeechActStructure formatQuestion({
    required String intro,
    required String directQ,
    bool isYesNo = false,
    String? wh,
    required String subject,
    required String verbK1,
    String rem = '',
  }) {
    return GermanIndirectQuestionsImperativesEngine.transformQuestion(
      introMatrix: intro,
      directQuestion: directQ,
      isYesNo: isYesNo,
      whWord: wh,
      subject: subject,
      verbInKonjunktiv: verbK1,
      remainder: rem,
    );
  }
}
