import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for German postal services, sending parcels, and certified mail.
class PostPaketScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Wie kann ich Ihnen in der Postfiliale behilflich sein?',
      utteranceAr: 'نهاركم سعيد! كيف يمكنني مساعدتكم في فرع البريد؟',
      linguisticTip: 'die Postfiliale = مكتب / فرع البريد الرسمي.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich möchte dieses Paket nach München verschicken und einen wichtigen Brief per Einschreiben aufgeben.',
      utteranceAr: 'نهاركم سعيد. أود إرسال هذا الطرد إلى ميونخ، وإرسال خطاب رسمي مهم عبر البريد المسجل.',
      linguisticTip: 'per Einschreiben = بالبريد المسجل المضمون الوصول.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Gerne. Das Paket wiegt 2,4 Kilogramm. Möchten Sie einen Standard- oder Expressversand mit Sendungsverfolgung?',
      utteranceAr: 'بكل سرور. يزن الطرد 2.4 كيلوغرام. هل تفضلون الشحن العادي أم السريع مع خدمة تتبع الشحنة؟',
      linguisticTip: 'die Sendungsverfolgung = خدمة تتبع مسار الشحنة بالرمز.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Standardversand mit Sendungsverfolgung reicht vollkommen aus.',
      utteranceAr: 'الشحن العادي مع ميزة التتبع يكفي تماماً.',
      linguisticTip: 'reicht vollkommen aus = كافٍ تماماً ويلبي الغرض.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Hier ist Ihr Einlieferungsbeleg mit der Sendungsnummer. Gute Reise für Ihr Paket!',
      utteranceAr: 'تفضل هذا إيصال الإيداع وفيه رقم تتبع الشحنة. نتمنى وصولاً طيباً لطردكم!',
      linguisticTip: 'der Einlieferungsbeleg = إيصال إثبات تسليم البريد.',
    ),
  ];
}
