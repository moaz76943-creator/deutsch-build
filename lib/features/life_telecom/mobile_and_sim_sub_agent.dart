import 'telecom_models.dart';

final class MobileAndSimSubAgent {
  const MobileAndSimSubAgent();

  List<TelecomPhrase> get phrases => _phrases;

  static const List<TelecomPhrase> _phrases = <TelecomPhrase>[
    TelecomPhrase(
      id: 'mobile-prepaid-purchase',
      domain: TelecomDomain.mobilePrepaid,
      topicDe: 'Prepaid-SIM kaufen',
      topicAr: 'شراء شريحة دفع مسبق',
      german:
          'Ich möchte eine Prepaid-SIM-Karte kaufen. Welche Tarife und Startguthaben sind verfügbar?',
      arabic:
          'أريد شراء شريحة SIM مسبقة الدفع. ما الباقات والرصيد الابتدائي المتاح؟',
      keywords: <String>[
        'Prepaid',
        'SIM',
        'Prepaid-SIM',
        'Startguthaben',
        'Tarif',
      ],
    ),
    TelecomPhrase(
      id: 'mobile-prepaid-activation',
      domain: TelecomDomain.mobilePrepaid,
      topicDe: 'Prepaid-Aktivierung',
      topicAr: 'تفعيل شريحة الدفع المسبق',
      german:
          'Ich möchte die Prepaid-Aktivierung abschließen. Welche Schritte muss ich nach dem Einlegen der SIM-Karte durchführen?',
      arabic:
          'أريد إكمال تفعيل الشريحة مسبقة الدفع. ما الخطوات المطلوبة بعد وضع شريحة SIM في الهاتف؟',
      keywords: <String>[
        'Prepaid-Aktivierung',
        'Aktivierung',
        'SIM',
        'Freischaltung',
      ],
    ),
    TelecomPhrase(
      id: 'mobile-identity-verification',
      domain: TelecomDomain.mobilePrepaid,
      topicDe: 'Video-Ident / PostIdent',
      topicAr: 'التحقق من الهوية عبر Video-Ident أو PostIdent',
      german:
          'Kann ich die Identitätsprüfung per Video-Ident durchführen, oder ist für diesen Tarif auch PostIdent möglich?',
      arabic:
          'هل يمكنني إجراء التحقق من الهوية عبر Video-Ident، أم أن PostIdent متاح أيضًا لهذه الباقة؟',
      keywords: <String>[
        'Video-Ident',
        'PostIdent',
        'Identitätsprüfung',
        'Ausweis',
        'Prepaid',
      ],
    ),
    TelecomPhrase(
      id: 'mobile-number-porting',
      domain: TelecomDomain.mobilePrepaid,
      topicDe: 'Rufnummernmitnahme',
      topicAr: 'نقل رقم الهاتف',
      german:
          'Ich möchte meine bisherige Rufnummer mitnehmen. Welche Angaben brauchen Sie für die Rufnummernmitnahme?',
      arabic:
          'أريد الاحتفاظ برقم هاتفي الحالي. ما البيانات المطلوبة لإتمام نقل الرقم؟',
      keywords: <String>[
        'Rufnummernmitnahme',
        'Rufnummer',
        'Portierung',
        'Anbieterwechsel',
      ],
    ),
    TelecomPhrase(
      id: 'mobile-data-setup',
      domain: TelecomDomain.mobilePrepaid,
      topicDe: 'Mobile Daten einrichten',
      topicAr: 'إعداد بيانات الهاتف',
      german:
          'Die SIM-Karte ist aktiviert, aber die mobilen Daten funktionieren nicht. Welche Einstellungen soll ich prüfen?',
      arabic:
          'تم تفعيل شريحة SIM لكن بيانات الهاتف لا تعمل. ما الإعدادات التي يجب أن أتحقق منها؟',
      keywords: <String>[
        'mobile Daten',
        'APN',
        'SIM',
        'Einstellungen',
        'Internet',
      ],
    ),
    TelecomPhrase(
      id: 'mobile-credit-balance',
      domain: TelecomDomain.mobilePrepaid,
      topicDe: 'Guthaben & Aufladung',
      topicAr: 'الرصيد وإعادة الشحن',
      german:
          'Wie kann ich mein Prepaid-Guthaben prüfen und die SIM-Karte wieder aufladen?',
      arabic:
          'كيف يمكنني معرفة رصيد الدفع المسبق وإعادة شحن الشريحة؟',
      keywords: <String>[
        'Guthaben',
        'Aufladung',
        'aufladen',
        'Prepaid',
      ],
    ),
  ];
}
