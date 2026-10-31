import 'package:flutter/foundation.dart';

import '../domain/jobcenter_models.dart';
import 'jobcenter_module_dependencies.dart';

final class JobcenterMasterOrchestrator extends ChangeNotifier {
  JobcenterMasterOrchestrator({
    JobcenterModuleDependencies? dependencies,
  }) : dependencies =
            dependencies ?? JobcenterModuleDependencies.standard();

  final JobcenterModuleDependencies dependencies;

  JobcenterSection _activeSection = JobcenterSection.overview;
  String _query = '';

  JobcenterSection get activeSection => _activeSection;
  String get query => _query;

  List<BuergergeldRequestModel> get benefitRequests =>
      _benefitRequests;
  List<CourseFundingRequestModel> get courseRequests =>
      _courseRequests;
  List<ConsultationAppointmentModel> get appointments =>
      _appointments;

  List<JobcenterHubEntry> get visibleEntries =>
      List<JobcenterHubEntry>.unmodifiable(
        _entries.where(
          (entry) =>
              entry.section == _activeSection &&
              entry.matches(_query),
        ),
      );

  JobcenterRouteSpec? get activeRoute => switch (_activeSection) {
        JobcenterSection.overview => null,
        JobcenterSection.consultationJobs =>
          dependencies.consultationRoute,
        JobcenterSection.applicationsNotices =>
          dependencies.applicationsRoute,
      };

  void setSection(JobcenterSection section) {
    if (_activeSection == section) return;
    _activeSection = section;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  static const List<BuergergeldRequestModel> _benefitRequests =
      <BuergergeldRequestModel>[
    BuergergeldRequestModel(
      id: 'buergergeld-main',
      programNameDe: 'Bürgergeld · Hauptantrag',
      programNameAr: 'إعانة Bürgergeld · الطلب الرئيسي',
      status: JobcenterRequestStatus.preparation,
      includesHousingCosts: true,
    ),
  ];

  static const List<CourseFundingRequestModel> _courseRequests =
      <CourseFundingRequestModel>[
    CourseFundingRequestModel(
      id: 'integration-course',
      courseNameDe: 'Integrationskurs / Sprachkurs',
      courseNameAr: 'دورة اندماج / دورة لغة',
      status: JobcenterRequestStatus.preparation,
      fundingQuestionDe:
          'Welche Förderung ist möglich und welche Voraussetzungen gelten?',
    ),
  ];

  static const List<ConsultationAppointmentModel> _appointments =
      <ConsultationAppointmentModel>[
    ConsultationAppointmentModel(
      id: 'employment-consultation',
      officeNameDe: 'Agentur für Arbeit / Jobcenter',
      officeNameAr: 'وكالة العمل / الجوب سنتر',
      purposeDe: 'Beratung zu Arbeit, Qualifizierung und nächsten Schritten',
      purposeAr: 'استشارة حول العمل والتأهيل والخطوات التالية',
      status: JobcenterRequestStatus.appointmentPlanned,
    ),
  ];

  static const List<JobcenterHubEntry> _entries =
      <JobcenterHubEntry>[
    JobcenterHubEntry(
      id: 'overview-buergergeld',
      section: JobcenterSection.overview,
      titleDe: 'Bürgergeld',
      titleAr: 'إعانة Bürgergeld',
      bodyDe:
          'Hauptantrag, Kosten der Unterkunft und Bearbeitungsstand sprachlich vorbereiten.',
      bodyAr:
          'تحضير لغة الطلب الرئيسي وتكاليف السكن والاستفسار عن حالة المعالجة.',
      keywords: <String>['Hauptantrag', 'Unterkunft', 'KdU'],
    ),
    JobcenterHubEntry(
      id: 'overview-course',
      section: JobcenterSection.overview,
      titleDe: 'Integrationskurs & Sprachkurs',
      titleAr: 'دورة الاندماج ودورة اللغة',
      bodyDe:
          'Fragen zu möglicher Förderung, Voraussetzungen und benötigten Unterlagen.',
      bodyAr:
          'أسئلة عن إمكانية التمويل والشروط والمستندات المطلوبة.',
      keywords: <String>['Förderung', 'Kurs', 'دورة اللغة'],
    ),
    JobcenterHubEntry(
      id: 'overview-appointment',
      section: JobcenterSection.overview,
      titleDe: 'Beratungstermin',
      titleAr: 'موعد الاستشارة',
      bodyDe:
          'Termin beim Jobcenter oder bei der Agentur für Arbeit vorbereiten.',
      bodyAr:
          'التحضير لموعد لدى الجوب سنتر أو وكالة العمل.',
      keywords: <String>['Termin', 'Sachbearbeiter', 'موعد'],
    ),
    JobcenterHubEntry(
      id: 'consultation-skills',
      section: JobcenterSection.consultationJobs,
      titleDe: 'Berufliche Fähigkeiten erklären',
      titleAr: 'شرح المهارات المهنية',
      bodyDe:
          'Erfahrung, Qualifikationen und gewünschte Tätigkeiten strukturiert beschreiben.',
      bodyAr:
          'شرح الخبرة والمؤهلات ونوع العمل المطلوب بشكل منظم.',
      keywords: <String>['Kenntnisse', 'Erfahrung', 'خبرة'],
    ),
    JobcenterHubEntry(
      id: 'consultation-course',
      section: JobcenterSection.consultationJobs,
      titleDe: 'Sprachkurs-Förderung erfragen',
      titleAr: 'السؤال عن تمويل دورة اللغة',
      bodyDe:
          'Nach Möglichkeit, Voraussetzungen und Unterlagen für Integrations- oder Sprachkurse fragen.',
      bodyAr:
          'السؤال عن الإمكانية والشروط والمستندات لدورة الاندماج أو اللغة.',
      keywords: <String>['Integrationskurs', 'Sprachkurs', 'دورة اللغة'],
    ),
    JobcenterHubEntry(
      id: 'consultation-applications',
      section: JobcenterSection.consultationJobs,
      titleDe: 'Bewerbungen nachverfolgen',
      titleAr: 'متابعة طلبات التوظيف',
      bodyDe:
          'Bewerbungsstand, nächste Schritte und mögliche Fahrtkosten zur Vorstellung klären.',
      bodyAr:
          'متابعة حالة طلبات التوظيف والخطوات التالية وإمكانية تكاليف السفر للمقابلة.',
      keywords: <String>['Bewerbungen', 'Fahrtkosten', 'مقابلة'],
    ),
    JobcenterHubEntry(
      id: 'applications-main',
      section: JobcenterSection.applicationsNotices,
      titleDe: 'Hauptantrag & Unterkunft',
      titleAr: 'الطلب الرئيسي وتكاليف السكن',
      bodyDe:
          'Felder im Hauptantrag und Angaben zu Kosten der Unterkunft verstehen.',
      bodyAr:
          'فهم حقول الطلب الرئيسي وبيانات تكاليف السكن.',
      keywords: <String>['Hauptantrag', 'Kosten der Unterkunft', 'السكن'],
    ),
    JobcenterHubEntry(
      id: 'applications-notice',
      section: JobcenterSection.applicationsNotices,
      titleDe: 'Bewilligungsbescheid verstehen',
      titleAr: 'فهم إشعار الموافقة',
      bodyDe:
          'Bewilligungszeitraum und monatliche Beträge gezielt nachfragen.',
      bodyAr:
          'الاستفسار عن مدة الاستحقاق والمبالغ الشهرية بشكل واضح.',
      keywords: <String>['Bewilligungsbescheid', 'Leistung', 'شهري'],
    ),
    JobcenterHubEntry(
      id: 'applications-objection',
      section: JobcenterSection.applicationsNotices,
      titleDe: 'Widerspruch & Zahlungsstatus',
      titleAr: 'الاعتراض وحالة الدفعة',
      bodyDe:
          'Frist im eigenen Bescheid prüfen, Eingang bestätigen lassen und Zahlungsstatus erfragen.',
      bodyAr:
          'فحص المهلة المكتوبة في الإشعار وطلب تأكيد الاستلام والاستفسار عن حالة الدفعة.',
      keywords: <String>['Widerspruch', 'Zahlung', 'اعتراض'],
    ),
  ];
}
