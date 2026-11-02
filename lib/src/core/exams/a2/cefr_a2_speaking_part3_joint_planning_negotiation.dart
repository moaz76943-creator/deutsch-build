class CefrA2SpeakingPart3JointPlanningNegotiation {
  const CefrA2SpeakingPart3JointPlanningNegotiation();
  String suggestTime(String time, String lang) =>
      lang == 'ar' ? 'ما رأيك أن نلتقي عند الساعة $time؟' : 'How about meeting at $time?';
}
