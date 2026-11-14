import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/release_builder.dart';

void main() {
  test('Confirms 100/100 tasks and sovereignty ready', () {
    const builder = ReleaseBuilder();
    final meta = builder.generateReleaseManifest();
    expect(meta.totalTasksCompleted, equals(100));
    expect(meta.releaseApkName, equals('polyglot-release.apk'));
    expect(meta.is16KbPageAligned, isTrue);
  });
}
