import 'childcare_master_hub.dart';

final class EnrollmentAttendanceAgent {
  const EnrollmentAttendanceAgent();

  static const List<ChildcarePhrase> entries = <ChildcarePhrase>[
    ChildcarePhrase(
      id: 'childcare-registration',
      category: ChildcareCategory.enrollmentAttendance,
      topicDe: 'Kind anmelden',
      topicAr: 'تسجيل الطفل',
      german:
          'Ich möchte mein Kind für einen Betreuungsplatz anmelden. Welche Unterlagen benötigen Sie?',
      arabic:
          'أريد تسجيل طفلي للحصول على مكان في الرعاية. ما الوثائق التي تحتاجونها؟',
      tags: <String>['Anmeldung', 'Betreuungsplatz', 'Unterlagen', 'تسجيل', 'وثائق'],
    ),
    ChildcarePhrase(
      id: 'childcare-start-date',
      category: ChildcareCategory.enrollmentAttendance,
      topicDe: 'Aufnahmetermin',
      topicAr: 'موعد بدء الدوام',
      german:
          'Ab wann wäre ein Platz verfügbar, und wann erhalten wir eine verbindliche Zusage?',
      arabic:
          'متى يتوفر مكان، ومتى نحصل على تأكيد رسمي نهائي؟',
      tags: <String>['Platz', 'verfügbar', 'Zusage', 'موعد', 'مكان'],
    ),
    ChildcarePhrase(
      id: 'childcare-settling-in',
      category: ChildcareCategory.enrollmentAttendance,
      topicDe: 'Eingewöhnung',
      topicAr: 'فترة التهيئة',
      german:
          'Wie läuft die Eingewöhnungsphase ab, und wie lange bleiben Eltern am Anfang dabei?',
      arabic:
          'كيف تسير فترة التهيئة، وكم يبقى الأهل مع الطفل في البداية؟',
      tags: <String>['Eingewöhnung', 'Eltern', 'Ablauf', 'تهيئة'],
    ),
    ChildcarePhrase(
      id: 'childcare-absence',
      category: ChildcareCategory.enrollmentAttendance,
      topicDe: 'Abwesenheit melden',
      topicAr: 'إبلاغ الغياب',
      german:
          'Mein Kind bleibt heute zu Hause. Bis wann und über welchen Weg soll ich die Abwesenheit melden?',
      arabic:
          'طفلي سيبقى في المنزل اليوم. حتى أي وقت وبأي طريقة يجب أن أبلغ عن الغياب؟',
      tags: <String>['Abwesenheit', 'fehlt', 'melden', 'غياب'],
    ),
    ChildcarePhrase(
      id: 'childcare-pickup',
      category: ChildcareCategory.enrollmentAttendance,
      topicDe: 'Abholberechtigung',
      topicAr: 'تفويض استلام الطفل',
      german:
          'Wie kann ich eine weitere Person schriftlich zur Abholung meines Kindes berechtigen?',
      arabic:
          'كيف يمكنني تفويض شخص آخر خطياً لاستلام طفلي؟',
      tags: <String>['Abholung', 'berechtigen', 'schriftlich', 'استلام', 'تفويض'],
    ),
    ChildcarePhrase(
      id: 'childcare-hours',
      category: ChildcareCategory.enrollmentAttendance,
      topicDe: 'Bring- und Abholzeiten',
      topicAr: 'أوقات الحضور والاستلام',
      german:
          'Welche festen Bring- und Abholzeiten gelten, und was soll ich bei einer Verspätung tun?',
      arabic:
          'ما أوقات الحضور والاستلام المحددة، وماذا أفعل إذا تأخرت؟',
      tags: <String>['Bringzeit', 'Abholzeit', 'Verspätung', 'دوام', 'تأخير'],
    ),
  ];
}
