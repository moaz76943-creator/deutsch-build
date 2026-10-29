import 'dart:convert';

class StudyCardExportItem {
  final String frontTerm;
  final String backMeaning;
  final String phoneticIpa;
  final String exampleSentence;

  const StudyCardExportItem({
    required this.frontTerm,
    required this.backMeaning,
    required this.phoneticIpa,
    required this.exampleSentence,
  });

  Map<String, String> toJson() => {
    'frontTerm': frontTerm,
    'backMeaning': backMeaning,
    'phoneticIpa': phoneticIpa,
    'exampleSentence': exampleSentence,
  };
}

class WeeklyMasterySnapshot {
  final String weekLabel;
  final String targetLanguage;
  final int wordsLearned;
  final double retentionRate;
  final int totalStudyMinutes;
  final List<StudyCardExportItem> priorityCards;

  const WeeklyMasterySnapshot({
    required this.weekLabel,
    required this.targetLanguage,
    required this.wordsLearned,
    required this.retentionRate,
    required this.totalStudyMinutes,
    required this.priorityCards,
  });
}

class PrintableSummaryExporter {
  const PrintableSummaryExporter();

  /// Generates clean, printer-friendly Markdown study summary.
  String exportMarkdownSummary(WeeklyMasterySnapshot snapshot) {
    final buffer = StringBuffer();
    buffer.writeln('# 📚 Polyglot Weekly Study Digest: ${snapshot.weekLabel}');
    buffer.writeln('**Language:** ${snapshot.targetLanguage.toUpperCase()} | **Retention Rate:** ${(snapshot.retentionRate * 100).toStringAsFixed(1)}% | **Time:** ${snapshot.totalStudyMinutes} mins\n');
    buffer.writeln('## 🎯 Key Vocabulary & Focus Items');
    buffer.writeln('| Term | IPA | Meaning | Example Sentence |');
    buffer.writeln('| :--- | :--- | :--- | :--- |');

    for (final card in snapshot.priorityCards) {
      buffer.writeln('| **${card.frontTerm}** | `/${card.phoneticIpa}/` | ${card.backMeaning} | *${card.exampleSentence}* |');
    }

    buffer.writeln('\n---\n*Generated offline by Polyglot Sovereign Core. No telemetry collected.*');
    return buffer.toString();
  }

  /// Generates a printable 2-column scissors cut-out flashcard template.
  String exportPrintableFlashcardCutoutGrid(List<StudyCardExportItem> cards) {
    final buffer = StringBuffer();
    buffer.writeln('✂️ PRINTABLE FLASHCARD CUT-OUT SHEET (Double-Sided / Foldable)');
    buffer.writeln('=' * 72);

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      buffer.writeln('+-----------------------------------+-----------------------------------+');
      buffer.writeln('| FRONT:                            | BACK:                             |');
      buffer.writeln('| ${card.frontTerm.padRight(34)}| ${card.backMeaning.padRight(34)}|');
      buffer.writeln('| IPA: /${card.phoneticIpa.padRight(28)}/| Ex: ${card.exampleSentence.padRight(30)}|');
      buffer.writeln('+-----------------------------------+-----------------------------------+');
    }

    return buffer.toString();
  }

  /// Encrypts learner study snapshot into sovereign encrypted base64 payload.
  String exportEncryptedBackup(WeeklyMasterySnapshot snapshot, String passphrase) {
    if (passphrase.isEmpty) {
      throw ArgumentError('Passphrase cannot be empty.');
    }

    final rawJson = jsonEncode({
      'weekLabel': snapshot.weekLabel,
      'targetLanguage': snapshot.targetLanguage,
      'wordsLearned': snapshot.wordsLearned,
      'retentionRate': snapshot.retentionRate,
      'totalStudyMinutes': snapshot.totalStudyMinutes,
      'cards': snapshot.priorityCards.map((c) => c.toJson()).toList(),
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    });

    final payloadBytes = utf8.encode(rawJson);
    final keyBytes = utf8.encode(passphrase);

    // Symmetric stream XOR masking with rotating key bytes for sovereign offline portability
    final masked = List<int>.generate(payloadBytes.length, (i) {
      return payloadBytes[i] ^ keyBytes[i % keyBytes.length];
    });

    return base64Encode(masked);
  }

  /// Decrypts sovereign backup payload.
  Map<String, dynamic> decryptBackup(String encryptedBase64, String passphrase) {
    final masked = base64Decode(encryptedBase64);
    final keyBytes = utf8.encode(passphrase);

    final unmasked = List<int>.generate(masked.length, (i) {
      return masked[i] ^ keyBytes[i % keyBytes.length];
    });

    final jsonStr = utf8.decode(unmasked);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
