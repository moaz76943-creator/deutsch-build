import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// An atomic progress record synchronized across personal devices.
class SyncProgressItem {
  final String itemId;
  final int repetitionCount;
  final double stability;
  final int lastReviewedTimestamp;

  const SyncProgressItem({
    required this.itemId,
    required this.repetitionCount,
    required this.stability,
    required this.lastReviewedTimestamp,
  });

  Map<String, dynamic> toJson() => {
    'i': itemId,
    'r': repetitionCount,
    's': stability,
    't': lastReviewedTimestamp,
  };

  factory SyncProgressItem.fromJson(Map<String, dynamic> json) => SyncProgressItem(
    itemId: json['i'] as String,
    repetitionCount: json['r'] as int,
    stability: (json['s'] as num).toDouble(),
    lastReviewedTimestamp: json['t'] as int,
  );
}

/// Zero-cloud, peer-to-peer sync engine using Last-Write-Wins (LWW) conflict resolution.
class P2pEncryptedProgressSync {
  final Uint8List sharedPairingSecret;

  P2pEncryptedProgressSync({required this.sharedPairingSecret});

  /// Encrypts sync snapshot bundle.
  Uint8List packAndEncryptSnapshot(List<SyncProgressItem> items) {
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    final plainBytes = utf8.encode(jsonStr);
    final cipher = Uint8List(plainBytes.length);

    for (int i = 0; i < plainBytes.length; i++) {
      cipher[i] = plainBytes[i] ^ sharedPairingSecret[i % sharedPairingSecret.length];
    }
    return cipher;
  }

  /// Decrypts sync snapshot bundle.
  List<SyncProgressItem> decryptAndUnpackSnapshot(Uint8List encryptedBytes) {
    final decrypted = Uint8List(encryptedBytes.length);
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted[i] = encryptedBytes[i] ^ sharedPairingSecret[i % sharedPairingSecret.length];
    }

    final jsonStr = utf8.decode(decrypted);
    final rawList = jsonDecode(jsonStr) as List;
    return rawList.map((e) => SyncProgressItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Reconciles local items with incoming peer items using Last-Write-Wins (LWW).
  List<SyncProgressItem> reconcile({
    required List<SyncProgressItem> localItems,
    required List<SyncProgressItem> incomingItems,
  }) {
    final Map<String, SyncProgressItem> map = {
      for (final item in localItems) item.itemId: item
    };

    for (final inc in incomingItems) {
      if (!map.containsKey(inc.itemId)) {
        map[inc.itemId] = inc;
      } else {
        // Last-Write-Wins based on timestamp
        final local = map[inc.itemId]!;
        if (inc.lastReviewedTimestamp > local.lastReviewedTimestamp) {
          map[inc.itemId] = inc;
        }
      }
    }

    return map.values.toList();
  }
}
