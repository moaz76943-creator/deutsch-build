/// Task 1933: Conversational repair engine generating scaffolding clarifications
class ConversationalRepairEngine {
  String generateRepairPrompt(String failedUtterance, String lang) => lang == 'de' ? 'Könnten Sie das bitte anders formulieren?' : 'هل يمكنك إعادة صياغة ذلك؟';
}
