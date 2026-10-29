enum ArchitectureIssueCode {
  duplicateModule,
  unknownDependency,
  forbiddenDependency,
  dependencyCycle,
}

final class ArchitectureModule {
  const ArchitectureModule({
    required this.name,
    required this.layer,
    required this.dependencies,
  });

  final String name;
  final String layer;
  final List<String> dependencies;
}

final class ArchitecturePolicy {
  const ArchitecturePolicy({required this.allowedDependencies});

  final Map<String, Set<String>> allowedDependencies;

  bool allows(String fromLayer, String toLayer) {
    if (fromLayer == toLayer) {
      return allowedDependencies[fromLayer]?.contains(toLayer) ?? false;
    }
    return allowedDependencies[fromLayer]?.contains(toLayer) ?? false;
  }
}

final class ArchitectureIssue {
  const ArchitectureIssue({
    required this.code,
    required this.module,
    this.dependency,
    this.cycle = const <String>[],
  });

  final ArchitectureIssueCode code;
  final String module;
  final String? dependency;
  final List<String> cycle;
}

final class ArchitectureValidationResult {
  const ArchitectureValidationResult(this.issues);

  final List<ArchitectureIssue> issues;

  bool get isValid => issues.isEmpty;
}

final class ArchitectureValidator {
  const ArchitectureValidator();

  ArchitectureValidationResult validate(
    List<ArchitectureModule> modules,
    ArchitecturePolicy policy,
  ) {
    final issues = <ArchitectureIssue>[];
    final byName = <String, ArchitectureModule>{};

    for (final module in modules) {
      if (byName.containsKey(module.name)) {
        issues.add(
          ArchitectureIssue(
            code: ArchitectureIssueCode.duplicateModule,
            module: module.name,
          ),
        );
        continue;
      }
      byName[module.name] = module;
    }

    for (final module in modules) {
      for (final dependencyName in module.dependencies) {
        final dependency = byName[dependencyName];
        if (dependency == null) {
          issues.add(
            ArchitectureIssue(
              code: ArchitectureIssueCode.unknownDependency,
              module: module.name,
              dependency: dependencyName,
            ),
          );
          continue;
        }

        if (!policy.allows(module.layer, dependency.layer)) {
          issues.add(
            ArchitectureIssue(
              code: ArchitectureIssueCode.forbiddenDependency,
              module: module.name,
              dependency: dependency.name,
            ),
          );
        }
      }
    }

    issues.addAll(_findCycles(byName));
    return ArchitectureValidationResult(
      List<ArchitectureIssue>.unmodifiable(issues),
    );
  }

  List<ArchitectureIssue> _findCycles(
    Map<String, ArchitectureModule> modules,
  ) {
    final issues = <ArchitectureIssue>[];
    final state = <String, int>{};
    final stack = <String>[];
    final reported = <String>{};

    void visit(String name) {
      final currentState = state[name] ?? 0;
      if (currentState == 2) return;
      if (currentState == 1) {
        final start = stack.indexOf(name);
        final cycle = <String>[
          ...stack.sublist(start < 0 ? 0 : start),
          name,
        ];
        final signature = cycle.join('>');
        if (reported.add(signature)) {
          issues.add(
            ArchitectureIssue(
              code: ArchitectureIssueCode.dependencyCycle,
              module: name,
              cycle: List<String>.unmodifiable(cycle),
            ),
          );
        }
        return;
      }

      state[name] = 1;
      stack.add(name);
      final module = modules[name];
      if (module != null) {
        for (final dependency in module.dependencies) {
          if (modules.containsKey(dependency)) {
            visit(dependency);
          }
        }
      }
      stack.removeLast();
      state[name] = 2;
    }

    for (final name in modules.keys) {
      visit(name);
    }
    return issues;
  }
}
