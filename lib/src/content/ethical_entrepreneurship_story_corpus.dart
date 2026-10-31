import 'a1_german_arabic_bitext_corpus.dart';

/// Graded interactive story corpus demonstrating ethical, debt-free software entrepreneurship.
class EthicalEntrepreneurshipStoryCorpus {
  static const String storyTitleDe = 'Der unabhängige Entwickler: Erfolg durch Ehrlichkeit und Eigenleistung';
  static const String storyTitleAr = 'المطور المستقل: النجاح بالأمانة والجهد الذاتي دون ديون ربوية';

  static const List<AlignedBitextPair> chapters = [
    AlignedBitextPair(
      pairId: 1,
      sentenceDe: 'Yasin beschloss, sein Softwareunternehmen vollkommen eigenfinanziert ohne zinsbelastete Kredite aufzubauen.',
      sentenceAr: 'قرر ياسين تأسيس شركته البرمجية بالتمويل الذاتي المستقل دون الوقوع في شباك القروض المصرفية الربوية.',
      iPlusOneNovelWords: ['eigenfinanziert', 'zinsbelastet', 'aufbauen'],
      grammarFocus: 'Infinitiv mit zu (aufzubauen) & zusammengesetzte Adjektive',
    ),
    AlignedBitextPair(
      pairId: 2,
      sentenceDe: 'Anstatt auf spekulative Investoren zu warten, entwickelte er Schritt für Schritt ein nützliches Produkt, das echten Mehrwert stiftete.',
      sentenceAr: 'وعوضاً عن انتظار المستثمرين والمضاربات المالية، عكف خطوة بخطوة على تطوير تطبيق نافع يقدم قيمة حقيقية للناس.',
      iPlusOneNovelWords: ['spekulativ', 'Mehrwert stiften', 'Schritt für Schritt'],
      grammarFocus: 'Anstatt... zu + Infinitiv (بدلاً من أن...) & Relativsatz im Präteritum',
    ),
    AlignedBitextPair(
      pairId: 3,
      sentenceDe: 'Dank seiner transparenten Geschäftsethik und exzellenten Qualität gewann er rasch treue und zufriedene Kunden in ganz Europa.',
      sentenceAr: 'وبفضل أخلاقياته المهنية الشفافة وجودة عمله الفائقة، كسب سريعاً ثقة عملاء مخلصين وراضين في كافة أرجاء أوروبا.',
      iPlusOneNovelWords: ['die Geschäftsethik', 'treu', 'europaweit'],
      grammarFocus: 'Genitiv nach der Präposition "Dank" (Dank seiner Ethik)',
    ),
  ];
}
