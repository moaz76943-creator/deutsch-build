import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_childcare_kindergarten/childcare_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_childcare_kindergarten/childcare_screen.dart';
import 'package:deutsch_bilarabi/features/life_childcare_kindergarten/enrollment_attendance_agent.dart';
import 'package:deutsch_bilarabi/features/life_childcare_kindergarten/parent_meetings_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ChildcareMasterHub _hub() => ChildcareMasterHub(
      entries: <ChildcarePhrase>[
        ...EnrollmentAttendanceAgent.entries,
        ...ParentMeetingsAgent.entries,
      ],
    );

void main() {
  group('ChildcareMasterHub', () {
    test('searches registration absence and parent meeting content', () {
      final hub = _hub();

      expect(hub.visibleEntries.length, 12);
      hub.setQuery('Abwesenheit');
      expect(
        hub.visibleEntries.any((entry) => entry.id == 'childcare-absence'),
        isTrue,
      );

      hub.setQuery('اجتماع');
      expect(
        hub.visibleEntries.any((entry) => entry.id == 'parent-meeting-date'),
        isTrue,
      );
    });

    test('category toggle isolates parent communication', () {
      final hub = _hub();
      hub.toggleCategory(ChildcareCategory.enrollmentAttendance);

      expect(
        hub.visibleEntries.every(
          (entry) => entry.category == ChildcareCategory.parentCommunication,
        ),
        isTrue,
      );
    });

    test('absence status exposes a direct notification sentence', () {
      final hub = _hub();
      hub.setStatus(ChildcareStatus.absentToday);

      expect(hub.statusPromptDe, contains('nicht kommen'));
      expect(hub.statusPromptDe, contains('Abwesenheit'));
      expect(hub.statusPromptAr, contains('الغياب'));
    });
  });

  test('branch agents cover enrollment attendance and parent meetings', () {
    final enrollment = EnrollmentAttendanceAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');
    final parents = ParentMeetingsAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');

    expect(enrollment, contains('Kind anmelden'));
    expect(enrollment, contains('Eingewöhnung'));
    expect(enrollment, contains('Abwesenheit melden'));
    expect(enrollment, contains('Abholberechtigung'));
    expect(parents, contains('Elterngespräch'));
    expect(parents, contains('Elternabend'));
    expect(parents, contains('Entwicklung'));
  });

  testWidgets('childcare screen is safe scrollable and bilingual',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ChildcareKindergartenMasterScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Kita · Kindergarten · Schule'), findsOneWidget);

    final search = find.byKey(const ValueKey<String>('childcare-search'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Elternabend');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('childcare-entry-parent-evening')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('childcare-entry-childcare-registration')),
      findsNothing,
    );
  });
}
