import 'social_models.dart';

final class NeighborhoodSubAgent {
  const NeighborhoodSubAgent();

  List<SocialPhrase> get phrases => _phrases;

  static const List<SocialPhrase> _phrases = <SocialPhrase>[
    SocialPhrase(
      id: 'neighborhood-quiet-hours',
      category: SocialCategory.neighborhood,
      germanDu:
          'Könntest du bitte ab 22 Uhr etwas leiser sein? Vielen Dank.',
      germanSie:
          'Könnten Sie bitte ab 22 Uhr etwas leiser sein? Vielen Dank.',
      arabic: 'هل يمكنك خفض الصوت قليلًا بعد الساعة العاشرة؟ شكرًا لك.',
      contextDe: 'Ruhezeiten freundlich ansprechen',
      contextAr: 'طلب هادئ ومحترم بخصوص أوقات الهدوء',
      keywords: <String>['Ruhezeiten', 'Ruhe', 'leiser', 'Nachtruhe'],
    ),
    SocialPhrase(
      id: 'neighborhood-package-courtesy',
      category: SocialCategory.neighborhood,
      germanDu: 'Danke, dass du mein Paket angenommen hast.',
      germanSie: 'Vielen Dank, dass Sie mein Paket angenommen haben.',
      arabic: 'شكرًا لاستلام طردي نيابةً عني.',
      contextDe: 'Höflich für die Paketannahme danken',
      contextAr: 'شكر الجار على استلام الطرد',
      keywords: <String>['Paket', 'Paketannahme', 'Nachbar'],
    ),
    SocialPhrase(
      id: 'neighborhood-house-rules',
      category: SocialCategory.neighborhood,
      germanDu: 'Weißt du, was die Hausordnung dazu sagt?',
      germanSie:
          'Könnten Sie mir bitte sagen, was die Hausordnung dazu vorsieht?',
      arabic: 'هل يمكنك إخباري بما تنص عليه قواعد المنزل في هذا الأمر؟',
      contextDe: 'Sachlich nach der Hausordnung fragen',
      contextAr: 'السؤال عن قواعد المبنى دون تصعيد',
      keywords: <String>['Hausordnung', 'Regeln', 'Treppenhaus'],
    ),
    SocialPhrase(
      id: 'neighborhood-boundary',
      category: SocialCategory.neighborhood,
      germanDu:
          'Bitte stell deine Sachen nicht vor meine Tür. Danke für dein Verständnis.',
      germanSie:
          'Bitte stellen Sie Ihre Sachen nicht vor meine Tür. Vielen Dank für Ihr Verständnis.',
      arabic: 'من فضلك لا تضع أغراضك أمام بابي. شكرًا لتفهمك.',
      contextDe: 'Eine persönliche Grenze höflich formulieren',
      contextAr: 'وضع حدود واضحة باحترام',
      keywords: <String>['Grenze', 'Tür', 'Rücksicht', 'Flur'],
    ),
  ];
}
