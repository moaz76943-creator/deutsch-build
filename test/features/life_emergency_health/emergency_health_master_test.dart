import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/emergency_health_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/emergency_health_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/emergency_health_models.dart';
import 'package:deutsch_bilarabi/features/life_emergency_health/emergency_health_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSource implements EmergencyHealthContentSource {
  const _FakeSource(this.domain, this.items);

  @override
  final EmergencyHealthDomain domain;

  @override
  final List<EmergencyPhrase> items;
}

void main() {
  group('EmergencyHealthModule', () {
    test('exposes a stable route and injects content sources', () {
      final source = _FakeSource(
        EmergencyHealthDomain.ambulance112,
        const <EmergencyPhrase>[
          EmergencyPhrase(
            id: 'test_112',
            domain: EmergencyHealthDomain.ambulance112,
            urgency: EmergencyUrgency.lifeThreatening,
            titleDe: 'Notruf',
            titleAr: 'اتصال طوارئ',
            german: 'Rufen Sie bitte einen Rettungswagen.',
            arabic: 'يرجى إرسال سيارة إسعاف.',
            explanationAr: 'جملة طوارئ تجريبية.',
            tags: <String>['112', 'Rettungswagen'],
          ),
        ],
      );

      final module = EmergencyHealthModule(
        dependencies: EmergencyHealthDependencies(
          contentSources: <EmergencyHealthContentSource>[source],
        ),
      );

      expect(EmergencyHealthModule.routeName, '/life/emergency-health');
      expect(module.createOrchestrator().visibleItems.single.id, 'test_112');
    });
  });

  group('EmergencyHealthMasterOrchestrator', () {
    test('switches domains and searches injected bilingual content', () {
      final orchestrator = EmergencyHealthMasterOrchestrator(
        contentSources: <EmergencyHealthContentSource>[
          _FakeSource(
            EmergencyHealthDomain.ambulance112,
            const <EmergencyPhrase>[
              EmergencyPhrase(
                id: 'ambulance_location',
                domain: EmergencyHealthDomain.ambulance112,
                urgency: EmergencyUrgency.lifeThreatening,
                titleDe: 'Standort',
                titleAr: 'الموقع',
                german: 'Der Notfall ist am Hauptbahnhof.',
                arabic: 'حالة الطوارئ في المحطة الرئيسية.',
                explanationAr: 'اذكر المكان بدقة.',
                tags: <String>['Wo', 'Standort'],
              ),
            ],
          ),
          _FakeSource(
            EmergencyHealthDomain.medicalOnCall,
            const <EmergencyPhrase>[
              EmergencyPhrase(
                id: 'doctor_pain',
                domain: EmergencyHealthDomain.medicalOnCall,
                urgency: EmergencyUrgency.urgentNonLifeThreatening,
                titleDe: 'Schmerzen',
                titleAr: 'الألم',
                german: 'Ich habe starke Schmerzen im Rücken.',
                arabic: 'لدي ألم شديد في الظهر.',
                explanationAr: 'صف الموضع والشدة.',
                tags: <String>['116117', 'Schmerzen'],
              ),
            ],
          ),
        ],
      );

      expect(orchestrator.domain, EmergencyHealthDomain.ambulance112);
      expect(orchestrator.visibleItems.single.id, 'ambulance_location');

      orchestrator.setQuery('المحطة');
      expect(orchestrator.visibleItems.single.id, 'ambulance_location');

      orchestrator.switchDomain(EmergencyHealthDomain.medicalOnCall);
      expect(orchestrator.query, isEmpty);
      orchestrator.setQuery('Rücken');
      expect(orchestrator.visibleItems.single.id, 'doctor_pain');
    });

    test('tracks the immediate-action checklist safely', () {
      final orchestrator = EmergencyHealthMasterOrchestrator();

      expect(orchestrator.immediateActions, hasLength(5));
      expect(orchestrator.completedActionCount, 0);
      expect(orchestrator.isImmediateChecklistComplete, isFalse);

      for (final action in orchestrator.immediateActions) {
        orchestrator.setActionComplete(action.id, true);
      }

      expect(orchestrator.completedActionCount, 5);
      expect(orchestrator.isImmediateChecklistComplete, isTrue);

      expect(
        () => orchestrator.setActionComplete('missing-action', true),
        throwsArgumentError,
      );
    });
  });

  testWidgets('master hub uses project glass UI and explicit BiDi', (tester) async {
    final orchestrator = EmergencyHealthMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyHealthMasterHub(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'Notruf, Notdienst & medizinische Hilfe',
      ),
    );
    expect(german.languageCode, 'de');

    final arabic = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'طوارئ الصحة والخدمات الطبية',
      ),
    );
    expect(arabic.languageCode, 'ar');
  });
}
