import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for doctor appointment, health insurance, and symptom description.
class ArztbesuchScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Praxis Dr. Weber, guten Tag! Was kann ich für Sie tun?',
      utteranceAr: 'عيادة الدكتور فيبر، نهاركم سعيد! كيف يمكنني خدمتكم؟',
      linguisticTip: 'صيغة الرد الهاتفي المعتادة في العيادات الطبية الألمانية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich habe seit zwei Tagen starke Halsschmerzen und Fieber. Kann ich heute vorbeikommen?',
      utteranceAr: 'نهاركم سعيد. أعاني منذ يومين من ألم شديد في الحلق وحمى. هل يمكنني الحضور اليوم للمعاينة؟',
      linguisticTip: 'seit + Dativ للتعبير عن المدة الزمنية المستمرة (seit zwei Tagen).',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Kommen Sie bitte um elf Uhr in unsere Akutsprechstunde. Bringen Sie Ihre Versichertenkarte mit.',
      utteranceAr: 'تفضلوا بالحضور عند الساعة الحادية عشرة في فترة الكشف العاجل. وأحضروا معكم بطاقة التأمين الصحي.',
      linguisticTip: 'Akutsprechstunde = ساعات استقبال الحالات الطارئة دون موعد مسبق طويل.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Bitte nehmen Sie im Behandlungszimmer Platz. Wo genau tut es weh?',
      utteranceAr: 'مرحباً بكم! تفضلوا بالجلوس في غرفة الفحص الطبي. أين موضع الألم بالتحديد؟',
      linguisticTip: 'Wehtun = يؤلم (Wo tut es weh? = أين موضع الألم؟).',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Das Schlucken fällt mir schwer und ich fühle mich sehr erschöpft.',
      utteranceAr: 'أجد صعوبة في البلع وأشعر بإرهاق شديد في جسدي.',
      linguisticTip: 'schwerfallen = يصعب على المرء (fällt mir schwer).',
    ),
  ];
}
