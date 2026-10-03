import 'services_master_orchestrator.dart';

final class TelecomSubAgent {
  const TelecomSubAgent();

  static const List<ServicePhrase> entries = <ServicePhrase>[
    ServicePhrase(
      id: 'telecom-dsl-setup',
      category: ServiceCategory.telecom,
      topicDe: 'DSL-Anschluss einrichten',
      topicAr: 'إعداد اتصال DSL',
      german:
          'Ich möchte meinen DSL-Anschluss einrichten. Welche Zugangsdaten brauche ich für den Router?',
      arabic:
          'أريد إعداد اتصال DSL في المنزل. ما بيانات الدخول التي أحتاجها للراوتر؟',
      tags: <String>[
        'DSL',
        'Router',
        'Zugangsdaten',
        'Einrichtung',
        'راوتر',
        'إعداد',
      ],
    ),
    ServicePhrase(
      id: 'telecom-fiber-outage',
      category: ServiceCategory.telecom,
      topicDe: 'Glasfaser-Störung',
      topicAr: 'عطل في الألياف الضوئية',
      german:
          'Die Glasfaser-Verbindung ist unterbrochen. Können Sie bitte prüfen, ob eine Störung vorliegt?',
      arabic:
          'اتصال الألياف الضوئية متوقف. هل يمكنكم التحقق مما إذا كان هناك عطل؟',
      tags: <String>[
        'Glasfaser',
        'Fiber',
        'Störung',
        'Internet',
        'ألياف',
        'عطل',
      ],
    ),
    ServicePhrase(
      id: 'telecom-router-sync',
      category: ServiceCategory.telecom,
      topicDe: 'Router synchronisiert nicht',
      topicAr: 'الراوتر لا يتزامن مع الخط',
      german:
          'Der Router synchronisiert sich nicht mit dem Anschluss. Welche Schritte soll ich zur Prüfung durchführen?',
      arabic:
          'الراوتر لا يتزامن مع الخط. ما الخطوات التي يجب أن أنفذها للفحص؟',
      tags: <String>[
        'Router',
        'Synchronisation',
        'Anschluss',
        'Internet',
        'راوتر',
        'اتصال',
      ],
    ),
    ServicePhrase(
      id: 'telecom-sim-activation',
      category: ServiceCategory.telecom,
      topicDe: 'SIM-Karte aktivieren',
      topicAr: 'تفعيل شريحة SIM',
      german:
          'Ich möchte meine SIM-Karte aktivieren. Welche Identitätsprüfung ist dafür erforderlich?',
      arabic:
          'أريد تفعيل شريحة SIM. ما إجراء التحقق من الهوية المطلوب لذلك؟',
      tags: <String>[
        'SIM',
        'Aktivierung',
        'Identitätsprüfung',
        'Mobilfunk',
        'شريحة',
        'تفعيل',
      ],
    ),
    ServicePhrase(
      id: 'telecom-mobile-data',
      category: ServiceCategory.telecom,
      topicDe: 'Mobile Daten funktionieren nicht',
      topicAr: 'بيانات الهاتف لا تعمل',
      german:
          'Die mobilen Daten funktionieren nach der Aktivierung nicht. Können Sie bitte die Einstellungen des Anschlusses prüfen?',
      arabic:
          'بيانات الهاتف لا تعمل بعد التفعيل. هل يمكنكم التحقق من إعدادات الخط من فضلكم؟',
      tags: <String>[
        'mobile Daten',
        'Mobilfunk',
        'Einstellungen',
        'SIM',
        'بيانات',
        'هاتف',
      ],
    ),
    ServicePhrase(
      id: 'telecom-contract-termination-inquiry',
      category: ServiceCategory.telecom,
      topicDe: 'Kündigungsfrist erfragen',
      topicAr: 'الاستفسار عن مهلة إنهاء العقد',
      german:
          'Ich möchte mich nach der Kündigungsfrist meines Vertrags erkundigen. Bitte nennen Sie mir den frühestmöglichen Termin.',
      arabic:
          'أريد الاستفسار عن مهلة إنهاء عقدي. أرجو تزويدي بأقرب موعد ممكن لإنهائه.',
      tags: <String>[
        'Kündigung',
        'Kündigungsfrist',
        'Vertrag',
        'Termin',
        'عقد',
        'إنهاء',
      ],
    ),
    ServicePhrase(
      id: 'telecom-termination-confirmation',
      category: ServiceCategory.telecom,
      topicDe: 'Kündigung schriftlich bestätigen',
      topicAr: 'طلب تأكيد إنهاء العقد خطياً',
      german:
          'Bitte bestätigen Sie mir schriftlich den Eingang meiner Kündigung und das Vertragsende.',
      arabic:
          'أرجو تأكيد استلام طلب إنهاء العقد وموعد انتهائه لي خطياً.',
      tags: <String>[
        'Kündigung',
        'Bestätigung',
        'Vertragsende',
        'schriftlich',
        'تأكيد',
        'إنهاء العقد',
      ],
    ),
  ];
}
