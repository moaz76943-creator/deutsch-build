import '../postal_models.dart';
import 'shipping_models.dart';

final class ShippingSubAgent {
  const ShippingSubAgent();

  List<ShippingPhrase> get phrases => _phrases;

  static const List<ShippingPhrase> _phrases = <ShippingPhrase>[
    ShippingPhrase(
      id: 'shipping-stamp-label',
      scenario: ShippingScenario.send,
      german:
          'Ich möchte eine Briefmarke beziehungsweise ein Versandlabel kaufen. Welche Frankierung brauche ich dafür?',
      arabic:
          'أريد شراء طابع بريدي أو ملصق شحن. ما قيمة التخليص البريدي التي أحتاجها؟',
      contextDe: 'Briefmarke oder Versandlabel kaufen',
      contextAr: 'شراء طابع أو ملصق شحن قبل الإرسال',
      carriers: <PostalCarrier>[
        PostalCarrier.deutschePost,
        PostalCarrier.dhl,
        PostalCarrier.hermes,
      ],
      keywords: <String>[
        'Briefmarke',
        'Versandlabel',
        'Frankierung',
        'Porto',
      ],
    ),
    ShippingPhrase(
      id: 'shipping-registered-return-receipt',
      scenario: ShippingScenario.send,
      german:
          'Ich möchte diesen Brief als Einschreiben mit Rückschein versenden. Was brauche ich dafür?',
      arabic:
          'أريد إرسال هذه الرسالة كبريد مسجل مع إشعار بالاستلام. ماذا أحتاج لذلك؟',
      contextDe: 'Einschreiben mit Rückschein aufgeben',
      contextAr: 'إرسال رسالة مسجلة مع إثبات وصول',
      carriers: <PostalCarrier>[PostalCarrier.deutschePost],
      keywords: <String>[
        'Einschreiben',
        'Rückschein',
        'Brief',
        'Zustellnachweis',
      ],
    ),
    ShippingPhrase(
      id: 'shipping-weigh-insurance',
      scenario: ShippingScenario.send,
      german:
          'Können Sie das Paket bitte wiegen und mir sagen, welche Versandart und welche Versicherung dafür passen?',
      arabic:
          'هل يمكنكم وزن الطرد وإخباري بنوع الشحن والتأمين المناسبين له؟',
      contextDe: 'Paket wiegen und passende Versicherung auswählen',
      contextAr: 'وزن الطرد واختيار الشحن والتأمين المناسبين',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
      ],
      keywords: <String>[
        'wiegen',
        'Gewicht',
        'Versicherung',
        'versichert',
        'Paket',
      ],
    ),
    ShippingPhrase(
      id: 'shipping-goods-declaration',
      scenario: ShippingScenario.send,
      german:
          'Ich verschicke Waren. Muss ich Inhalt, Wert oder besondere Hinweise auf dem Versandauftrag angeben?',
      arabic:
          'أنا أشحن بضائع. هل يجب أن أذكر المحتوى أو القيمة أو أي ملاحظات خاصة في طلب الشحن؟',
      contextDe: 'Angaben beim Warenversand klären',
      contextAr: 'الاستفسار عن البيانات المطلوبة عند شحن البضائع',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
      ],
      keywords: <String>[
        'Waren',
        'Inhalt',
        'Wert',
        'Versandauftrag',
      ],
    ),
    ShippingPhrase(
      id: 'shipping-pickup-id',
      scenario: ShippingScenario.pickup,
      german:
          'Ich möchte mein Paket in der Filiale beziehungsweise im Paketshop abholen. Hier sind meine Benachrichtigung und mein Ausweis.',
      arabic:
          'أريد استلام طردي من الفرع أو متجر الطرود. هذه بطاقة الإشعار وهذه هويتي.',
      contextDe: 'Paket mit Benachrichtigung und Ausweis abholen',
      contextAr: 'استلام الطرد من الفرع أو Paketshop مع إبراز الهوية',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
        PostalCarrier.deutschePost,
      ],
      keywords: <String>[
        'Filiale',
        'Paketshop',
        'Ausweis',
        'Personalausweis',
        'Benachrichtigung',
        'Abholung',
      ],
    ),
    ShippingPhrase(
      id: 'shipping-pickup-authorized-person',
      scenario: ShippingScenario.pickup,
      german:
          'Kann eine andere Person die Sendung für mich abholen, und welche Vollmacht oder Unterlagen werden benötigt?',
      arabic:
          'هل يمكن لشخص آخر استلام الشحنة عني، وما التفويض أو المستندات المطلوبة؟',
      contextDe: 'Abholung durch eine bevollmächtigte Person klären',
      contextAr: 'الاستفسار عن استلام الشحنة بواسطة شخص مفوض',
      carriers: <PostalCarrier>[
        PostalCarrier.dhl,
        PostalCarrier.hermes,
        PostalCarrier.deutschePost,
      ],
      keywords: <String>[
        'Vollmacht',
        'bevollmächtigt',
        'Unterlagen',
        'abholen',
      ],
    ),
  ];
}
