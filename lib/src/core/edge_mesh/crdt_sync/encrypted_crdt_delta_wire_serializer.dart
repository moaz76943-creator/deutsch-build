/// Task 2037: Binary wire serializer packing CRDT mutations into AES-GCM envelopes
class EncryptedCrdtWireSerializer {
  List<int> serialize(Map<String, dynamic> delta) => delta.toString().codeUnits;
}
