import 'a1_german_arabic_bitext_corpus.dart';

/// Curated parallel B2 corpus exploring environmental sustainability, green technologies, and civic responsibility.
class B2GermanArabicBitextCorpus {
  static const String corpusTitleDe = 'Nachhaltige Energiewende und bürgerschaftliches Engagement';
  static const String corpusTitleAr = 'التحول نحو الطاقة المستدامة والمبادرات المجتمعية الفاعلة';

  static const List<AlignedBitextPair> b2Paragraphs = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Die schrittweise Umstellung auf regenerative Energiequellen stellt nicht nur eine technische Herausforderung dar, sondern verlangt ein kollektives Umdenken.',
      sentenceAr: 'إن التحول التدريجي نحو مصادر الطاقة المتجددة لا يمثل تحدياً تقنياً فحسب، بل يتطلب تغييراً جماعياً في نمط التفكير والسلوك اليومي.',
      iPlusOneNovelWords: ['die Umstellung', 'regenerativ', 'kollektives Umdenken'],
      grammarFocus: 'Doppelkonjunktionen (nicht nur... sondern auch)',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Durch die Installation dezentraler Solaranlagen auf privaten Hausdächern wird ein beträchtlicher Teil des lokalen Strombedarfs emissionsfrei erzeugt.',
      sentenceAr: 'ومن خلال تركيب أنظمة طاقة شمسية لا مركزية على أسطح المنازل، يتم توليد جزء كبير وملموس من الاحتياج المحلي للكهرباء دون انبعاثات ضارة.',
      iPlusOneNovelWords: ['dezentral', 'beträchtlich', 'emissionsfrei'],
      grammarFocus: 'Zustandspassiv und Vorgangspassiv im Präsens (wird erzeugt)',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Experten betonen, dass eine verlässliche Energiesicherheit langfristig nur durch intelligente Speichertechnologien gewährleistet werden kann.',
      sentenceAr: 'ويؤكد الخبراء أن أمن الطاقة الموثوق لا يمكن ضمانه على المدى البعيد إلا من خلال تقنيات تخزين الطاقة الذكية والمتقدمة.',
      iPlusOneNovelWords: ['die Energiesicherheit', 'langfristig', 'gewährleisten'],
      grammarFocus: 'Passiv mit Modalverben im Nebensatz (gewährleistet werden kann)',
    ),
  ];
}
