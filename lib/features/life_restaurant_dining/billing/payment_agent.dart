import 'billing_models.dart';

final class PaymentAgent {
  const PaymentAgent();

  List<BillingPhrase> get phrases => _phrases;

  static const List<BillingPhrase> _phrases = <BillingPhrase>[
    BillingPhrase(
      id: 'bill-request',
      kind: BillingPhraseKind.payment,
      german: 'Die Rechnung, bitte.',
      arabic: 'الحساب، من فضلك.',
      contextDe: 'Höflich um die Rechnung bitten',
      contextAr: 'طلب الحساب بلباقة',
      keywords: <String>['Rechnung', 'zahlen', 'bezahlen'],
    ),
    BillingPhrase(
      id: 'bill-together',
      kind: BillingPhraseKind.payment,
      german: 'Wir zahlen zusammen, bitte.',
      arabic: 'سندفع معاً، من فضلك.',
      contextDe: 'Eine gemeinsame Rechnung bezahlen',
      contextAr: 'دفع الحساب معاً',
      keywords: <String>['zusammen', 'gemeinsam', 'Rechnung'],
    ),
    BillingPhrase(
      id: 'bill-separate',
      kind: BillingPhraseKind.payment,
      german: 'Wir zahlen getrennt, bitte.',
      arabic: 'سندفع بشكل منفصل، من فضلك.',
      contextDe: 'Getrennte Zahlungen ankündigen',
      contextAr: 'طلب تقسيم الدفع',
      keywords: <String>['getrennt', 'separat', 'Rechnung'],
    ),
    BillingPhrase(
      id: 'payment-card',
      kind: BillingPhraseKind.payment,
      german: 'Kann ich mit Karte bezahlen?',
      arabic: 'هل يمكنني الدفع بالبطاقة؟',
      contextDe: 'Kartenzahlung erfragen',
      contextAr: 'الاستفسار عن الدفع بالبطاقة',
      keywords: <String>['Karte', 'Kartenzahlung', 'bezahlen'],
    ),
    BillingPhrase(
      id: 'payment-cash',
      kind: BillingPhraseKind.payment,
      german: 'Ich zahle bar.',
      arabic: 'سأدفع نقداً.',
      contextDe: 'Barzahlung ankündigen',
      contextAr: 'تحديد الدفع نقداً',
      keywords: <String>['bar', 'Bargeld', 'zahlen'],
    ),
  ];
}
