import 'package:deutsch_bilarabi/core/infrastructure/sys_codex_connector_review/architecture_validator.dart';
import 'package:deutsch_bilarabi/core/infrastructure/sys_codex_connector_review/code_review_hub.dart';
import 'package:deutsch_bilarabi/core/infrastructure/sys_codex_connector_review/performance_profiler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArchitectureValidator', () {
    const validator = ArchitectureValidator();
    const policy = ArchitecturePolicy(
      allowedDependencies: <String, Set<String>>{
        'presentation': <String>{'application', 'domain'},
        'application': <String>{'domain'},
        'domain': <String>{},
      },
    );

    test('accepts dependencies allowed by layer policy', () {
      final result = validator.validate(
        const <ArchitectureModule>[
          ArchitectureModule(
            name: 'screen',
            layer: 'presentation',
            dependencies: <String>['orchestrator'],
          ),
          ArchitectureModule(
            name: 'orchestrator',
            layer: 'application',
            dependencies: <String>['models'],
          ),
          ArchitectureModule(
            name: 'models',
            layer: 'domain',
            dependencies: <String>[],
          ),
        ],
        policy,
      );

      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });

    test('reports forbidden and unknown dependencies', () {
      final result = validator.validate(
        const <ArchitectureModule>[
          ArchitectureModule(
            name: 'domain-model',
            layer: 'domain',
            dependencies: <String>['ui', 'missing'],
          ),
          ArchitectureModule(
            name: 'ui',
            layer: 'presentation',
            dependencies: <String>[],
          ),
        ],
        policy,
      );

      expect(
        result.issues.map((issue) => issue.code),
        containsAll(<ArchitectureIssueCode>[
          ArchitectureIssueCode.forbiddenDependency,
          ArchitectureIssueCode.unknownDependency,
        ]),
      );
    });

    test('detects dependency cycles', () {
      final result = validator.validate(
        const <ArchitectureModule>[
          ArchitectureModule(
            name: 'a',
            layer: 'application',
            dependencies: <String>['b'],
          ),
          ArchitectureModule(
            name: 'b',
            layer: 'application',
            dependencies: <String>['a'],
          ),
        ],
        const ArchitecturePolicy(
          allowedDependencies: <String, Set<String>>{
            'application': <String>{'application'},
          },
        ),
      );

      expect(
        result.issues.any(
          (issue) => issue.code == ArchitectureIssueCode.dependencyCycle,
        ),
        isTrue,
      );
    });
  });

  group('PerformanceProfiler', () {
    const profiler = PerformanceProfiler();

    test('computes deterministic aggregate metrics and p95', () {
      final profiles = profiler.profile(
        const <PerformanceSample>[
          PerformanceSample(operation: 'parse', elapsedMicros: 100),
          PerformanceSample(operation: 'parse', elapsedMicros: 200),
          PerformanceSample(operation: 'parse', elapsedMicros: 300),
          PerformanceSample(operation: 'parse', elapsedMicros: 400),
          PerformanceSample(operation: 'parse', elapsedMicros: 500),
        ],
      );

      final parse = profiles.single;
      expect(parse.count, 5);
      expect(parse.totalMicros, 1500);
      expect(parse.averageMicros, 300);
      expect(parse.maxMicros, 500);
      expect(parse.p95Micros, 500);
    });

    test('flags operations that exceed their p95 budget', () {
      final profiles = profiler.profile(
        const <PerformanceSample>[
          PerformanceSample(operation: 'review', elapsedMicros: 800),
          PerformanceSample(operation: 'review', elapsedMicros: 1200),
        ],
        budgetsMicros: const <String, int>{'review': 1000},
      );

      expect(profiles.single.budgetExceeded, isTrue);
      expect(profiles.single.budgetMicros, 1000);
    });

    test('rejects negative timings', () {
      expect(
        () => profiler.profile(
          const <PerformanceSample>[
            PerformanceSample(operation: 'bad', elapsedMicros: -1),
          ],
        ),
        throwsArgumentError,
      );
    });
  });

  test('CodeReviewHub rejects architecture or performance violations', () {
    const hub = CodeReviewHub();

    final report = hub.review(
      modules: const <ArchitectureModule>[
        ArchitectureModule(
          name: 'domain',
          layer: 'domain',
          dependencies: <String>['presentation'],
        ),
        ArchitectureModule(
          name: 'presentation',
          layer: 'presentation',
          dependencies: <String>[],
        ),
      ],
      policy: const ArchitecturePolicy(
        allowedDependencies: <String, Set<String>>{
          'domain': <String>{},
          'presentation': <String>{'domain'},
        },
      ),
      samples: const <PerformanceSample>[
        PerformanceSample(operation: 'scan', elapsedMicros: 2000),
      ],
      budgetsMicros: const <String, int>{'scan': 1000},
    );

    expect(report.isApproved, isFalse);
    expect(report.architecture.isValid, isFalse);
    expect(report.performance.single.budgetExceeded, isTrue);
  });
}
