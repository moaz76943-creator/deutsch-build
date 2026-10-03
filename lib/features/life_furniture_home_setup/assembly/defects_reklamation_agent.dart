import 'assembly_models.dart';

final class DefectsReklamationAgent {
  const DefectsReklamationAgent();

  List<AssemblyScenario> get scenarios => _scenarios;

  static const List<AssemblyScenario> _scenarios = <AssemblyScenario>[
    AssemblyScenario(
      id: 'missing-part',
      issue: AssemblyIssue.missingPart,
      titleDe: 'Fehlendes Teil melden',
      titleAr: 'الإبلاغ عن قطعة ناقصة',
      german:
          'In meinem Paket fehlt Teil B7. Können Sie mir das fehlende Teil bitte nachsenden?',
      arabic:
          'القطعة B7 غير موجودة في الطرد. هل يمكنكم إرسال القطعة الناقصة لي؟',
      keywords: <String>['fehlendes Teil', 'fehlt', 'nachsenden', 'B7'],
    ),
    AssemblyScenario(
      id: 'wrong-screw',
      issue: AssemblyIssue.wrongScrew,
      titleDe: 'Falsche Schrauben reklamieren',
      titleAr: 'الإبلاغ عن براغي غير مطابقة',
      german:
          'Die gelieferten Schrauben passen nicht zur Aufbauanleitung. Ich brauche bitte die richtigen Schrauben.',
      arabic:
          'البراغي المرسلة لا تطابق دليل التركيب. أحتاج البراغي الصحيحة من فضلكم.',
      keywords: <String>['Schrauben', 'passen nicht', 'Aufbauanleitung'],
    ),
    AssemblyScenario(
      id: 'replace-scratched-part',
      issue: AssemblyIssue.transportDamage,
      titleDe: 'Verkratztes Teil ersetzen',
      titleAr: 'استبدال جزء مخدوش',
      german:
          'Die Frontplatte ist beim Transport verkratzt angekommen. Ich möchte das beschädigte Teil reklamieren und ersetzen lassen.',
      arabic:
          'وصلت الواجهة مخدوشة أثناء النقل. أريد تقديم شكوى واستبدال الجزء المتضرر.',
      keywords: <String>[
        'verkratzt',
        'beschädigt',
        'Transport',
        'Reklamation',
        'ersetzen',
      ],
    ),
    AssemblyScenario(
      id: 'document-damage',
      issue: AssemblyIssue.transportDamage,
      titleDe: 'Transportschaden dokumentieren',
      titleAr: 'توثيق ضرر النقل',
      german:
          'Welche Fotos und Angaben benötigen Sie für die Reklamation des Transportschadens?',
      arabic:
          'ما الصور والبيانات التي تحتاجونها لتقديم شكوى عن ضرر النقل؟',
      keywords: <String>['Fotos', 'Angaben', 'Transportschaden'],
    ),
  ];
}
