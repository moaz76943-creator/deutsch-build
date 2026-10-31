import 'dart:io';

Future<void> main(List<String> args) async {
  final script = File.fromUri(Platform.script).absolute;
  final root = script.parent.parent;
  final config = File(
    '${root.path}/tool/headless_package_config.json',
  );
  final generator = File(
    '${root.path}/tool/generate_polyglot_packs.dart',
  );

  if (!await config.exists()) {
    throw StateError(
      'Missing headless package config: ${config.path}',
    );
  }
  if (!await generator.exists()) {
    throw StateError(
      'Missing Phase 11 generator: ${generator.path}',
    );
  }

  final process = await Process.start(
    Platform.resolvedExecutable,
    <String>[
      '--packages=${config.path}',
      generator.path,
      ...args,
    ],
    workingDirectory: root.path,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    stderr.writeln(
      'Phase 11 headless generator failed with exit code $exitCode.',
    );
    exit(exitCode);
  }
}
