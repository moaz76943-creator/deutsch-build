import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/application/haircut_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/domain/haircut_models.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/presentation/haircut_master_screen.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/styles/haircut_phrase.dart';

void main() {
  test('shared salon models preserve services hours and preferences', () {
    const service = HaircutServiceOption(
      id: 'classic-cut',
      kind: HaircutServiceKind.classicHaircut,
      germanName: 'Klassischer Haarschnitt',
      arabicName: 'قصة شعر كلاسيكية',
      estimatedMinutes: 30,
    );
    const hours = SalonOpeningHours(
      dayDe: 'Montag',
      opensAt: '09:00',
      closesAt: '18:00',
    );
    const appointment = HaircutAppointmentPreference(
      mode: HaircutAppointmentMode.reserved,
      preferredDayDe: 'Montag',
      preferredTime: '15:30',
    );
    const grooming = ClassicGroomingPreference(
      haircutNoteDe: 'Bitte gleichmäßig und gepflegt.',
      beardNoteDe: 'Bart nur etwas stutzen.',
      washHair: true,
      gentleDrying: true,
    );

    expect(service.estimatedMinutes, 30);
    expect(hours.labelDe, 'Montag · 09:00–18:00');
    expect(appointment.mode, HaircutAppointmentMode.reserved);
    expect(grooming.washHair, isTrue);
    expect(grooming.gentleDrying, isTrue);
  });

  test('module exposes stable route and isolated orchestrators', () {
    const module = HaircutBarbershopModule();
    final first = module.createOrchestrator();
    final second = module.createOrchestrator();

    first.setQuery('Termin');

    expect(HaircutBarbershopModule.routeName, '/life/haircut-barbershop');
    expect(first.query, 'Termin');
    expect(second.query, isEmpty);

    first.dispose();
    second.dispose();
  });

  test('master orchestrator aggregates both salon sub-agents', () {
    const module = HaircutBarbershopModule();
    final orchestrator = module.createOrchestrator();
    addTearDown(orchestrator.dispose);

    final topics = orchestrator.results.map((phrase) => phrase.topic).toSet();

    expect(topics, contains(HaircutTopic.appointment));
    expect(topics, contains(HaircutTopic.haircut));
    expect(topics, contains(HaircutTopic.beardMoustache));
    expect(topics, contains(HaircutTopic.washing));
    expect(topics, contains(HaircutTopic.care));
    expect(topics, contains(HaircutTopic.payment));
  });

  test('master search and level filter remain deterministic', () {
    const module = HaircutBarbershopModule();
    final orchestrator = module.createOrchestrator();
    addTearDown(orchestrator.dispose);

    orchestrator.setLevel(HaircutLevel.b1);
    orchestrator.setQuery('bitte');

    expect(orchestrator.results, isNotEmpty);
    expect(
      orchestrator.results.every((phrase) => phrase.level == HaircutLevel.b1),
      isTrue,
    );

    orchestrator.resetFilters();
    expect(orchestrator.level, isNull);
    expect(orchestrator.query, isEmpty);
  });

  test('quick salon phrases come from appointment and payment branches', () {
    const module = HaircutBarbershopModule();
    final orchestrator = module.createOrchestrator();
    addTearDown(orchestrator.dispose);

    final topics = orchestrator.quickPhrases.map((phrase) => phrase.topic).toSet();

    expect(topics, contains(HaircutTopic.appointment));
    expect(topics, contains(HaircutTopic.washing));
    expect(topics, contains(HaircutTopic.payment));
  });

  testWidgets('master hub uses glass cards safe scroll and explicit BiDi',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HaircutMasterScreen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Friseursalon & Barbershop'), findsOneWidget);
  });
}
