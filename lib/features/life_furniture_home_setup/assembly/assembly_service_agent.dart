import 'assembly_models.dart';

final class AssemblyServiceAgent {
  const AssemblyServiceAgent();

  List<AssemblyScenario> get scenarios => _scenarios;

  static const List<AssemblyScenario> _scenarios = <AssemblyScenario>[
    AssemblyScenario(
      id: 'assembly-instructions',
      issue: AssemblyIssue.instructions,
      titleDe: 'Aufbauanleitung verstehen',
      titleAr: 'فهم دليل التركيب',
      german:
          'Gibt es die Aufbauanleitung auch digital, und welcher Schritt kommt nach der Montage der Seitenteile?',
      arabic:
          'هل يتوفر دليل التركيب رقميًا، وما الخطوة التالية بعد تركيب الأجزاء الجانبية؟',
      keywords: <String>['Aufbauanleitung', 'Schritt', 'Montage'],
    ),
    AssemblyScenario(
      id: 'assembly-tools',
      issue: AssemblyIssue.tools,
      titleDe: 'Werkzeuge prüfen',
      titleAr: 'الاستفسار عن الأدوات',
      german:
          'Welche Werkzeuge brauche ich für den Aufbau? Reicht ein Schraubendreher?',
      arabic:
          'ما الأدوات التي أحتاجها للتركيب؟ هل يكفي مفك البراغي؟',
      keywords: <String>['Werkzeuge', 'Schraubendreher', 'Inbusschlüssel'],
    ),
    AssemblyScenario(
      id: 'montage-service',
      issue: AssemblyIssue.montageService,
      titleDe: 'Montageservice buchen',
      titleAr: 'طلب فني تركيب',
      german:
          'Kann ich einen Montageservice buchen, und ist die Befestigung an der Wand im Preis enthalten?',
      arabic:
          'هل يمكنني حجز خدمة تركيب، وهل تثبيت الأثاث على الحائط مشمول في السعر؟',
      keywords: <String>['Montageservice', 'buchen', 'Wand', 'Preis'],
    ),
  ];
}
