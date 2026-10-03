import '../emergency_health_models.dart';

abstract final class NotdienstPhraseBank {
  static const List<EmergencyPhrase> items = <EmergencyPhrase>[
    EmergencyPhrase(
      id: 'doctor_116117_intro',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: '116 117 anrufen',
      titleAr: 'الاتصال بخدمة 116117',
      german:
          'Guten Abend. Ich brauche heute ärztliche Hilfe, aber es ist kein lebensbedrohlicher Notfall.',
      arabic:
          'مساء الخير. أحتاج مساعدة طبية اليوم، لكنها ليست حالة مهددة للحياة.',
      explanationAr:
          'هذه صياغة مناسبة لخدمة الطبيب المناوب عندما لا تستطيع الحالة الانتظار حتى موعد العيادة التالي ولكنها ليست مهددة للحياة.',
      tags: <String>[
        '116 117',
        'Bereitschaftsdienst',
        'ärztliche Hilfe',
        'nicht lebensbedrohlich',
      ],
    ),
    EmergencyPhrase(
      id: 'doctor_location',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: 'Ort und Erreichbarkeit',
      titleAr: 'الموقع وإمكانية الوصول',
      german:
          'Ich bin in der Bahnhofstraße 10. Können Sie mir sagen, welche Bereitschaftspraxis zuständig ist?',
      arabic:
          'أنا في شارع بانهوف 10. هل يمكنكم إخباري بأي عيادة مناوبة مسؤولة عن منطقتي؟',
      explanationAr:
          'اذكر عنوانك أو رمزك البريدي بوضوح لتحديد الخدمة المناسبة.',
      tags: <String>[
        'Bereitschaftspraxis',
        'Adresse',
        'Postleitzahl',
        '116117',
      ],
    ),
    EmergencyPhrase(
      id: 'doctor_pain_description',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: 'Schmerzen beschreiben',
      titleAr: 'وصف الألم',
      german:
          'Ich habe seit drei Stunden starke, stechende Schmerzen im rechten Unterbauch.',
      arabic:
          'لدي منذ ثلاث ساعات ألم شديد وطاعن في أسفل البطن من الجهة اليمنى.',
      explanationAr:
          'اذكر مدة الألم وموضعه وشدته وطبيعته مثل stechend أو dumpf.',
      tags: <String>[
        'Schmerzen',
        'stark',
        'stechend',
        'Unterbauch',
        'Dauer',
      ],
    ),
    EmergencyPhrase(
      id: 'doctor_escalate_112',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: 'Lebensgefahr: 112 statt 116 117',
      titleAr: 'في الخطر المهدد للحياة: 112',
      german:
          'Bei Bewusstlosigkeit, schwerer Atemnot oder anderen lebensbedrohlichen Zeichen rufe ich sofort 112.',
      arabic:
          'عند فقدان الوعي أو ضيق التنفس الشديد أو أي علامة مهددة للحياة أتصل فورًا بـ112.',
      explanationAr:
          'خدمة 116117 ليست بديلًا عن رقم الطوارئ 112 في الحالات المهددة للحياة.',
      tags: <String>[
        '112',
        'Bewusstlosigkeit',
        'Atemnot',
        'lebensbedrohlich',
      ],
    ),
    EmergencyPhrase(
      id: 'pharmacy_find_service',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: 'Apotheken-Notdienst finden',
      titleAr: 'العثور على صيدلية مناوبة',
      german:
          'Wo finde ich heute Nacht die nächste geöffnete Apotheke im Apotheken-Notdienst?',
      arabic:
          'أين أجد الليلة أقرب صيدلية مفتوحة ضمن خدمة الصيدليات المناوبة؟',
      explanationAr:
          'تحقق من خدمة البحث الرسمية الحالية لأن الصيدليات المناوبة تتغير حسب المكان والوقت.',
      tags: <String>[
        'Apotheken-Notdienst',
        'Apotheke',
        'heute Nacht',
        'geöffnet',
      ],
    ),
    EmergencyPhrase(
      id: 'pharmacy_fee',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: 'Notdienstgebühr verstehen',
      titleAr: 'فهم رسوم خدمة المناوبة',
      german:
          'Fällt für diese Abgabe die Notdienstgebühr von 2,50 Euro an?',
      arabic:
          'هل تُفرض على هذا الصرف رسوم خدمة المناوبة البالغة 2.50 يورو؟',
      explanationAr:
          'وفق ABDA يمكن للصيدلية فرض 2.50 يورو شاملة الضريبة لكل استخدام لخدمة المناوبة؛ وقد تتحملها شركة التأمين للمؤمن عليه إذا وضع الطبيب علامة noctu على الوصفة.',
      tags: <String>[
        'Notdienstgebühr',
        '2,50 Euro',
        'noctu',
        'Krankenkasse',
        'Apotheke',
      ],
    ),
    EmergencyPhrase(
      id: 'pharmacy_prescription',
      domain: EmergencyHealthDomain.medicalOnCall,
      urgency: EmergencyUrgency.urgentNonLifeThreatening,
      titleDe: 'Rezept im Notdienst',
      titleAr: 'الوصفة في خدمة المناوبة',
      german:
          'Auf meinem Rezept ist noctu angekreuzt. Wird die Notdienstgebühr von meiner Krankenkasse übernommen?',
      arabic:
          'تم وضع علامة noctu على وصفتي. هل تتحمل شركة التأمين رسوم خدمة المناوبة؟',
      explanationAr:
          'اسأل الصيدلية مباشرة عن تحمل الرسوم لأن تفاصيل التغطية تعتمد على الوصفة والتأمين.',
      tags: <String>[
        'Rezept',
        'noctu',
        'Notdienstgebühr',
        'Krankenkasse',
      ],
    ),
  ];
}
