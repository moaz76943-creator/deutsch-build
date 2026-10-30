import 'a1_core_lexical_bank.dart';

/// Specialized vocabulary bank covering wholesome family life, household, and halal food.
class A1FamilyHomeHalalBank {
  static const List<LexicalEntry> items = [
    LexicalEntry(
      germanWord: 'die Familie',
      arabicMeaning: 'العائلة / الأسرة',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Meine Familie ist mir sehr wichtig.',
      exampleSentenceAr: 'عائلتي مهمة جداً بالنسبة لي.',
    ),
    LexicalEntry(
      germanWord: 'die Eltern',
      arabicMeaning: 'الوالدان',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Ich respektiere und ehre meine Eltern.',
      exampleSentenceAr: 'أنا أحترم وأبر والديّ.',
    ),
    LexicalEntry(
      germanWord: 'das Wasser',
      arabicMeaning: 'الماء',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Frisches Wasser ist gesund für den Körper.',
      exampleSentenceAr: 'الماء النقي صحي للجسم.',
    ),
    LexicalEntry(
      germanWord: 'das Brot',
      arabicMeaning: 'الخبز',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Wir essen morgens frisches Brot mit Honig.',
      exampleSentenceAr: 'نأكل في الصباح خبزاً طازجاً مع العسل.',
    ),
    LexicalEntry(
      germanWord: 'das Obst',
      arabicMeaning: 'الفواكه',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Äpfel und Feigen sind köstliches Obst.',
      exampleSentenceAr: 'التفاح والتين فواكه لذيذة.',
    ),
    LexicalEntry(
      germanWord: 'das Gemüse',
      arabicMeaning: 'الخضروات',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Frisches Gemüse stärkt die Gesundheit.',
      exampleSentenceAr: 'الخضروات الطازجة تقوي الصحة.',
    ),
    LexicalEntry(
      germanWord: 'das Haus',
      arabicMeaning: 'البيت / المنزل',
      partOfSpeech: 'noun',
      cefrLevel: 'A1',
      exampleSentenceDe: 'Unser Haus ist sauber und friedlich.',
      exampleSentenceAr: 'منزلنا نظيف وهادئ.',
    ),
  ];

  /// Filters items by grammatical part of speech.
  List<LexicalEntry> getByPartOfSpeech(String pos) {
    return items.where((e) => e.partOfSpeech.toLowerCase() == pos.toLowerCase()).toList();
  }
}
