import 'car_service_models.dart';

final class TuevInspectionSubAgent {
  const TuevInspectionSubAgent();

  List<CarServicePhrase> get phrases => const <CarServicePhrase>[
        CarServicePhrase(
          id: 'hu-appointment',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.huPreparation,
          titleDe: 'Termin für die Hauptuntersuchung',
          titleAr: 'حجز موعد للفحص الدوري',
          german:
              'Ich möchte einen Termin für die Hauptuntersuchung vereinbaren.',
          arabic:
              'أريد حجز موعد لإجراء الفحص الدوري للمركبة.',
          keywords: <String>['HU', 'TÜV', 'DEKRA', 'Termin', 'فحص'],
        ),
        CarServicePhrase(
          id: 'hu-documents',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.huPreparation,
          titleDe: 'Unterlagen vorbereiten',
          titleAr: 'تحضير الأوراق المطلوبة',
          german:
              'Welche Unterlagen soll ich zur Hauptuntersuchung mitbringen?',
          arabic:
              'ما الأوراق التي يجب أن أحضرها معي إلى الفحص الدوري؟',
          noteDe:
              'In der Regel wird die Zulassungsbescheinigung Teil I benötigt.',
          noteAr:
              'عادةً تكون شهادة تسجيل المركبة – الجزء الأول مطلوبة.',
          keywords: <String>['Fahrzeugschein', 'Zulassungsbescheinigung', 'أوراق'],
        ),
        CarServicePhrase(
          id: 'hu-check-prep',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.huPreparation,
          titleDe: 'Vorher selbst prüfen',
          titleAr: 'فحص أشياء بسيطة مسبقًا',
          german:
              'Ich möchte vor der HU Beleuchtung, Reifen und Sicherheitsausstattung prüfen.',
          arabic:
              'أريد قبل الفحص الدوري التأكد من الإضاءة والإطارات وتجهيزات السلامة.',
          keywords: <String>['Beleuchtung', 'Reifen', 'Sicherheitsausstattung'],
        ),
        CarServicePhrase(
          id: 'hu-minor-defects',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.inspectionReport,
          titleDe: 'Geringe Mängel verstehen',
          titleAr: 'فهم العيوب البسيطة',
          german:
              'Im Prüfbericht stehen Geringe Mängel. Was soll ich zeitnah beheben lassen?',
          arabic:
              'يذكر تقرير الفحص وجود عيوب بسيطة. ما الذي ينبغي إصلاحه قريبًا؟',
          noteDe:
              'Bei geringen Mängeln kann die Plakette erteilt werden; die Beanstandungen sollen trotzdem zeitnah behoben werden.',
          noteAr:
              'عند وجود عيوب بسيطة يمكن منح الملصق، لكن ينبغي إصلاح الملاحظات في وقت قريب.',
          keywords: <String>['Geringe Mängel', 'Prüfbericht', 'عيوب بسيطة'],
        ),
        CarServicePhrase(
          id: 'hu-major-defects',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.inspectionReport,
          titleDe: 'Erhebliche Mängel verstehen',
          titleAr: 'فهم العيوب الجسيمة',
          german:
              'Im Prüfbericht stehen Erhebliche Mängel. Was muss vor der Nachprüfung repariert werden?',
          arabic:
              'يذكر تقرير الفحص وجود عيوب جسيمة. ما الذي يجب إصلاحه قبل إعادة الفحص؟',
          noteDe:
              'Bei erheblichen Mängeln wird zunächst keine neue HU-Plakette erteilt; die Mängel müssen für die Nachprüfung behoben werden.',
          noteAr:
              'عند وجود عيوب جسيمة لا يُمنح ملصق فحص جديد أولًا، ويجب إصلاح العيوب قبل إعادة الفحص.',
          keywords: <String>['Erhebliche Mängel', 'Nachprüfung', 'عيوب جسيمة'],
        ),
        CarServicePhrase(
          id: 'hu-report-question',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.inspectionReport,
          titleDe: 'Prüfbericht erklären lassen',
          titleAr: 'طلب شرح تقرير الفحص',
          german:
              'Können Sie mir bitte erklären, welche Punkte im Prüfbericht besonders wichtig sind?',
          arabic:
              'هل يمكنكم شرح أهم النقاط الواردة في تقرير الفحص من فضلكم؟',
          keywords: <String>['Bericht', 'Mängel', 'شرح'],
        ),
        CarServicePhrase(
          id: 'hu-sticker-read',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.inspectionSticker,
          titleDe: 'HU-Plakette ablesen',
          titleAr: 'قراءة ملصق الفحص',
          german:
              'Wie lese ich auf der HU-Plakette Monat und Jahr der nächsten Hauptuntersuchung ab?',
          arabic:
              'كيف أقرأ شهر وسنة موعد الفحص الدوري القادم من ملصق الفحص؟',
          noteDe:
              'Die Zahl oben zeigt den Fälligkeitsmonat; die Zahl in der Mitte zeigt das Jahr.',
          noteAr:
              'الرقم الموجود في الأعلى يوضح شهر الاستحقاق، والرقم في المنتصف يوضح السنة.',
          keywords: <String>['Plakette', 'Monat', 'Jahr', 'صلاحية'],
        ),
        CarServicePhrase(
          id: 'hu-sticker-validity',
          mode: CarServiceMode.inspection,
          topic: CarServiceTopic.inspectionSticker,
          titleDe: 'Fälligkeit bestätigen',
          titleAr: 'التأكد من موعد الاستحقاق',
          german:
              'Ist meine HU-Plakette noch gültig, und in welchem Monat ist die nächste Untersuchung fällig?',
          arabic:
              'هل ملصق الفحص ما زال ساريًا، وفي أي شهر يحين موعد الفحص القادم؟',
          keywords: <String>['gültig', 'Fälligkeit', 'موعد'],
        ),
      ];
}
