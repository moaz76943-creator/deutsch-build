import 'a1_core_lexical_bank.dart';

/// Curated vocabulary bank for time expressions, weekdays, and punctuality values.
class A1A2TimeCalendarBank {
  static const List<LexicalEntry> calendarEntries = [
    LexicalEntry(
      germanWord: 'die Zeit',
      arabicMeaning: 'الوقت / الزمان',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Pünktlichkeit bedeutet, die Zeit anderer zu respektieren.',
      exampleSentenceAr: 'الانضباط بالمواعيد يعني احترام وقت الآخرين.',
    ),
    LexicalEntry(
      germanWord: 'heute',
      arabicMeaning: 'اليوم',
      partOfSpeech: 'adverb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Heute ist ein produktiver Tag zum Lernen.',
      exampleSentenceAr: 'اليوم يوم مثمر للتعلم.',
    ),
    LexicalEntry(
      germanWord: 'morgen',
      arabicMeaning: 'غداً',
      partOfSpeech: 'adverb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Morgen früh beginnt mein Deutschunterricht.',
      exampleSentenceAr: 'صباح الغد يبدأ درس اللغة الألمانية.',
    ),
    LexicalEntry(
      germanWord: 'der Termin',
      arabicMeaning: 'الموعد المحدد',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Ich habe einen wichtigen Termin um elf Uhr.',
      exampleSentenceAr: 'لدي موعد مهم عند الساعة الحادية عشرة.',
    ),
    LexicalEntry(
      germanWord: 'pünktlich',
      arabicMeaning: 'منضبط في الموعد / في الوقت تماماً',
      partOfSpeech: 'adjective',
      cefrLevel: 'A1',
      exampleSentenceDe: 'In Deutschland ist es sehr geschätzt, pünktlich zu sein.',
      exampleSentenceAr: 'في ألمانيا يُقدّر كثيراً أن تكون منضبطاً في الموعد.',
    ),
    LexicalEntry(
      germanWord: 'die Jahreszeit',
      arabicMeaning: 'فصل من فصول السنة',
      partOfSpeech: 'noun',
      cefrLevel: 'A2',
      exampleSentenceDe: 'Der Frühling ist eine wunderschöne Jahreszeit.',
      exampleSentenceAr: 'فصل الربيع فصل بديع وجميل.',
    ),
  ];

  static const List<String> weekdaysDe = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'
  ];

  static const List<String> weekdaysAr = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];
}
