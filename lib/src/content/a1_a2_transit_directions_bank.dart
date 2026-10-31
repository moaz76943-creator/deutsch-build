import 'a1_core_lexical_bank.dart';

/// Curated vocabulary bank for public transport and urban orientation.
class A1A2TransitDirectionsBank {
  static const List<LexicalEntry> entries = [
    LexicalEntry(
      germanWord: 'der Bahnhof',
      arabicMeaning: 'محطة القطار',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Wir treffen uns am Hauptbahnhof um zehn Uhr.',
      exampleSentenceAr: 'نلتقي في محطة القطارات المركزية عند الساعة العاشرة.',
    ),
    LexicalEntry(
      germanWord: 'der Zug',
      arabicMeaning: 'القطار',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Der Zug nach Frankfurt fährt auf Gleis 4 ab.',
      exampleSentenceAr: 'القطار المتجه إلى فرانكفورت ينطلق من الرصيف رقم 4.',
    ),
    LexicalEntry(
      germanWord: 'die Fahrkarte',
      arabicMeaning: 'تذكرة السفر / الركوب',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Ich kaufe eine Fahrkarte am Automaten.',
      exampleSentenceAr: 'أشتري تذكرة سفر من آلة التذاكر.',
    ),
    LexicalEntry(
      germanWord: 'geradeaus',
      arabicMeaning: 'إلى الأمام مباشرة',
      partOfSpeech: 'adverb',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Gehen Sie bitte geradeaus und dann nach links.',
      exampleSentenceAr: 'امشِ للأمام مباشرة ثم اتجه يساراً.',
    ),
    LexicalEntry(
      germanWord: 'die Haltestelle',
      arabicMeaning: 'موقف الحافلة أو الترام',
      partOfSpeech: 'noun',
      cefrLevel: 'A2',
      exampleSentenceDe: 'Die nächste Haltestelle heißt Stadtmitte.',
      exampleSentenceAr: 'الموقف التالي اسمه وسط المدينة.',
    ),
    LexicalEntry(
      germanWord: 'umsteigen',
      arabicMeaning: 'يبدل وسيلة المواصلات / يغير القطار',
      partOfSpeech: 'verb',
      cefrLevel: 'A2',
      exampleSentenceDe: 'In Hannover müssen wir in einen anderen Zug umsteigen.',
      exampleSentenceAr: 'في هانوفر يجب أن نبدل إلى قطار آخر.',
    ),
  ];

  List<LexicalEntry> searchByDirection() {
    return entries.where((e) => e.partOfSpeech == 'adverb' || e.germanWord.contains('Haltestelle')).toList();
  }
}
