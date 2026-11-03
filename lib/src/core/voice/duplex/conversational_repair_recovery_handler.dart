/// Task 1138: Spoken conversational repair & re-prompting handler
class ConversationalRepairHandler {
  String generateRepairPrompt(String lang) => lang == 'de' ? 'Könntest du das wiederholen?' : 'هل يمكنك إعادة ذلك؟';
}
