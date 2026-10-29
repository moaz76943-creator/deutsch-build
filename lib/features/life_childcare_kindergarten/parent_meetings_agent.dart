import 'childcare_master_hub.dart';

final class ParentMeetingsAgent {
  const ParentMeetingsAgent();

  static const List<ChildcarePhrase> entries = <ChildcarePhrase>[
    ChildcarePhrase(
      id: 'parent-meeting-date',
      category: ChildcareCategory.parentCommunication,
      topicDe: 'Elterngespräch vereinbaren',
      topicAr: 'تحديد اجتماع مع الأهل',
      german:
          'Ich würde gern einen Termin für ein Elterngespräch vereinbaren. Welche Zeiten sind möglich?',
      arabic:
          'أرغب في تحديد موعد لاجتماع مع الأهل. ما الأوقات المتاحة؟',
      tags: <String>['Elterngespräch', 'Termin', 'Zeiten', 'اجتماع', 'موعد'],
    ),
    ChildcarePhrase(
      id: 'parent-evening',
      category: ChildcareCategory.parentCommunication,
      topicDe: 'Elternabend',
      topicAr: 'اجتماع أولياء الأمور العام',
      german:
          'Wann findet der nächste Elternabend statt, und welche Themen stehen auf der Tagesordnung?',
      arabic:
          'متى يُعقد اجتماع أولياء الأمور القادم، وما المواضيع الموجودة على جدول الأعمال؟',
      tags: <String>['Elternabend', 'Tagesordnung', 'Themen', 'أولياء الأمور'],
    ),
    ChildcarePhrase(
      id: 'parent-progress',
      category: ChildcareCategory.parentCommunication,
      topicDe: 'Entwicklung besprechen',
      topicAr: 'مناقشة تطور الطفل',
      german:
          'Ich möchte gern hören, wie mein Kind im Alltag zurechtkommt und welche Fortschritte Sie beobachten.',
      arabic:
          'أود معرفة كيف يتعامل طفلي مع الروتين اليومي وما التطورات التي تلاحظونها.',
      tags: <String>['Entwicklung', 'Fortschritte', 'Alltag', 'تطور'],
    ),
    ChildcarePhrase(
      id: 'parent-learning',
      category: ChildcareCategory.parentCommunication,
      topicDe: 'Unterstützung zu Hause',
      topicAr: 'الدعم في المنزل',
      german:
          'Welche Aktivitäten können wir zu Hause sinnvoll aufgreifen, um das Lernen im Alltag zu unterstützen?',
      arabic:
          'ما الأنشطة المناسبة التي يمكننا متابعتها في المنزل لدعم التعلم اليومي؟',
      tags: <String>['Unterstützung', 'zu Hause', 'Lernen', 'دعم', 'منزل'],
    ),
    ChildcarePhrase(
      id: 'parent-school-letter',
      category: ChildcareCategory.parentCommunication,
      topicDe: 'Mitteilung verstehen',
      topicAr: 'فهم رسالة المدرسة أو الروضة',
      german:
          'Könnten Sie mir bitte erklären, was in dieser Mitteilung organisatorisch von den Eltern erwartet wird?',
      arabic:
          'هل يمكنكم شرح المطلوب تنظيمياً من الأهل في هذا الإشعار؟',
      tags: <String>['Mitteilung', 'Eltern', 'organisatorisch', 'إشعار'],
    ),
    ChildcarePhrase(
      id: 'parent-followup',
      category: ChildcareCategory.parentCommunication,
      topicDe: 'Rückmeldung nach Gespräch',
      topicAr: 'متابعة بعد الاجتماع',
      german:
          'Vielen Dank für das Gespräch. Können wir in einigen Wochen kurz besprechen, wie sich die vereinbarten Schritte entwickeln?',
      arabic:
          'شكراً على الاجتماع. هل يمكننا بعد عدة أسابيع مراجعة تطور الخطوات التي اتفقنا عليها؟',
      tags: <String>['Rückmeldung', 'vereinbart', 'Gespräch', 'متابعة'],
    ),
  ];
}
