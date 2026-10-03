import 'checkout_pfand_models.dart';

final class CheckoutPfandSubAgent {
  const CheckoutPfandSubAgent();

  List<CheckoutPhrase> get phrases => _phrases;

  List<CheckoutPhrase> search(String query) =>
      List<CheckoutPhrase>.unmodifiable(
        _phrases.where((phrase) => phrase.matches(query)),
      );

  static const List<CheckoutPhrase> _phrases = <CheckoutPhrase>[
    CheckoutPhrase(
      id: 'pfand-machine-use',
      kind: CheckoutSituation.pfand,
      topicDe: 'Pfandautomat benutzen',
      topicAr: 'استخدام ماكينة استرجاع العبوات',
      german:
          'Wo ist der Pfandautomat, und kann ich diese Flaschen dort zurückgeben?',
      arabic:
          'أين توجد ماكينة استرجاع العبوات، وهل يمكنني إعادة هذه القوارير فيها؟',
      keywords: <String>[
        'Pfandautomat',
        'Flaschen',
        'zurückgeben',
        'Pfand',
        'قوارير',
      ],
    ),
    CheckoutPhrase(
      id: 'pfand-machine-rejected',
      kind: CheckoutSituation.pfand,
      topicDe: 'Flasche wird nicht angenommen',
      topicAr: 'الماكينة ترفض العبوة',
      german:
          'Der Pfandautomat nimmt diese Flasche nicht an. Können Sie bitte prüfen, ob sie hier zurückgegeben werden kann?',
      arabic:
          'ماكينة استرجاع العبوات لا تقبل هذه القارورة. هل يمكنكم التحقق مما إذا كان يمكن إرجاعها هنا؟',
      keywords: <String>[
        'Pfandautomat',
        'nicht angenommen',
        'Flasche',
        'Rückgabe',
        'رفض',
      ],
    ),
    CheckoutPhrase(
      id: 'pfand-voucher-redeem',
      kind: CheckoutSituation.pfand,
      topicDe: 'Pfandbon an der Kasse einlösen',
      topicAr: 'صرف قسيمة العبوات عند الصندوق',
      german:
          'Kann ich diesen Pfandbon direkt an der Kasse einlösen?',
      arabic:
          'هل يمكنني صرف قسيمة استرجاع العبوات هذه مباشرة عند الصندوق؟',
      keywords: <String>['Pfandbon', 'Kasse', 'einlösen', 'قسيمة'],
    ),
    CheckoutPhrase(
      id: 'checkout-receipt',
      kind: CheckoutSituation.checkout,
      topicDe: 'Kassenbon',
      topicAr: 'إيصال الدفع',
      german: 'Könnte ich bitte den Kassenbon bekommen?',
      arabic: 'هل يمكنني الحصول على إيصال الدفع من فضلك؟',
      keywords: <String>['Kassenbon', 'Beleg', 'Kasse', 'وصل'],
    ),
    CheckoutPhrase(
      id: 'checkout-card',
      kind: CheckoutSituation.checkout,
      topicDe: 'Mit Karte bezahlen',
      topicAr: 'الدفع بالبطاقة',
      german: 'Kann ich mit Karte bezahlen?',
      arabic: 'هل يمكنني الدفع بالبطاقة؟',
      keywords: <String>['Karte', 'bezahlen', 'Kartenzahlung', 'بطاقة'],
    ),
    CheckoutPhrase(
      id: 'checkout-payback',
      kind: CheckoutSituation.checkout,
      topicDe: 'Payback-Punkte',
      topicAr: 'نقاط الولاء Payback',
      german:
          'Kann ich meine Payback-Karte verwenden und die Punkte für diesen Einkauf sammeln?',
      arabic:
          'هل يمكنني استخدام بطاقة Payback وجمع النقاط على عملية الشراء هذه؟',
      keywords: <String>['Payback', 'Punkte', 'Karte', 'Treuepunkte', 'نقاط'],
    ),
    CheckoutPhrase(
      id: 'return-wrong-item',
      kind: CheckoutSituation.returnExchange,
      topicDe: 'Falscher Artikel',
      topicAr: 'منتج خاطئ',
      german:
          'Ich habe versehentlich den falschen Artikel gekauft. Welche Möglichkeiten habe ich für die Rückgabe?',
      arabic:
          'اشتريت المنتج الخاطئ بالخطأ. ما الخيارات المتاحة لإرجاعه؟',
      keywords: <String>[
        'falsche',
        'Artikel',
        'Rückgabe',
        'zurückgeben',
        'إرجاع',
      ],
    ),
    CheckoutPhrase(
      id: 'return-exchange',
      kind: CheckoutSituation.returnExchange,
      topicDe: 'Umtausch',
      topicAr: 'استبدال المنتج',
      german:
          'Ich möchte diesen ungeöffneten Artikel umtauschen. Welche Bedingungen gelten dafür?',
      arabic:
          'أريد استبدال هذا المنتج غير المفتوح. ما الشروط المطبقة على الاستبدال؟',
      keywords: <String>['umtauschen', 'Umtausch', 'Bedingungen', 'استبدال'],
    ),
    CheckoutPhrase(
      id: 'return-refund',
      kind: CheckoutSituation.returnExchange,
      topicDe: 'Ware zurückgeben',
      topicAr: 'إرجاع البضاعة',
      german:
          'Ich möchte diese Ware zurückgeben. Brauche ich dafür den Kassenbon?',
      arabic:
          'أريد إرجاع هذه البضاعة. هل أحتاج إلى إيصال الدفع لذلك؟',
      keywords: <String>[
        'zurückgeben',
        'Rückgabe',
        'Kassenbon',
        'Erstattung',
        'إرجاع',
      ],
    ),
  ];
}
