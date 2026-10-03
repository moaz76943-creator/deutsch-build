import 'package:flutter/foundation.dart';

import '../domain/housing_models.dart';

final class HousingMasterOrchestrator extends ChangeNotifier {
  HousingMasterOrchestrator({
    this.apartmentAgent = const ApartmentHuntingSubAgent(),
    this.maintenanceAgent = const MaintenanceRepairSubAgent(),
  });

  final ApartmentHuntingSubAgent apartmentAgent;
  final MaintenanceRepairSubAgent maintenanceAgent;

  HousingCategory _category = HousingCategory.apartmentHunting;
  HousingLevel _level = HousingLevel.a1a2;
  HousingQuickAction? _lastQuickAction;
  String? _lastQuickActionText;

  HousingCategory get category => _category;
  HousingLevel get level => _level;
  HousingQuickAction? get lastQuickAction => _lastQuickAction;
  String? get lastQuickActionText => _lastQuickActionText;

  List<HousingPhrase> get visiblePhrases => switch (_category) {
        HousingCategory.apartmentHunting =>
          apartmentAgent.phrasesFor(_level),
        HousingCategory.maintenanceRepair =>
          maintenanceAgent.phrasesFor(_level),
      };

  List<HousingQuickAction> get availableQuickActions => switch (_category) {
        HousingCategory.apartmentHunting =>
          apartmentAgent.quickActions,
        HousingCategory.maintenanceRepair =>
          maintenanceAgent.quickActions,
      };

  void switchCategory(HousingCategory category) {
    if (_category == category) return;
    _category = category;
    _clearQuickAction();
    notifyListeners();
  }

  void setLevel(HousingLevel level) {
    if (_level == level) return;
    _level = level;
    _clearQuickAction();
    notifyListeners();
  }

  String runQuickAction(HousingQuickAction action) {
    if (!availableQuickActions.contains(action)) {
      throw ArgumentError.value(
        action,
        'action',
        'Quick action is not available for the active housing category.',
      );
    }

    final text = switch (_category) {
      HousingCategory.apartmentHunting =>
        apartmentAgent.quickActionText(action),
      HousingCategory.maintenanceRepair =>
        maintenanceAgent.quickActionText(action),
    };

    _lastQuickAction = action;
    _lastQuickActionText = text;
    notifyListeners();
    return text;
  }

  void clearQuickAction() {
    if (_lastQuickAction == null && _lastQuickActionText == null) return;
    _clearQuickAction();
    notifyListeners();
  }

  void _clearQuickAction() {
    _lastQuickAction = null;
    _lastQuickActionText = null;
  }
}

final class ApartmentHuntingSubAgent {
  const ApartmentHuntingSubAgent();

  List<HousingPhrase> get phrases => _phrases;

  List<HousingQuickAction> get quickActions => const <HousingQuickAction>[
        HousingQuickAction.contactLandlord,
        HousingQuickAction.askAboutKaution,
      ];

  List<HousingPhrase> phrasesFor(HousingLevel level) => List<HousingPhrase>.unmodifiable(
        _phrases.where((item) => item.level == level),
      );

  String quickActionText(HousingQuickAction action) {
    return switch (action) {
      HousingQuickAction.contactLandlord =>
        'Guten Tag, ich interessiere mich für die Wohnung aus Ihrer Anzeige. '
            'Ist sie noch verfügbar?',
      HousingQuickAction.askAboutKaution =>
        'Könnten Sie mir bitte mitteilen, wie hoch die Kaution ist und '
            'wann sie zu zahlen ist?',
      _ => throw ArgumentError.value(
          action,
          'action',
          'Action does not belong to the apartment hunting sub-agent.',
        ),
    };
  }

  static const List<HousingPhrase> _phrases = <HousingPhrase>[
    HousingPhrase(
      id: 'apartment_a1_listing',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.a1a2,
      titleDe: 'Anzeige verstehen',
      textDe: 'Ich interessiere mich für die Wohnung aus Ihrer Anzeige.',
      explanationAr:
          'جملة بسيطة للتعبير عن الاهتمام بشقة شاهدتها في إعلان.',
    ),
    HousingPhrase(
      id: 'apartment_a1_landlord',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.a1a2,
      titleDe: 'Vermieter kontaktieren',
      textDe: 'Guten Tag, ist die Wohnung noch frei?',
      explanationAr:
          'سؤال مباشر ومهذب عند التواصل الأول مع المؤجر.',
    ),
    HousingPhrase(
      id: 'apartment_a1_kaution',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.a1a2,
      titleDe: 'Kaution',
      textDe: 'Wie hoch ist die Kaution?',
      explanationAr:
          'للسؤال عن قيمة التأمين المالي المطلوب عند الاستئجار.',
    ),
    HousingPhrase(
      id: 'apartment_b1_viewing',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.b1,
      titleDe: 'Besichtigung vereinbaren',
      textDe:
          'Könnten wir einen Termin für eine Wohnungsbesichtigung vereinbaren?',
      explanationAr:
          'صياغة مهذبة لطلب موعد لمعاينة الشقة.',
    ),
    HousingPhrase(
      id: 'apartment_b1_documents',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.b1,
      titleDe: 'Unterlagen',
      textDe: 'Welche Unterlagen benötigen Sie von mir?',
      explanationAr:
          'سؤال عن الوثائق التي يطلبها المؤجر قبل إتمام الإيجار.',
    ),
    HousingPhrase(
      id: 'apartment_b1_kaution_terms',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.b1,
      titleDe: 'Kaution klären',
      textDe:
          'Wann muss die Kaution gezahlt werden und in welcher Höhe?',
      explanationAr:
          'للتأكد من قيمة التأمين وموعد دفعه قبل توقيع العقد.',
    ),
    HousingPhrase(
      id: 'apartment_b2_listing_details',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.b2,
      titleDe: 'Angaben in der Anzeige klären',
      textDe:
          'Könnten Sie bitte erläutern, welche Nebenkosten in der Anzeige '
          'bereits berücksichtigt sind?',
      explanationAr:
          'سؤال تفصيلي للتأكد مما إذا كانت التكاليف الجانبية مشمولة في الإعلان.',
    ),
    HousingPhrase(
      id: 'apartment_b2_landlord_followup',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.b2,
      titleDe: 'Rückfrage an den Vermieter',
      textDe:
          'Ich möchte mich erkundigen, ob nach der Besichtigung noch '
          'weitere Angaben von mir benötigt werden.',
      explanationAr:
          'متابعة رسمية بعد المعاينة لمعرفة إن كانت هناك معلومات إضافية مطلوبة.',
    ),
    HousingPhrase(
      id: 'apartment_b2_kaution_receipt',
      category: HousingCategory.apartmentHunting,
      level: HousingLevel.b2,
      titleDe: 'Kaution dokumentieren',
      textDe:
          'Bitte bestätigen Sie mir schriftlich den Eingang der Kaution.',
      explanationAr:
          'طلب توثيق كتابي لاستلام مبلغ التأمين.',
    ),
  ];
}

final class MaintenanceRepairSubAgent {
  const MaintenanceRepairSubAgent();

  List<HousingPhrase> get phrases => _phrases;

  List<HousingQuickAction> get quickActions => const <HousingQuickAction>[
        HousingQuickAction.reportPlumbing,
        HousingQuickAction.reportHeating,
        HousingQuickAction.arrangeInternet,
      ];

  List<HousingPhrase> phrasesFor(HousingLevel level) => List<HousingPhrase>.unmodifiable(
        _phrases.where((item) => item.level == level),
      );

  String quickActionText(HousingQuickAction action) {
    return switch (action) {
      HousingQuickAction.reportPlumbing =>
        'Guten Tag, unter dem Waschbecken tritt Wasser aus. '
            'Könnten Sie bitte einen Termin für die Reparatur vereinbaren?',
      HousingQuickAction.reportHeating =>
        'Guten Tag, die Heizung wird nicht warm. '
            'Bitte teilen Sie mir mit, wann sie geprüft werden kann.',
      HousingQuickAction.arrangeInternet =>
        'Guten Tag, ich möchte einen Termin für die Internetinstallation '
            'in meiner Wohnung vereinbaren.',
      _ => throw ArgumentError.value(
          action,
          'action',
          'Action does not belong to the maintenance sub-agent.',
        ),
    };
  }

  static const List<HousingPhrase> _phrases = <HousingPhrase>[
    HousingPhrase(
      id: 'maintenance_a1_water',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.a1a2,
      titleDe: 'Wasserproblem',
      textDe: 'Unter dem Waschbecken tritt Wasser aus.',
      explanationAr:
          'وصف بسيط لتسرب مياه تحت حوض الغسيل.',
    ),
    HousingPhrase(
      id: 'maintenance_a1_heating',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.a1a2,
      titleDe: 'Heizung',
      textDe: 'Die Heizung wird nicht warm.',
      explanationAr:
          'جملة مباشرة للإبلاغ عن أن التدفئة لا تعمل بشكل صحيح.',
    ),
    HousingPhrase(
      id: 'maintenance_a1_internet',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.a1a2,
      titleDe: 'Internetinstallation',
      textDe: 'Ich brauche einen Termin für die Internetinstallation.',
      explanationAr:
          'لطلب موعد أساسي لتركيب خدمة الإنترنت.',
    ),
    HousingPhrase(
      id: 'maintenance_b1_plumber',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.b1,
      titleDe: 'Installateur anfragen',
      textDe:
          'Seit heute verliert die Leitung unter der Spüle Wasser. '
          'Wann kann ein Handwerker kommen?',
      explanationAr:
          'بلاغ أوضح عن مشكلة في تمديدات المياه وطلب موعد للفني.',
    ),
    HousingPhrase(
      id: 'maintenance_b1_heating',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.b1,
      titleDe: 'Heizung prüfen lassen',
      textDe:
          'Die Heizung funktioniert seit gestern nicht zuverlässig. '
          'Könnten Sie sie bitte prüfen lassen?',
      explanationAr:
          'صياغة مهذبة لطلب فحص التدفئة عندما يكون العطل متقطعاً.',
    ),
    HousingPhrase(
      id: 'maintenance_b1_internet',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.b1,
      titleDe: 'Internet-Termin abstimmen',
      textDe:
          'Welche Termine sind für die Installation des Internetanschlusses '
          'verfügbar?',
      explanationAr:
          'للسؤال عن المواعيد المتاحة لتركيب اتصال الإنترنت.',
    ),
    HousingPhrase(
      id: 'maintenance_b2_water_damage',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.b2,
      titleDe: 'Wasserschaden präzise melden',
      textDe:
          'An der Leitung unter dem Waschbecken ist ein Leck aufgetreten. '
          'Ich bitte um eine zeitnahe fachgerechte Reparatur.',
      explanationAr:
          'بلاغ رسمي ودقيق عن تسرب مع طلب إصلاح مهني في وقت مناسب.',
    ),
    HousingPhrase(
      id: 'maintenance_b2_heating_deadline',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.b2,
      titleDe: 'Heizungsstörung dokumentieren',
      textDe:
          'Die Heizungsanlage fällt wiederholt aus. Bitte bestätigen Sie mir '
          'schriftlich, wann die Überprüfung stattfinden kann.',
      explanationAr:
          'طلب رسمي مع توثيق كتابي لموعد فحص عطل تدفئة متكرر.',
    ),
    HousingPhrase(
      id: 'maintenance_b2_internet_coordination',
      category: HousingCategory.maintenanceRepair,
      level: HousingLevel.b2,
      titleDe: 'Internetinstallation koordinieren',
      textDe:
          'Für die Installation des Internetanschlusses benötige ich einen '
          'verbindlichen Termin innerhalb des angekündigten Zeitfensters.',
      explanationAr:
          'صياغة متقدمة لطلب موعد مؤكد ضمن الفترة الزمنية التي تم الإعلان عنها.',
    ),
  ];
}
