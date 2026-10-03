enum WorkflowIssueCode {
  missingJobs,
  missingSteps,
  missingCheckout,
  missingFlutterSetup,
  missingPubGet,
  buildBeforeDependencyInstall,
  unpinnedKnownAction,
}

final class WorkflowIssue {
  const WorkflowIssue({
    required this.code,
    required this.message,
    this.line,
  });

  final WorkflowIssueCode code;
  final String message;
  final int? line;
}

final class WorkflowRepairResult {
  const WorkflowRepairResult({
    required this.originalYaml,
    required this.repairedYaml,
    required this.issuesBefore,
    required this.issuesAfter,
    required this.changes,
  });

  final String originalYaml;
  final String repairedYaml;
  final List<WorkflowIssue> issuesBefore;
  final List<WorkflowIssue> issuesAfter;
  final List<String> changes;

  bool get changed => originalYaml != repairedYaml;
}

final class WorkflowBuildFixer {
  const WorkflowBuildFixer();

  static const String checkoutAction =
      'actions/checkout@11d5960a326750d5838078e36cf38b85af677262';
  static const String flutterAction =
      'subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2';

  List<WorkflowIssue> inspect(String yaml) {
    final lines = yaml.split('\n');
    final issues = <WorkflowIssue>[];

    final jobsIndex = _indexOfTrimmed(lines, 'jobs:');
    if (jobsIndex < 0) {
      issues.add(
        const WorkflowIssue(
          code: WorkflowIssueCode.missingJobs,
          message: 'Workflow is missing a jobs section.',
        ),
      );
      return List<WorkflowIssue>.unmodifiable(issues);
    }

    final stepsIndex = _indexOfTrimmed(lines, 'steps:');
    if (stepsIndex < 0) {
      issues.add(
        const WorkflowIssue(
          code: WorkflowIssueCode.missingSteps,
          message: 'Workflow is missing a steps section.',
        ),
      );
      return List<WorkflowIssue>.unmodifiable(issues);
    }

    final checkoutIndex = _indexContaining(lines, 'uses: actions/checkout@');
    final flutterIndex =
        _indexContaining(lines, 'uses: subosito/flutter-action@');
    final pubGetIndex = _indexContaining(lines, 'flutter pub get');
    final buildIndex = _indexContaining(lines, 'flutter build ');

    if (checkoutIndex < 0) {
      issues.add(
        const WorkflowIssue(
          code: WorkflowIssueCode.missingCheckout,
          message: 'Flutter jobs must checkout the source before build steps.',
        ),
      );
    }
    if (flutterIndex < 0) {
      issues.add(
        const WorkflowIssue(
          code: WorkflowIssueCode.missingFlutterSetup,
          message: 'Flutter jobs must set up Flutter before running commands.',
        ),
      );
    }
    if (buildIndex >= 0 && pubGetIndex < 0) {
      issues.add(
        const WorkflowIssue(
          code: WorkflowIssueCode.missingPubGet,
          message: 'Flutter build requires dependency installation first.',
        ),
      );
    }
    if (buildIndex >= 0 && pubGetIndex >= 0 && buildIndex < pubGetIndex) {
      issues.add(
        WorkflowIssue(
          code: WorkflowIssueCode.buildBeforeDependencyInstall,
          message: 'flutter pub get must run before flutter build.',
          line: buildIndex + 1,
        ),
      );
    }

    for (var index = 0; index < lines.length; index++) {
      final trimmed = lines[index].trim();
      if (_isFloatingKnownAction(trimmed, 'actions/checkout@') ||
          _isFloatingKnownAction(trimmed, 'subosito/flutter-action@')) {
        issues.add(
          WorkflowIssue(
            code: WorkflowIssueCode.unpinnedKnownAction,
            message: 'Known actions must be pinned to an exact commit SHA.',
            line: index + 1,
          ),
        );
      }
    }

    return List<WorkflowIssue>.unmodifiable(issues);
  }

  WorkflowRepairResult repair(String yaml) {
    final before = inspect(yaml);
    var lines = yaml.split('\n');
    final changes = <String>[];

    lines = lines.map((line) {
      final trimmed = line.trim();
      if (_isFloatingKnownAction(trimmed, 'actions/checkout@')) {
        changes.add('Pinned actions/checkout to the approved SHA.');
        return _replaceActionRef(line, 'actions/checkout@', checkoutAction);
      }
      if (_isFloatingKnownAction(trimmed, 'subosito/flutter-action@')) {
        changes.add('Pinned subosito/flutter-action to the approved SHA.');
        return _replaceActionRef(
          line,
          'subosito/flutter-action@',
          flutterAction,
        );
      }
      return line;
    }).toList();

    final stepsIndex = _indexOfTrimmed(lines, 'steps:');
    if (stepsIndex >= 0) {
      var insertAt = stepsIndex + 1;
      final stepIndent = _leadingWhitespace(lines[stepsIndex]) + '  ';

      if (_indexContaining(lines, 'uses: actions/checkout@') < 0) {
        lines.insert(insertAt, stepIndent + '- uses: ' + checkoutAction);
        insertAt++;
        changes.add('Added source checkout step.');
      }
      if (_indexContaining(lines, 'uses: subosito/flutter-action@') < 0) {
        lines.insert(insertAt, stepIndent + '- uses: ' + flutterAction);
        insertAt++;
        changes.add('Added Flutter setup step.');
      }

      final buildIndex = _indexContaining(lines, 'flutter build ');
      var pubGetIndex = _indexContaining(lines, 'flutter pub get');
      if (buildIndex >= 0 && pubGetIndex < 0) {
        final indent = _leadingWhitespace(lines[buildIndex]);
        lines.insert(
          buildIndex,
          indent + '- run: flutter pub get --enforce-lockfile',
        );
        changes.add('Added dependency installation before build.');
      } else if (buildIndex >= 0 &&
          pubGetIndex >= 0 &&
          buildIndex < pubGetIndex) {
        final pubLine = lines.removeAt(pubGetIndex);
        final newBuildIndex = _indexContaining(lines, 'flutter build ');
        lines.insert(newBuildIndex, pubLine);
        changes.add('Moved dependency installation before build.');
      }
    }

    final repaired = lines.join('\n');
    return WorkflowRepairResult(
      originalYaml: yaml,
      repairedYaml: repaired,
      issuesBefore: before,
      issuesAfter: inspect(repaired),
      changes: List<String>.unmodifiable(changes),
    );
  }

  bool _isFloatingKnownAction(String line, String marker) {
    final markerIndex = line.indexOf(marker);
    if (markerIndex < 0) return false;
    final ref = line.substring(markerIndex + marker.length).split(' ').first;
    return !RegExp(r'^[0-9a-fA-F]{40}$').hasMatch(ref);
  }

  String _replaceActionRef(String line, String marker, String replacement) {
    final markerIndex = line.indexOf(marker);
    if (markerIndex < 0) return line;
    final prefix = line.substring(0, markerIndex);
    final rest = line.substring(markerIndex + marker.length);
    final suffixIndex = rest.indexOf(' ');
    final suffix = suffixIndex < 0 ? '' : rest.substring(suffixIndex);
    return prefix + replacement + suffix;
  }

  int _indexOfTrimmed(List<String> lines, String value) {
    for (var index = 0; index < lines.length; index++) {
      if (lines[index].trim() == value) return index;
    }
    return -1;
  }

  int _indexContaining(List<String> lines, String value) {
    for (var index = 0; index < lines.length; index++) {
      if (lines[index].contains(value)) return index;
    }
    return -1;
  }

  String _leadingWhitespace(String value) {
    final length = value.length - value.trimLeft().length;
    return value.substring(0, length);
  }
}
