import 'package:deutsch_bilarabi/core/infrastructure/sys_ci_cd_workflow_fixer/ci_cd_workflow_hub.dart';
import 'package:deutsch_bilarabi/core/infrastructure/sys_ci_cd_workflow_fixer/unit_test_automation.dart';
import 'package:deutsch_bilarabi/core/infrastructure/sys_ci_cd_workflow_fixer/workflow_build_fixer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkflowBuildFixer', () {
    const fixer = WorkflowBuildFixer();

    test('detects missing Flutter build prerequisites', () {
      const yaml = '''
name: Broken
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: flutter build apk --debug
''';

      final issues = fixer.inspect(yaml);

      expect(
        issues.map((issue) => issue.code),
        containsAll(<WorkflowIssueCode>[
          WorkflowIssueCode.missingCheckout,
          WorkflowIssueCode.missingFlutterSetup,
          WorkflowIssueCode.missingPubGet,
        ]),
      );
    });

    test('repairs missing prerequisites before the build command', () {
      const yaml = '''
name: Broken
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: flutter build apk --debug
''';

      final result = fixer.repair(yaml);

      expect(result.changed, isTrue);
      expect(result.issuesAfter, isEmpty);
      expect(result.repairedYaml, contains('actions/checkout@'));
      expect(result.repairedYaml, contains('subosito/flutter-action@'));
      expect(result.repairedYaml, contains('flutter pub get --enforce-lockfile'));
      expect(
        result.repairedYaml.indexOf('flutter pub get'),
        lessThan(result.repairedYaml.indexOf('flutter build apk')),
      );
    });

    test('pins known floating action versions', () {
      const yaml = '''
name: Floating
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --debug
''';

      final before = fixer.inspect(yaml);
      final repaired = fixer.repair(yaml);

      expect(
        before.where(
          (issue) => issue.code == WorkflowIssueCode.unpinnedKnownAction,
        ),
        hasLength(2),
      );
      expect(
        repaired.issuesAfter.where(
          (issue) => issue.code == WorkflowIssueCode.unpinnedKnownAction,
        ),
        isEmpty,
      );
    });

    test('moves pub get ahead of an early build step', () {
      const yaml = '''
name: Order
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
      - uses: subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2
      - run: flutter build apk --debug
      - run: flutter pub get
''';

      final repaired = fixer.repair(yaml);

      expect(repaired.issuesAfter, isEmpty);
      expect(
        repaired.repairedYaml.indexOf('flutter pub get'),
        lessThan(repaired.repairedYaml.indexOf('flutter build apk')),
      );
    });
  });

  group('UnitTestAutomation', () {
    const automation = UnitTestAutomation();

    test('creates one deterministic unit-test command per module', () {
      final plan = automation.plan(
        const <UnitTestModule>[
          UnitTestModule(
            id: 'review',
            testPath:
                'test/core/infrastructure/sys_codex_connector_review/',
          ),
          UnitTestModule(
            id: 'data',
            testPath:
                'test/core/infrastructure/sys_data_layer_validation/',
          ),
          UnitTestModule(
            id: 'ci',
            testPath:
                'test/core/infrastructure/sys_ci_cd_workflow_fixer/',
          ),
        ],
      );

      expect(plan.commands, hasLength(3));
      expect(
        plan.commands.map((item) => item.command),
        contains(
          'flutter test test/core/infrastructure/sys_data_layer_validation/',
        ),
      );
      expect(plan.workflowStepsYaml, contains('Unit tests - review'));
      expect(plan.workflowStepsYaml, contains('Unit tests - data'));
      expect(plan.workflowStepsYaml, contains('Unit tests - ci'));
    });

    test('deduplicates identical test paths', () {
      final plan = automation.plan(
        const <UnitTestModule>[
          UnitTestModule(id: 'one', testPath: 'test/core/shared/'),
          UnitTestModule(id: 'two', testPath: 'test/core/shared/'),
        ],
      );

      expect(plan.commands, hasLength(1));
    });

    test('rejects unsafe test paths', () {
      expect(
        () => automation.plan(
          const <UnitTestModule>[
            UnitTestModule(id: 'bad', testPath: '../outside_test.dart'),
          ],
        ),
        throwsArgumentError,
      );
    });
  });

  test('CiCdWorkflowHub returns repaired workflow and module test plan', () {
    const hub = CiCdWorkflowHub();
    const yaml = '''
name: Hub
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: flutter build apk --debug
''';

    final report = hub.prepare(
      workflowYaml: yaml,
      modules: const <UnitTestModule>[
        UnitTestModule(id: 'core', testPath: 'test/core/'),
      ],
    );

    expect(report.workflow.issuesAfter, isEmpty);
    expect(report.tests.commands.single.command, 'flutter test test/core/');
    expect(report.isReady, isTrue);
  });
}
