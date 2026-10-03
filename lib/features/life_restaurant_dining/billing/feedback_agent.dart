import 'billing_models.dart';

final class FeedbackAgent {
  const FeedbackAgent();

  List<BillingPhrase> get phrases => _phrases;

  static const List<BillingPhrase> _phrases = <BillingPhrase>[
    BillingPhrase(
      id: 'feedback-satisfied',
      kind: BillingPhraseKind.feedback,
      german: 'Es hat sehr gut geschmeckt, vielen Dank.',
      arabic: 'كان الطعام لذيذاً جداً، شكراً جزيلاً.',
      contextDe: 'Zufriedenheit freundlich ausdrücken',
      contextAr: 'التعبير عن الرضا بلباقة',
      keywords: <String>['geschmeckt', 'zufrieden', 'danke'],
    ),
    BillingPhrase(
      id: 'feedback-wrong-order',
      kind: BillingPhraseKind.feedback,
      german:
          'Entschuldigung, ich glaube, ich habe etwas anderes bestellt. Könnten Sie das bitte prüfen?',
      arabic: 'عذراً، أعتقد أنني طلبت شيئاً آخر. هل يمكنكم التحقق من ذلك؟',
      contextDe: 'Eine falsche Bestellung sachlich melden',
      contextAr: 'الإبلاغ عن خطأ في الطلب دون تصعيد',
      keywords: <String>['falsch', 'bestellt', 'prüfen', 'Bestellung'],
    ),
    BillingPhrase(
      id: 'feedback-cold-food',
      kind: BillingPhraseKind.feedback,
      german:
          'Entschuldigung, das Essen ist leider kalt. Könnten Sie das bitte noch einmal prüfen?',
      arabic: 'عذراً، الطعام بارد للأسف. هل يمكنكم التحقق منه من فضلكم؟',
      contextDe: 'Kaltes Essen höflich ansprechen',
      contextAr: 'الإبلاغ بلباقة عن الطعام البارد',
      keywords: <String>['kalt', 'Essen', 'prüfen'],
    ),
  ];
}
