import 'a1_german_arabic_bitext_corpus.dart';

/// Curated parallel B2 corpus exploring preventive healthcare, balanced nutrition, and circadian rhythm.
class B2PreventiveMedicineBitextCorpus {
  static const String corpusTitleDe = 'Präventivmedizin und ganzheitliche Gesundheitsförderung';
  static const String corpusTitleAr = 'الطب الوقائي وتعزيز الصحة الشاملة لجسم الإنسان';

  static const List<AlignedBitextPair> medicalParagraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Die moderne Präventivmedizin rückt die frühzeitige Erkennung von Risikofaktoren in den Mittelpunkt, um chronischen Erkrankungen wirksam vorzubeugen.',
      sentenceAr: 'يركز الطب الوقائي الحديث على الكشف المبكر عن عوامل الخطر بهدف الوقاية الفاعلة من الأمراض المزمنة قبل حدوثها.',
      iPlusOneNovelWords: ['die Präventivmedizin', 'die Risikofaktoren', 'vorbeugen'],
      grammarFocus: 'Infinitivkonstruktion mit "um... zu" & Dativ-Objekt (vorbeugen + Dat)',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Eine ausgewogene Ernährung, die reich an Ballaststoffen und natürlichen Vitaminen ist, stärkt das körpereigene Immunsystem nachhaltig.',
      sentenceAr: 'إن التغذية المتوازنة الغنية بالألياف الطبيعية والفيتامينات تعزز الجهاز المناعي للجسم بصورة مستدامة وقوية.',
      iPlusOneNovelWords: ['ausgewogen', 'die Ballaststoffe', 'das Immunsystem'],
      grammarFocus: 'Relativsatz im Nominativ & trennbare Zusammensetzungen (körper-eigen)',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Wissenschaftliche Studien belegen eindeutig, dass erholsamer Schlaf und regelmäßige körperliche Betätigung die zelluläre Regeneration beschleunigen.',
      sentenceAr: 'وتثبت الدراسات العلمية بشكل قاطع أن النوم المريح والنشاط البدني المنتظم يسرعان عملية التجدد الخلوي في الجسم.',
      iPlusOneNovelWords: ['eindeutig belegen', 'erholsam', 'die Regeneration'],
      grammarFocus: 'Dass-Satz mit akkumulierten Subjekten & Verb am Satzende',
    ),
  ];
}
