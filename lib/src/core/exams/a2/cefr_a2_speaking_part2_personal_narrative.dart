class CefrA2SpeakingPart2PersonalNarrative {
  const CefrA2SpeakingPart2PersonalNarrative();
  String narrativePrompt(String topic, String lang) =>
      lang == 'ar' ? 'تحدث عن تجربتك في: $topic وماذا حدث معك.' : 'Tell us about your experience with: $topic.';
}
