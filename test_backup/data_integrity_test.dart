import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Language & Data Integrity Checks', () {
    test('Verify JSON assets are valid and non-empty', () async {
      final assetsDir = Directory('assets');
      if (!assetsDir.existsSync()) return;

      final jsonFiles = assetsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));

      for (final file in jsonFiles) {
        final content = await file.readAsString();
        expect(content.trim().isNotEmpty, true, reason: 'File ${file.path} is empty');

        try {
          final decoded = json.decode(content);
          expect(decoded, isNotNull, reason: 'File ${file.path} decoded to null');
        } catch (e) {
          fail('Corrupted JSON syntax in: ${file.path} -> $e');
        }
      }
    });
  });
}
