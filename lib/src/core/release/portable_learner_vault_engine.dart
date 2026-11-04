import 'dart:convert';
import 'dart:typed_data';

class LearnerExportPayload {
  final String learnerId;
  final int totalMasteredCards;
  final int totalReviewTurns;
  final double retentionAverage;
  final List<String> activeLanguages;
  final String rawDatabaseDumpJson;

  const LearnerExportPayload({
    required this.learnerId,
    required this.totalMasteredCards,
    required this.totalReviewTurns,
    required this.retentionAverage,
    required this.activeLanguages,
    required this.rawDatabaseDumpJson,
  });

  Map<String, dynamic> toJson() => {
    'learnerId': learnerId,
    'totalMasteredCards': totalMasteredCards,
    'totalReviewTurns': totalReviewTurns,
    'retentionAverage': retentionAverage,
    'activeLanguages': activeLanguages,
    'rawDatabaseDumpJson': rawDatabaseDumpJson,
  };
}

class PortableLearnerVaultEngine {
  static const String vaultMagicHeader = 'POLYGLOT_VAULT_V3';

  const PortableLearnerVaultEngine();

  /// Compiles learner data into a single encrypted sovereign .polyglot container file.
  Uint8List exportToPortableVault({
    required LearnerExportPayload payload,
    required String userPassphrase,
  }) {
    if (userPassphrase.isEmpty) {
      throw ArgumentError('Passphrase cannot be empty.');
    }

    final rawJson = jsonEncode(payload.toJson());
    final rawBytes = utf8.encode(rawJson);
    final keyBytes = utf8.encode(userPassphrase);

    // Symmetric stream encryption with rotating key bytes
    final encryptedData = Uint8List(rawBytes.length);
    int checksumAcc = 0;
    for (int i = 0; i < rawBytes.length; i++) {
      final encryptedByte = rawBytes[i] ^ keyBytes[i % keyBytes.length];
      encryptedData[i] = encryptedByte;
      checksumAcc = (checksumAcc * 31 + encryptedByte) & 0x7FFFFFFF;
    }

    final headerBytes = utf8.encode('$vaultMagicHeader|chk_${checksumAcc.toRadixString(16)}|');
    final combined = Uint8List(headerBytes.length + encryptedData.length);
    combined.setRange(0, headerBytes.length, headerBytes);
    combined.setRange(headerBytes.length, combined.length, encryptedData);

    return combined;
  }

  /// Restores learner state from encrypted .polyglot vault container.
  LearnerExportPayload importFromPortableVault({
    required Uint8List vaultBytes,
    required String userPassphrase,
  }) {
    final headerStr = utf8.decode(vaultBytes.sublist(0, 36), allowMalformed: true);
    if (!headerStr.startsWith(vaultMagicHeader)) {
      throw const FormatException('Invalid file format: Missing POLYGLOT_VAULT_V3 magic header.');
    }

    final separatorIndex = vaultBytes.indexOf(124, 20); // Find second '|' delimiter
    final encryptedData = vaultBytes.sublist(separatorIndex + 1);
    final keyBytes = utf8.encode(userPassphrase);

    final decryptedBytes = Uint8List(encryptedData.length);
    for (int i = 0; i < encryptedData.length; i++) {
      decryptedBytes[i] = encryptedData[i] ^ keyBytes[i % keyBytes.length];
    }

    try {
      final decryptedJson = utf8.decode(decryptedBytes);
      final map = jsonDecode(decryptedJson) as Map<String, dynamic>;

      return LearnerExportPayload(
        learnerId: map['learnerId'] as String,
        totalMasteredCards: map['totalMasteredCards'] as int,
        totalReviewTurns: map['totalReviewTurns'] as int,
        retentionAverage: (map['retentionAverage'] as num).toDouble(),
        activeLanguages: List<String>.from(map['activeLanguages'] as List),
        rawDatabaseDumpJson: map['rawDatabaseDumpJson'] as String,
      );
    } catch (_) {
      throw const FormatException('Decryption failed: Incorrect passphrase or corrupted vault file.');
    }
  }
}
