final class UnitTestModule {
  const UnitTestModule({
    required this.id,
    required this.testPath,
  });

  final String id;
  final String testPath;
}

final class UnitTestCommand {
  const UnitTestCommand({
    required this.moduleId,
    required this.testPath,
    required this.command,
  });

  final String moduleId;
  final String testPath;
  final String command;
}

final class UnitTestPlan {
  const UnitTestPlan({
    required this.commands,
    required this.workflowStepsYaml,
  });

  final List<UnitTestCommand> commands;
  final String workflowStepsYaml;

  bool get isEmpty => commands.isEmpty;
}

final class UnitTestAutomation {
  const UnitTestAutomation();

  UnitTestPlan plan(List<UnitTestModule> modules) {
    final seenPaths = <String>{};
    final commands = <UnitTestCommand>[];

    for (final module in modules) {
      final id = module.id.trim();
      final path = module.testPath.trim();

      if (id.isEmpty) {
        throw ArgumentError.value(module.id, 'id', 'Module id cannot be empty.');
      }
      if (!_isSafeTestPath(path)) {
        throw ArgumentError.value(
          module.testPath,
          'testPath',
          'Test path must remain inside test/ and contain safe characters.',
        );
      }
      if (!seenPaths.add(path)) continue;

      commands.add(
        UnitTestCommand(
          moduleId: id,
          testPath: path,
          command: 'flutter test ' + path,
        ),
      );
    }

    final workflowLines = <String>[];
    for (final item in commands) {
      workflowLines
        ..add('- name: Unit tests - ' + item.moduleId)
        ..add('  run: ' + item.command);
    }

    return UnitTestPlan(
      commands: List<UnitTestCommand>.unmodifiable(commands),
      workflowStepsYaml: workflowLines.join('\n'),
    );
  }

  bool _isSafeTestPath(String path) {
    if (!path.startsWith('test/')) return false;
    if (path.contains('..') || path.contains('\n') || path.contains('\r')) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9_./-]+$').hasMatch(path);
  }
}
