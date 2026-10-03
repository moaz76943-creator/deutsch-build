import 'package:deutsch_bilarabi/features/life_doctor_appointment/application/doctor_appointment_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_doctor_appointment/domain/doctor_appointment_models.dart';
import 'package:deutsch_bilarabi/features/life_doctor_appointment/presentation/doctor_appointment_master_hub.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoctorAppointmentMasterOrchestrator', () {
    const orchestrator = DoctorAppointmentMasterOrchestrator();

    test('offers Hausarzt and Facharzt journeys', () {
      expect(
        orchestrator.clinicTypes,
        <DoctorClinicType>[
          DoctorClinicType.hausarzt,
          DoctorClinicType.facharzt,
        ],
      );
    });

    test('exposes shared insurance, referral, and appointment models', () {
      expect(orchestrator.documents, isNotEmpty);
      expect(
        orchestrator.documents.map((item) => item.kind),
        contains(DoctorDocumentKind.gesundheitskarte),
      );
      expect(
        orchestrator.documents.map((item) => item.kind),
        contains(DoctorDocumentKind.ueberweisung),
      );
      expect(orchestrator.appointmentChecklist, isNotEmpty);
    });

    test('search is bilingual and scoped to clinic type', () {
      final german = orchestrator.search('Gesundheitskarte');
      final arabic = orchestrator.search('إحالة');
      final specialist = orchestrator.search(
        'Facharzt',
        clinicType: DoctorClinicType.facharzt,
      );

      expect(german, isNotEmpty);
      expect(arabic, isNotEmpty);
      expect(
        specialist.every(
          (item) =>
              item.clinicType == null ||
              item.clinicType == DoctorClinicType.facharzt,
        ),
        isTrue,
      );
    });
  });

  testWidgets('master hub uses project design shell and explicit BiDi',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DoctorAppointmentMasterHub(
          orchestrator: DoctorAppointmentMasterOrchestrator(),
        ),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Arztbesuch & Termin'), findsOneWidget);
    expect(find.textContaining('تدريب لغوي'), findsOneWidget);
  });
}
