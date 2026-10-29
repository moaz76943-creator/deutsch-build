import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Bytes measured on 2026-10-24 while `pubspec.yaml` still listed `- assets/`.
/// The catch-all packaged every file under `assets/` into the Flutter bundle.
const int blanketBundleBytesBefore = 117861098;
const int blanketBundleFilesBefore = 951;

/// Fonts are not in the FontManifest, and these PNGs are not referenced by
/// `Image.asset` or Android resources. They must stay out of the APK.
const List<String> _excludedTopLevels = <String>[
  'fonts',
  'icon',
  'icons',
  'images',
];

const List<String> _requiredRuntimeAssets = <String>[
  'assets/data/master_vocabulary.json',
  'assets/data/missions_50.json',
  'assets/content/packs/de/canonical/de-1.0.0.json',
  'assets/content/packs/de/sqlite/de-1.0.0.sqlite.test',
  'assets/content/packs/de/bundles/de-1.0.0.pack.gz',
];

void main() {
  test('Flutter asset bundle omits unused fonts and duplicate icons', () {
    final root = Directory.current;
    expect(File('pubspec.yaml').existsSync(), isTrue,
        reason: 'Run from the repository root (flutter test does).');

    final entries = flutterAssetEntries(File('pubspec.yaml').readAsStringSync());
    expect(entries, isNot(contains('assets/')));
    expect(entries, isNot(contains('assets')));
    expect(entries.any((entry) => entry.startsWith('assets/fonts')), isFalse);
    expect(entries.any((entry) => entry.startsWith('assets/icon')), isFalse);
    expect(entries.any((entry) => entry.startsWith('assets/images')), isFalse);

    final allFiles = _filesUnder(root, 'assets');
    final bundled = allFiles.where((path) => _isBundled(path, entries)).toList();
    final omitted = allFiles.where((path) => !_isBundled(path, entries)).toList();

    final bundledBytes = _totalBytes(bundled);
    final omittedBytes = _totalBytes(omitted);
    final blanketBytes = bundledBytes + omittedBytes;

    // ignore: avoid_print
    print(
      'Asset bundle before (blanket assets/): '
      '$blanketBundleBytesBefore bytes, $blanketBundleFilesBefore files. '
      'After: $bundledBytes bytes, ${bundled.length} files. '
      'Omitted: $omittedBytes bytes, ${omitted.length} files '
      '(${(100 * omittedBytes / blanketBytes).toStringAsFixed(1)}%).',
    );

    expect(blanketBytes, blanketBundleBytesBefore,
        reason: 'The on-disk asset tree changed; remeasure before relaxing.');
    expect(allFiles.length, blanketBundleFilesBefore);
    expect(omittedBytes, greaterThanOrEqualTo(70 * 1024 * 1024));
    expect(bundledBytes, lessThanOrEqualTo(42 * 1024 * 1024));
    expect(bundledBytes, lessThan(blanketBundleBytesBefore ~/ 2));

    for (final required in _requiredRuntimeAssets) {
      expect(bundled, contains(required),
          reason: 'Offline runtime still needs $required');
      expect(File(required).existsSync(), isTrue);
    }

    const stillOmitted = <String>[
      'assets/fonts/NotoSansCJK-Regular.ttc',
      'assets/fonts/NotoSansSC-Regular.otf',
      'assets/fonts/NotoSansSC-Regular.ttf',
      'assets/fonts/fallback/NotoSansSC.ttf',
      'assets/fonts/NotoSansKR-Regular.ttf',
      'assets/fonts/NotoSansJP-Regular.ttf',
      'assets/fonts/Cairo-Variable.ttf',
      'assets/images/icon.png',
      'assets/icon/app_icon.png',
      'assets/icons/app_icon.png',
    ];
    for (final path in stillOmitted) {
      expect(omitted, contains(path));
      expect(File(path).existsSync(), isTrue,
          reason: 'Keep the source file; only drop it from the bundle.');
    }

    for (final path in omitted) {
      final top = path.split('/')[1];
      expect(_excludedTopLevels, contains(top),
          reason: '$path was omitted without an explicit exclusion');
    }
  });
}

/// Entries in the `flutter: assets:` list. Directory entries keep their
/// trailing slash, matching Flutter's recursive include rule.
List<String> flutterAssetEntries(String pubspec) {
  final lines = pubspec.split('\n');
  var inFlutter = false;
  var inAssets = false;
  final entries = <String>[];
  for (final raw in lines) {
    if (!inFlutter) {
      if (raw == 'flutter:') inFlutter = true;
      continue;
    }
    if (raw.isNotEmpty && !raw.startsWith(' ') && !raw.startsWith('#')) {
      break;
    }
    if (!inAssets) {
      if (raw.trim() == 'assets:') inAssets = true;
      continue;
    }
    if (raw.startsWith('    - ')) {
      entries.add(raw.trim().substring(2).trim());
      continue;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    break;
  }
  return entries;
}

bool _isBundled(String relativePath, List<String> entries) {
  for (final entry in entries) {
    if (entry.endsWith('/')) {
      if (relativePath.startsWith(entry)) return true;
    } else if (relativePath == entry) {
      return true;
    }
  }
  return false;
}

List<String> _filesUnder(Directory root, String relativeDir) {
  final base = Directory('${root.path}/$relativeDir');
  final files = base
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => file.path.substring(root.path.length + 1))
      .toList();
  files.sort();
  return files;
}

int _totalBytes(List<String> relativePaths) {
  var total = 0;
  for (final path in relativePaths) {
    total += File(path).lengthSync();
  }
  return total;
}
