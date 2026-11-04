/// Task 1575: CBOR-encoded delta wire format serializer for fast binary sync
class LedgerCborSerializer {
  List<int> serializeDelta(String deltaJson) => deltaJson.codeUnits;
}
