class CefrA1SpeakingPart3PoliteRequests {
  const CefrA1SpeakingPart3PoliteRequests();
  String formulateRequest(String item, String lang) =>
      lang == 'ar' ? 'من فضلك، هل يمكنني الحصول على $item؟' : 'Could I please have $item?';
}
