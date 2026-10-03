import 'billing_models.dart';

final class TippingAgent {
  const TippingAgent();

  String get cultureNoteDe =>
      'Trinkgeld ist freiwillig. Wenn Sie Trinkgeld geben möchten, können Sie beim Bezahlen den gewünschten Gesamtbetrag nennen.';

  String get cultureNoteAr =>
      'الإكرامية اختيارية. إذا أردت تقديمها يمكنك ذكر المبلغ الإجمالي الذي تريد دفعه عند الحساب.';

  String roundedTotalPhrase(int euro) {
    if (euro <= 0) {
      throw ArgumentError.value(euro, 'euro', 'must be greater than zero');
    }
    return 'Machen Sie bitte $euro Euro.';
  }

  List<BillingPhrase> get phrases => _phrases;

  static const List<BillingPhrase> _phrases = <BillingPhrase>[
    BillingPhrase(
      id: 'tip-stimmt-so',
      kind: BillingPhraseKind.tipping,
      german: 'Stimmt so, danke.',
      arabic: 'الباقي لك، شكراً.',
      contextDe: 'Den gegebenen Betrag als Endbetrag bestätigen',
      contextAr: 'إبلاغ النادل بأن المبلغ المدفوع هو المبلغ النهائي',
      keywords: <String>['Stimmt so', 'Trinkgeld', 'danke'],
    ),
    BillingPhrase(
      id: 'tip-round-total',
      kind: BillingPhraseKind.tipping,
      german: 'Machen Sie bitte 32 Euro.',
      arabic: 'اجعل المبلغ 32 يورو، من فضلك.',
      contextDe: 'Beim Bezahlen einen gewünschten Gesamtbetrag nennen',
      contextAr: 'ذكر مبلغ إجمالي محدد عند الدفع',
      keywords: <String>['Machen Sie', 'Gesamtbetrag', 'aufrunden'],
    ),
  ];
}
