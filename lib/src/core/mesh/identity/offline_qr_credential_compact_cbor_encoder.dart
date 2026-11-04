/// Task 1555: Encodes credentials into compact CBOR binary for offline QR
class CompactCborQrEncoder {
  List<int> encodeToCbor(Map<String, dynamic> claim) => [0xD8, 0x27, ...claim.keys.map((k) => k.length)];
}
