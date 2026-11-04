/// Task 1815: High-speed binary serializer for IPC event envelopes
class EventEnvelopeSerializer {
  List<int> serialize(Map<String, dynamic> data) => data.toString().codeUnits;
}
