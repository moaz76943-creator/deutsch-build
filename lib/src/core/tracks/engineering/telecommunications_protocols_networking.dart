class TelecommunicationsProtocolsNetworking {
  const TelecommunicationsProtocolsNetworking();
  String latencyStatus(int ms) => ms < 50 ? 'استجابة فائقة السرعة' : 'زمن استجابة مقبول';
}
