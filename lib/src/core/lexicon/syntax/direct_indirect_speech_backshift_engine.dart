class DirectIndirectSpeechBackshiftEngine {
  String toReportedSpeech(String speaker, String statement, String lang) =>
      lang == 'ar' ? 'صرّح $speaker بأنه $statement' : '$speaker sagte, dass $statement';
}
