import 'a1_german_arabic_bitext_corpus.dart';

/// Graded interactive story corpus demonstrating inter-cultural academic dialogue and scholarly manuscripts.
class CivilizationalDialogueStoryCorpus {
  static const String storyTitleDe = 'Das Kolloquium der Gelehrten: Universale Wissenschaft und Brücken des Verstehens';
  static const String storyTitleAr = 'ندوة العلماء الكبرى: شمولية العلم وجسور التفاهم الإنساني';

  static const List<AlignedBitextPair> scholarlyChapters = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Auf dem internationalen Wissenschaftskongress in Heidelberg versammelten sich renommierte Forscher aus Europa und dem Orient, um gemeinsame medizinhistorische Handschriften zu analysieren.',
      sentenceAr: 'في المؤتمر العلمي الدولي بمدينة هايدلبرغ، اجتمع باحثون مرموقون من أوروبا والمشرق العربي لدراسة مخطوطات تاريخية مشتركة في علوم الطب والصيدلة.',
      iPlusOneNovelWords: ['der Wissenschaftskongress', 'renommiert', 'die Handschrift'],
      grammarFocus: 'Finalkonstruktion mit "um... zu" & zusammengesetzte Substantive (medizinhistorisch)',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Die Gelehrten stellten fest, dass die akribische Dokumentation von Heilpflanzen im arabischen Andalusien das Fundament für die frühe mitteleuropäische Botanik legte.',
      sentenceAr: 'وتوصل العلماء إلى أن التوثيق الدقيق للأعشاب الطبية في الأندلس الإسلامية شكّل حجر الأساس لعلم النبات المبكر في وسط أوروبا.',
      iPlusOneNovelWords: ['akribisch', 'das Fundament legen', 'die Botanik'],
      grammarFocus: 'Erweiterte dass-Sätze im Präteritum & präpositionale Attribute',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'In einem Geist gegenseitiger Hochachtung betonten alle Teilnehmer, dass wahre Erkenntnis keine geographischen Grenzen kennt, sondern ein universales Erbe der Menschheit darstellt.',
      sentenceAr: 'وفي أجواء مفعمة بالتقدير والاحترام المتبادل، أكد جميع المشاركين أن المعرفة الحقيقية لا تحدها حدود جغرافية، بل تمثل إرثاً إنسانياً مشتركاً لكافة الشعوب.',
      iPlusOneNovelWords: ['die Hochachtung', 'universales Erbe', 'geographische Grenzen'],
      grammarFocus: 'Gehobene Satzkonstruktion mit "sondern" & Prädikatsklammer im Konjunktiv I/Präsens',
    ),
  ];
}
