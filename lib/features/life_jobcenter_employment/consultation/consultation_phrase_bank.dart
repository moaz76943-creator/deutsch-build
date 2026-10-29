import 'consultation_models.dart';

final class ConsultationPhraseBank {
  const ConsultationPhraseBank();

  List<ConsultationPhrase> get phrases => _phrases;

  static const List<ConsultationPhrase> _phrases =
      <ConsultationPhrase>[
    ConsultationPhrase(
      id: 'adviser-goals',
      topic: ConsultationTopic.adviserMeeting,
      german:
          'Ich habe heute einen Termin bei meiner Sachbearbeiterin oder meinem Sachbearbeiter und möchte meine beruflichen Ziele und die nächsten Schritte besprechen.',
      arabic:
          'لدي اليوم موعد مع الموظفة أو الموظف المسؤول وأريد مناقشة أهدافي المهنية والخطوات التالية.',
      contextDe: 'Gespräch strukturiert eröffnen',
      contextAr: 'بدء الحديث مع المستشار بشكل منظم',
      keywords: <String>['Sachbearbeiter', 'Termin', 'Ziele', 'مستشار'],
    ),
    ConsultationPhrase(
      id: 'adviser-clarify-plan',
      topic: ConsultationTopic.adviserMeeting,
      german:
          'Können Sie mir bitte erklären, welche nächsten Schritte Sie mir empfehlen und was ich bis zum nächsten Termin vorbereiten soll?',
      arabic:
          'هل يمكن أن تشرح لي الخطوات التالية التي تقترحها وما الذي ينبغي أن أجهزه قبل الموعد القادم؟',
      contextDe: 'Aufgaben und nächsten Termin klären',
      contextAr: 'توضيح المطلوب قبل الموعد التالي',
      keywords: <String>['nächste Schritte', 'vorbereiten', 'موعد'],
    ),
    ConsultationPhrase(
      id: 'skills-experience',
      topic: ConsultationTopic.skillsProfile,
      german:
          'Ich habe mehrere Jahre Berufserfahrung und möchte meine bisherigen Kenntnisse und Tätigkeiten gemeinsam mit Ihnen ordnen.',
      arabic:
          'لدي عدة سنوات من الخبرة المهنية وأريد ترتيب مهاراتي وأعمالي السابقة معك.',
      contextDe: 'Berufserfahrung und Kenntnisse beschreiben',
      contextAr: 'شرح الخبرة والمهارات المهنية',
      keywords: <String>['Berufserfahrung', 'Kenntnisse', 'Erfahrung', 'خبرة'],
    ),
    ConsultationPhrase(
      id: 'skills-target-role',
      topic: ConsultationTopic.skillsProfile,
      german:
          'Welche Tätigkeiten passen aus Ihrer Sicht zu meinen Erfahrungen, und welche Qualifikation fehlt mir eventuell noch?',
      arabic:
          'ما الأعمال التي تناسب خبرتي برأيك، وما المؤهل الذي قد أحتاجه أيضاً؟',
      contextDe: 'Passende Tätigkeiten und Qualifizierung erfragen',
      contextAr: 'السؤال عن الوظائف المناسبة والتأهيل المطلوب',
      keywords: <String>['Qualifikation', 'Tätigkeiten', 'مهارات'],
    ),
    ConsultationPhrase(
      id: 'course-integration-funding',
      topic: ConsultationTopic.courseFunding,
      german:
          'Kann das Jobcenter einen Integrationskurs oder Sprachkurs fördern? Welche Voraussetzungen gelten dafür?',
      arabic:
          'هل يمكن للجوب سنتر تمويل دورة اندماج أو دورة لغة؟ وما الشروط المطلوبة لذلك؟',
      contextDe: 'Mögliche Kursförderung ohne Zusage erfragen',
      contextAr: 'السؤال عن إمكانية تمويل الدورة دون افتراض الموافقة',
      keywords: <String>['Integrationskurs', 'Sprachkurs', 'Förderung', 'دورة اللغة'],
    ),
    ConsultationPhrase(
      id: 'course-documents',
      topic: ConsultationTopic.courseFunding,
      german:
          'Ist eine Kostenübernahme für den Kurs möglich, und welche Unterlagen brauchen Sie für die Prüfung?',
      arabic:
          'هل تغطية تكلفة الدورة ممكنة، وما المستندات التي تحتاجونها لفحص الطلب؟',
      contextDe: 'Voraussetzungen und Unterlagen klären',
      contextAr: 'توضيح الشروط والمستندات المطلوبة',
      keywords: <String>['Kostenübernahme', 'Unterlagen', 'möglich', 'تمويل'],
    ),
    ConsultationPhrase(
      id: 'applications-status',
      topic: ConsultationTopic.applications,
      german:
          'Ich habe in den letzten Wochen mehrere Bewerbungen verschickt. Können wir gemeinsam prüfen, welche Rückmeldungen noch offen sind?',
      arabic:
          'أرسلت عدة طلبات توظيف خلال الأسابيع الماضية. هل يمكننا مراجعة الردود التي ما زالت معلقة؟',
      contextDe: 'Bewerbungen systematisch nachverfolgen',
      contextAr: 'متابعة طلبات التوظيف بشكل منظم',
      keywords: <String>['Bewerbungen', 'Rückmeldungen', 'تقديم'],
    ),
    ConsultationPhrase(
      id: 'applications-next-step',
      topic: ConsultationTopic.applications,
      german:
          'Soll ich diese Bewerbung noch einmal nachfassen, oder empfehlen Sie mir einen anderen nächsten Schritt?',
      arabic:
          'هل تنصحني بمتابعة هذا الطلب مرة أخرى أم بخطوة أخرى؟',
      contextDe: 'Nächsten Bewerbungsschritt abstimmen',
      contextAr: 'تحديد الخطوة التالية في طلب التوظيف',
      keywords: <String>['Bewerbung', 'nachfassen', 'خطوة'],
    ),
    ConsultationPhrase(
      id: 'travel-costs-before-interview',
      topic: ConsultationTopic.travelCosts,
      german:
          'Ich habe eine Einladung zu einem Vorstellungsgespräch. Kann ich vor der Reise die Übernahme der Fahrtkosten beantragen, und welche Voraussetzungen gelten?',
      arabic:
          'لدي دعوة لمقابلة عمل. هل يمكنني طلب تغطية تكاليف السفر قبل الرحلة، وما الشروط المطلوبة؟',
      contextDe: 'Fahrtkosten vor dem Vorstellungsgespräch erfragen',
      contextAr: 'السؤال مسبقاً عن تكاليف السفر للمقابلة',
      keywords: <String>['Fahrtkosten', 'Vorstellungsgespräch', 'Reise', 'مقابلة'],
    ),
    ConsultationPhrase(
      id: 'travel-costs-proof',
      topic: ConsultationTopic.travelCosts,
      german:
          'Welche Nachweise soll ich für die Fahrtkosten aufbewahren und wann soll ich sie einreichen?',
      arabic:
          'ما الإثباتات التي يجب أن أحتفظ بها لتكاليف السفر ومتى أقدمها؟',
      contextDe: 'Nachweise und Einreichung klären',
      contextAr: 'توضيح الإثباتات ووقت تقديمها',
      keywords: <String>['Nachweise', 'einreichen', 'Fahrtkosten', 'إثبات'],
    ),
  ];
}
