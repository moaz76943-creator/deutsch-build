import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Real Deterministic Merkle Root Calculator replacing fake constant
class MerkleSearchTreeSyncProtocol {
  String computeRootHash(List<String> hashes) {
    if (hashes.isEmpty) throw ArgumentError('Empty hash list cannot form a Merkle root');
    final validHex = RegExp(r'^[0-9a-fA-F]{64}$');
    for (final h in hashes) {
      if (!validHex.hasMatch(h)) throw FormatException('Invalid SHA-256 leaf hash: $h');
    }

    List<String> currentLayer = List<String>.from(hashes);
    while (currentLayer.length > 1) {
      final List<String> nextLayer = [];
      for (int i = 0; i < currentLayer.length; i += 2) {
        if (i + 1 < currentLayer.length) {
          final combined = utf8.encode('${currentLayer[i]}:${currentLayer[i + 1]}');
          nextLayer.add(sha256.convert(combined).toString());
        } else {
          nextLayer.add(currentLayer[i]);
        }
      }
      currentLayer = nextLayer;
    }
    return currentLayer.first;
  }
}
