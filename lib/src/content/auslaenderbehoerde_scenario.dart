import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for residence permit renewal and immigration office interactions.
class AuslaenderbehoerdeScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Sie haben einen Termin zur Verlängerung Ihres Aufenthaltstitels?',
      utteranceAr: 'نهاركم سعيد! لديكم موعد رسمي لتمديد تصريح إقامتكم القانونية؟',
      linguisticTip: 'der Aufenthaltstitel = تصريح / بطاقة الإقامة القانونية في ألمانيا.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ja genau. Hier sind mein Reisepass, mein Arbeitsvertrag und die Gehaltsabrechnungen der letzten drei Monate.',
      utteranceAr: 'نهاركم سعيد. نعم بالضبط. تفضلوا جواز سفري، وعقد عملي، وبيانات الراتب للأشهر الثلاثة الأخيرة.',
      linguisticTip: 'die Gehaltsabrechnung = قسيمة / كشف الراتب الشهري الصادر عن الشركة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gut. Liegt Ihnen auch eine aktuelle Mitgliedsbescheinigung Ihrer gesetzlichen Krankenkasse vor?',
      utteranceAr: 'ممتاز جداً. هل بحوزتكم أيضاً شهادة تأمين صحي حديثة من صندوق التأمين القانوني؟',
      linguisticTip: 'die Mitgliedsbescheinigung = شهادة إثبات العضوية في التأمين الصحي.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Ja, hier ist das Bestätigungsschreiben der Krankenkasse und mein biometrisches Passfoto.',
      utteranceAr: 'نعم، تفضلوا خطاب التأكيد الصادر من التأمين الصحي وصورتي الشخصية البيومترية الحديثة.',
      linguisticTip: 'das biometrische Passfoto = الصورة الشخصية البيومترية المطابقة لمعايير الجوازات.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Alle Unterlagen sind vollständig und einwandfrei. Die elektronische Aufenthaltskarte wird bestellt.',
      utteranceAr: 'جميع وثائقكم مكتملة وسليمة تماماً. سنطلب إصدار بطاقة الإقامة الإلكترونية الجديدة لكم.',
      linguisticTip: 'die elektronische Aufenthaltskarte (eAT) = بطاقة الإقامة الإلكترونية الذكية.',
    ),
  ];
}
