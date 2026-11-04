class CefrA2WritingPart1SmsMessagingScenarios {
  int evaluateSms(String text) => text.trim().split(' ').length >= 20 ? 10 : 5;
}
