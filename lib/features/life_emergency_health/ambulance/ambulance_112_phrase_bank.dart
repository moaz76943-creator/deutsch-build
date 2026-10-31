import '../emergency_health_models.dart';

abstract final class Ambulance112PhraseBank {
  static const List<EmergencyPhrase> items = <EmergencyPhrase>[
    EmergencyPhrase(
      id: 'ambulance_request',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Rettungswagen anfordern',
      titleAr: 'طلب سيارة إسعاف',
      german:
          'Ich brauche dringend einen Rettungswagen. Bitte schicken Sie Hilfe.',
      arabic:
          'أحتاج سيارة إسعاف بشكل عاجل. يرجى إرسال المساعدة.',
      explanationAr:
          'ابدأ بطلب واضح ومباشر، ثم انتظر أسئلة مركز الطوارئ.',
      tags: <String>['112', 'Rettungswagen', 'Notruf', 'dringend'],
    ),
    EmergencyPhrase(
      id: 'ambulance_location',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Genauen Standort nennen',
      titleAr: 'ذكر الموقع الدقيق',
      german:
          'Wir sind in der Gartenstraße 18, Eingang B, im dritten Stock.',
      arabic:
          'نحن في شارع غارتن 18، المدخل B، في الطابق الثالث.',
      explanationAr:
          'اذكر Straße، Hausnummer، المدخل والطابق أو علامة واضحة عند الإمكان.',
      tags: <String>[
        'Wo',
        'Straße',
        'Hausnummer',
        'Eingang',
        'Stock',
        'Standort',
      ],
    ),
    EmergencyPhrase(
      id: 'ambulance_unconscious',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Bewusstlosigkeit melden',
      titleAr: 'الإبلاغ عن فقدان الوعي',
      german:
          'Die Person ist bewusstlos und reagiert nicht auf Ansprache.',
      arabic:
          'الشخص فاقد للوعي ولا يستجيب عند التحدث إليه.',
      explanationAr:
          'صف ما تلاحظه دون تشخيص، ثم أجب عن أسئلة التنفس واتبع تعليمات الموظف.',
      tags: <String>['bewusstlos', 'reagiert nicht', 'Bewusstsein'],
    ),
    EmergencyPhrase(
      id: 'ambulance_breathing',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Schwere Atemnot',
      titleAr: 'ضيق تنفس شديد',
      german:
          'Die Person hat starke Atemnot und kann nur wenige Wörter sprechen.',
      arabic:
          'الشخص يعاني من ضيق تنفس شديد ولا يستطيع قول سوى كلمات قليلة.',
      explanationAr:
          'أبلغ عن شدة ضيق التنفس وما إذا كان الشخص يستطيع الكلام.',
      tags: <String>['Atemnot', 'Atmung', 'schwer', 'sprechen'],
    ),
    EmergencyPhrase(
      id: 'ambulance_bleeding',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Starke Blutung',
      titleAr: 'نزيف شديد',
      german:
          'Die Person hat eine starke Blutung am Arm, die nicht aufhört.',
      arabic:
          'لدى الشخص نزيف شديد في الذراع ولا يتوقف.',
      explanationAr:
          'حدد موضع النزيف واذكر إن كان مستمرًا أو شديدًا.',
      tags: <String>['starke Blutung', 'Arm', 'blutet', 'Verletzung'],
    ),
    EmergencyPhrase(
      id: 'ambulance_accident',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Schwerer Unfall',
      titleAr: 'حادث خطير',
      german:
          'Es gab einen Verkehrsunfall. Zwei Personen sind verletzt.',
      arabic:
          'وقع حادث سير وهناك شخصان مصابان.',
      explanationAr:
          'اذكر نوع الحادث وعدد المصابين وأي خطر مستمر في المكان.',
      tags: <String>[
        'Unfall',
        'Verkehrsunfall',
        'zwei Personen',
        'verletzt',
      ],
    ),
    EmergencyPhrase(
      id: 'ambulance_chest_pain',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Starke Brustschmerzen',
      titleAr: 'ألم شديد في الصدر',
      german:
          'Die Person hat plötzlich starke Brustschmerzen und fühlt sich sehr schwach.',
      arabic:
          'يعاني الشخص فجأة من ألم شديد في الصدر ويشعر بضعف شديد.',
      explanationAr:
          'اذكر البداية المفاجئة وشدة الأعراض؛ لا تحاول تشخيص السبب بنفسك.',
      tags: <String>['Brustschmerzen', 'plötzlich', 'schwach'],
    ),
    EmergencyPhrase(
      id: 'ambulance_wait',
      domain: EmergencyHealthDomain.ambulance112,
      urgency: EmergencyUrgency.lifeThreatening,
      titleDe: 'Auf Rückfragen warten',
      titleAr: 'انتظار أسئلة المركز',
      german:
          'Ich bleibe am Telefon. Bitte sagen Sie mir, was ich jetzt tun soll.',
      arabic:
          'سأبقى على الهاتف. يرجى إخباري بما يجب أن أفعله الآن.',
      explanationAr:
          'لا تغلق الاتصال من نفسك؛ اتبع تعليمات مركز الطوارئ حتى تصل المساعدة.',
      tags: <String>['Warten', 'Rückfragen', 'Leitstelle', 'Telefon'],
    ),
  ];
}
