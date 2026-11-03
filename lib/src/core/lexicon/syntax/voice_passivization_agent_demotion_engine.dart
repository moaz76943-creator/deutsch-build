class VoicePassivizationAgentDemotionEngine {
  String toPassive(String subject, String verb, String object, String lang) =>
      lang == 'ar' ? 'كُتِبَ $object' : '$object wurde geschrieben';
}
