import 'telecom_models.dart';

final class HomeInternetSubAgent {
  const HomeInternetSubAgent();

  List<TelecomPhrase> get phrases => _phrases;

  static const List<TelecomPhrase> _phrases = <TelecomPhrase>[
    TelecomPhrase(
      id: 'home-router-setup',
      domain: TelecomDomain.homeInternet,
      topicDe: 'Router einrichten',
      topicAr: 'إعداد الراوتر',
      german:
          'Ich möchte meinen Router einrichten. Welche Zugangsdaten und Einstellungen brauche ich für meinen Anschluss?',
      arabic:
          'أريد إعداد الراوتر. ما بيانات الدخول والإعدادات التي أحتاجها لهذا الخط؟',
      keywords: <String>[
        'Router einrichten',
        'Router',
        'Zugangsdaten',
        'WLAN',
        'Anschluss',
      ],
    ),
    TelecomPhrase(
      id: 'home-technician-window',
      domain: TelecomDomain.homeInternet,
      topicDe: 'Technikerfenster',
      topicAr: 'موعد فني التركيب',
      german:
          'Für welches Technikerfenster ist der Termin geplant, und muss ich während des gesamten Zeitraums zu Hause sein?',
      arabic:
          'ما الفترة المحددة لموعد الفني، وهل يجب أن أبقى في المنزل طوال هذه الفترة؟',
      keywords: <String>[
        'Technikerfenster',
        'Techniker',
        'Termin',
        'Installation',
        'Freischaltung',
      ],
    ),
    TelecomPhrase(
      id: 'home-contract-terms',
      domain: TelecomDomain.homeInternet,
      topicDe: 'DSL, Kabel & Glasfaser · Vertragslaufzeit',
      topicAr: 'مدة عقد DSL أو الكابل أو الألياف',
      german:
          'Welche Vertragslaufzeit gilt für diesen DSL-, Kabel- oder Glasfaservertrag, und welche Bandbreite ist vereinbart?',
      arabic:
          'ما مدة العقد لخدمة DSL أو الكابل أو الألياف، وما سرعة الاتصال المتفق عليها؟',
      keywords: <String>[
        'DSL',
        'Kabel',
        'Glasfaser',
        'Vertragslaufzeit',
        'Bandbreite',
        'Vertrag',
      ],
    ),
    TelecomPhrase(
      id: 'home-bandwidth-measurement',
      domain: TelecomDomain.homeInternet,
      topicDe: 'Bandbreite messen',
      topicAr: 'قياس سرعة الاتصال',
      german:
          'Wie kann ich die Bandbreite messen und die Ergebnisse dokumentieren, wenn die Verbindung dauerhaft langsamer als erwartet ist?',
      arabic:
          'كيف يمكنني قياس سرعة الاتصال وتوثيق النتائج إذا كانت السرعة أقل من المتوقع بشكل مستمر؟',
      keywords: <String>[
        'Bandbreite messen',
        'Bandbreite',
        'Geschwindigkeit',
        'Speedtest',
        'Messung',
      ],
    ),
    TelecomPhrase(
      id: 'home-line-activation',
      domain: TelecomDomain.homeInternet,
      topicDe: 'Anschluss noch nicht freigeschaltet',
      topicAr: 'الخط لم يُفعّل بعد',
      german:
          'Der Anschluss ist noch nicht freigeschaltet. Können Sie bitte den Aktivierungsstatus und den nächsten Schritt prüfen?',
      arabic:
          'الخط لم يتم تفعيله بعد. هل يمكنكم التحقق من حالة التفعيل والخطوة التالية؟',
      keywords: <String>[
        'Freischaltung',
        'Aktivierung',
        'Anschluss',
        'DSL',
        'Glasfaser',
      ],
    ),
  ];
}
