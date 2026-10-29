import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/printable_summary_exporter.dart';

void main() {
  group('PrintableSummaryExporter Tests', () {
    const exporter = PrintableSummaryExporter();

    final testSnapshot = WeeklyMasterySnapshot(
      weekLabel: 'Week 42 - 2026',
      targetLanguage: 'de',
      wordsLearned: 35,
      retentionRate: 0.92,
      totalStudyMinutes: 210,
      priorityCards: [
        const StudyCardExportItem(
          frontTerm: 'der Baum',
          backMeaning: 'the tree',
          phoneticIpa: 'baʊ̯m',
          exampleSentence: 'Der Baum ist grün.',
        ),
        const StudyCardExportItem(
          frontTerm: 'die Blume',
          backMeaning: 'the flower',
          phoneticIpa: 'ˈbluːmə',
          exampleSentence: 'Die Blume duftet gut.',
        ),
      ],
    );

    test('Markdown summary renders clean table and headers', () {
      final md = exporter.exportMarkdownSummary(testSnapshot);

      expect(md, contains('# 📚 Polyglot Weekly Study Digest'));
      expect(md, contains('| **der Baum** | `/baʊ̯m/` | the tree | *Der Baum ist grün.* |'));
      expect(md, contains('Retention Rate: 92.0%'));
    });

    test('Printable cutout grid renders card boundaries with cut indicators', () {
      final cutout = exporter.exportPrintableFlashcardCutoutGrid(testSnapshot.priorityCards);

      expect(cutout, contains('PRINTABLE FLASHCARD CUT-OUT SHEET'));
      expect(cutout, contains('+-----------------------------------+'));
      expect(cutout, contains('der Baum'));
    });

    test('Encrypted backup successfully encrypts and decrypts with secret passphrase', () {
      const secret = 'MySuperMasterKey2026';
      final encrypted = exporter.exportEncryptedBackup(testSnapshot, secret);

      expect(encrypted.isNotEmpty, isTrue);
      expect(encrypted, isNot(contains('der Baum')));

      final decrypted = exporter.decryptBackup(encrypted, secret);
      expect(decrypted['weekLabel'], equals('Week 42 - 2026'));
      expect(decrypted['wordsLearned'], equals(35));
      expect(decrypted['cards'].length, equals(2));
      expect(decrypted['cards'][0]['frontTerm'], equals('der Baum'));
    });
  });
}
