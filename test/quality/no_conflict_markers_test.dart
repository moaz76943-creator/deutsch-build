import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Fails when a git conflict marker is committed into core Dart sources.
/// A line that merely mentions the marker inside a comment still fails:
/// those tokens are not valid Dart and must not ship.
void main() {
  test('lib and test Dart files contain no git conflict markers', () {
    final hits = <String>[];
    for (final rootName in const ['lib', 'test']) {
      final root = Directory(rootName);
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true, followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final isMarker = line.startsWith('<<<<<<<') ||
              line.startsWith('>>>>>>>') ||
              line == '=======';
          if (isMarker) {
            hits.add('${entity.path}:${i + 1}');
          }
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
