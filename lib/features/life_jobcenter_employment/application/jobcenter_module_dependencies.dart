import '../domain/jobcenter_models.dart';

final class JobcenterModuleDependencies {
  const JobcenterModuleDependencies({
    required this.consultationRoute,
    required this.applicationsRoute,
  });

  factory JobcenterModuleDependencies.standard() =>
      const JobcenterModuleDependencies(
        consultationRoute: JobcenterRouteSpec(
          id: 'jobcenter-consultation',
          path: '/life/jobcenter/consultation',
          labelDe: 'Beratung & Jobsuche',
          labelAr: 'الاستشارة والبحث عن عمل',
        ),
        applicationsRoute: JobcenterRouteSpec(
          id: 'jobcenter-applications',
          path: '/life/jobcenter/applications',
          labelDe: 'Anträge & Bescheide',
          labelAr: 'الطلبات والإشعارات',
        ),
      );

  final JobcenterRouteSpec consultationRoute;
  final JobcenterRouteSpec applicationsRoute;
}
