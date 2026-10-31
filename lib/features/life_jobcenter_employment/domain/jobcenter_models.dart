enum JobcenterSection {
  overview,
  consultationJobs,
  applicationsNotices,
}

enum JobcenterRequestStatus {
  preparation,
  submitted,
  appointmentPlanned,
}

extension JobcenterSectionLabels on JobcenterSection {
  String get labelDe => switch (this) {
        JobcenterSection.overview => 'Übersicht',
        JobcenterSection.consultationJobs => 'Beratung & Jobsuche',
        JobcenterSection.applicationsNotices => 'Anträge & Bescheide',
      };

  String get labelAr => switch (this) {
        JobcenterSection.overview => 'نظرة عامة',
        JobcenterSection.consultationJobs => 'الاستشارة والبحث عن عمل',
        JobcenterSection.applicationsNotices => 'الطلبات والإشعارات',
      };
}

extension JobcenterRequestStatusLabels on JobcenterRequestStatus {
  String get labelDe => switch (this) {
        JobcenterRequestStatus.preparation => 'Vorbereitung',
        JobcenterRequestStatus.submitted => 'Eingereicht',
        JobcenterRequestStatus.appointmentPlanned => 'Termin geplant',
      };

  String get labelAr => switch (this) {
        JobcenterRequestStatus.preparation => 'قيد التجهيز',
        JobcenterRequestStatus.submitted => 'تم التقديم',
        JobcenterRequestStatus.appointmentPlanned => 'موعد مخطط',
      };
}

final class JobcenterRouteSpec {
  const JobcenterRouteSpec({
    required this.id,
    required this.path,
    required this.labelDe,
    required this.labelAr,
  });

  final String id;
  final String path;
  final String labelDe;
  final String labelAr;
}

final class BuergergeldRequestModel {
  const BuergergeldRequestModel({
    required this.id,
    required this.programNameDe,
    required this.programNameAr,
    required this.status,
    required this.includesHousingCosts,
  });

  final String id;
  final String programNameDe;
  final String programNameAr;
  final JobcenterRequestStatus status;
  final bool includesHousingCosts;
}

final class CourseFundingRequestModel {
  const CourseFundingRequestModel({
    required this.id,
    required this.courseNameDe,
    required this.courseNameAr,
    required this.status,
    required this.fundingQuestionDe,
  });

  final String id;
  final String courseNameDe;
  final String courseNameAr;
  final JobcenterRequestStatus status;
  final String fundingQuestionDe;
}

final class ConsultationAppointmentModel {
  const ConsultationAppointmentModel({
    required this.id,
    required this.officeNameDe,
    required this.officeNameAr,
    required this.purposeDe,
    required this.purposeAr,
    required this.status,
  });

  final String id;
  final String officeNameDe;
  final String officeNameAr;
  final String purposeDe;
  final String purposeAr;
  final JobcenterRequestStatus status;
}

final class JobcenterHubEntry {
  const JobcenterHubEntry({
    required this.id,
    required this.section,
    required this.titleDe,
    required this.titleAr,
    required this.bodyDe,
    required this.bodyAr,
    this.keywords = const <String>[],
  });

  final String id;
  final JobcenterSection section;
  final String titleDe;
  final String titleAr;
  final String bodyDe;
  final String bodyAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = <String>[
      id,
      titleDe,
      titleAr,
      bodyDe,
      bodyAr,
      section.labelDe,
      section.labelAr,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(needle);
  }
}
