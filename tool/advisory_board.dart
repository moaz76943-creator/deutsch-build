import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _defaultInterval = 360;
const _minInterval = 15;
const _maxInterval = 10080;

Future<void> main(List<String> args) async {
  final options = Options.parse(args);
  final board = InnovationAdvisoryBoard(
    File.fromUri(Platform.script).absolute.parent.parent,
  );
  do {
    stdout.writeln(await board.report(options.marketSnapshot));
    if (!options.watch) return;
    stdout.writeln('\n[ADVISORY_BOARD] read-only cycle complete.');
    await Future<void>.delayed(
      Duration(minutes: options.intervalMinutes),
    );
  } while (true);
}

final class Options {
  const Options(
    this.watch,
    this.intervalMinutes,
    this.marketSnapshot,
  );

  final bool watch;
  final int intervalMinutes;
  final String? marketSnapshot;

  static Options parse(List<String> args) {
    var watch = false;
    var interval = _defaultInterval;
    String? market;

    for (final arg in args) {
      if (arg == '--watch') {
        watch = true;
      } else if (arg == '--once') {
        watch = false;
      } else if (arg.startsWith('--interval-minutes=')) {
        final value = int.tryParse(arg.split('=').last.trim());
        if (value == null ||
            value < _minInterval ||
            value > _maxInterval) {
          throw const FormatException(
            'interval must be 15..10080 minutes',
          );
        }
        interval = value;
      } else if (arg.startsWith('--market-snapshot=')) {
        market = arg
            .substring('--market-snapshot='.length)
            .trim();
        if (market.isEmpty) {
          throw const FormatException(
            'market snapshot path is empty',
          );
        }
      } else {
        throw FormatException(
          'unknown advisory-board argument: $arg',
        );
      }
    }

    return Options(watch, interval, market);
  }
}

final class Snapshot {
  const Snapshot(
    this.pubspec,
    this.manifest,
    this.hasWorker,
    this.marketFresh,
  );

  final String pubspec;
  final String manifest;
  final bool hasWorker;
  final bool marketFresh;

  int get dependencyCount {
    var inside = false;
    var count = 0;

    for (final line in const LineSplitter().convert(pubspec)) {
      if (line == 'dependencies:') {
        inside = true;
        continue;
      }
      if (line == 'dev_dependencies:') break;
      if (inside &&
          line.startsWith('  ') &&
          !line.startsWith('    ') &&
          line.trim().isNotEmpty) {
        count += 1;
      }
    }

    return count;
  }

  int get permissionCount =>
      RegExp(r'<uses-permission ').allMatches(manifest).length;
}

final class Proposal {
  const Proposal(
    this.id,
    this.agent,
    this.title,
    this.goal,
    this.pros,
    this.risks,
    this.complexity,
    this.fit, {
    this.permissionRisk = false,
    this.binaryRisk = false,
  });

  final int id;
  final String agent;
  final String title;
  final String goal;
  final List<String> pros;
  final List<String> risks;
  final String complexity;
  final String fit;
  final bool permissionRisk;
  final bool binaryRisk;
}

abstract interface class Advisor {
  Proposal propose(Snapshot snapshot, int id);
}

final class PerformanceAdvisor implements Advisor {
  @override
  Proposal propose(Snapshot s, int id) => Proposal(
        id,
        'Performance Advisor',
        'Read-Only Performance Budget Gate',
        'Define measurable startup/hot-path budgets before '
            'optimization; persistent worker present=${s.hasWorker}.',
        const [
          'Uses the existing worker boundary.',
          'Keeps profiling/advice local.',
          'Prevents ad-hoc optimization drift.',
        ],
        const [
          'Wrong thresholds can create false confidence.',
          'Device profiling is still required before release.',
        ],
        'Low-Medium',
        'High: bounded work, worker isolation, offline-first, '
            'zero billing.',
      );
}

final class UxMarketAdvisor implements Advisor {
  @override
  Proposal propose(Snapshot s, int id) => Proposal(
        id,
        'UX & Market Advisor',
        'Offline Daily Mission Layer',
        'Compose existing pair-scoped SRS, vocabulary and grammar '
            'into a short resumable local mission. '
            'Market snapshot fresh=${s.marketFresh}.',
        const [
          'Improves re-entry without cloud dependency.',
          'Reuses canonical progress/SRS.',
          'Differentiates through offline continuity.',
        ],
        const [
          'Avoid manipulative streak pressure.',
          'Must not create a second progress authority.',
          'Competitor claims require fresh external evidence.',
        ],
        'Medium',
        'High only as a presentation/orchestration layer over '
            'canonical pair-scoped state.',
      );
}

final class TechRadarAdvisor implements Advisor {
  @override
  Proposal propose(Snapshot s, int id) => Proposal(
        id,
        'Tech Radar Advisor',
        'Staged Dependency Compatibility Radar',
        'Inventory ${s.dependencyCount} direct dependencies and '
            'rank future upgrades; never auto-upgrade.',
        const [
          'Separates awareness from mutation.',
          'Supports one-package-at-a-time rollback.',
          'Fits Phase 20 hardening.',
        ],
        const [
          'Version numbers alone do not prove safety.',
          'Fresh security/upstream status needs external research.',
        ],
        'Low inventory / Medium per approved upgrade',
        'High: advisory-only and compatible with zero-regression '
            'gates.',
        permissionRisk: true,
        binaryRisk: true,
      );
}

final class RiskArchitectureAuditor {
  List<String> audit(Proposal proposal, Snapshot snapshot) {
    final risks = <String>[...proposal.risks];

    if (proposal.permissionRisk) {
      risks.add(
        'Permission impact must be checked against the live '
        'manifest (${snapshot.permissionCount} declarations).',
      );
    }
    if (proposal.binaryRisk) {
      risks.add(
        'Binary-size impact must be measured before release '
        'admission.',
      );
    }

    risks.add(
      'No proposal becomes IMPLEMENTED, VERIFIED or INTEGRATED '
      'without separate evidence.',
    );
    return risks;
  }
}

final class InnovationAdvisoryBoard {
  InnovationAdvisoryBoard(this.root);

  final Directory root;
  final _auditor = RiskArchitectureAuditor();
  final List<Advisor> _advisors = [
    PerformanceAdvisor(),
    UxMarketAdvisor(),
    TechRadarAdvisor(),
  ];

  Future<String> report(String? marketSnapshot) async {
    final snapshot = await _snapshot(marketSnapshot);
    final proposals = [
      for (var i = 0; i < _advisors.length; i += 1)
        _advisors[i].propose(snapshot, i + 1),
    ];

    final buffer = StringBuffer()
      ..writeln(
        'التقرير الاستشاري — Innovation Advisory Board',
      )
      ..writeln(
        'READ-ONLY / OFFLINE-FIRST / ZERO ADDITIONAL BILLING',
      )
      ..writeln(
        'Output: stdout only; no GitHub Issues and no code mutation.',
      );

    for (final proposal in proposals) {
      buffer
        ..writeln(
          '\nPROPOSAL ${proposal.id} — ${proposal.agent}',
        )
        ..writeln(
          '- عنوان الفكرة والهدف منها: '
          '${proposal.title} — ${proposal.goal}',
        )
        ..writeln(
          '- الإيجابيات (Pros): '
          '${proposal.pros.join(' | ')}',
        )
        ..writeln(
          '- السلبيات والثغرات بحسب تقييم '
          'وكيل تدقيق المخاطر (Cons & Risks): '
          '${_auditor.audit(proposal, snapshot).join(' | ')}',
        )
        ..writeln(
          '- التعقيد الهندسي ومدى التوافق مع دستور v8.0: '
          '${proposal.complexity}; ${proposal.fit}',
        )
        ..writeln(
          '[APPROVE: PROPOSAL ${proposal.id}]',
        )
        ..writeln(
          '[DEFER: PROPOSAL ${proposal.id}]',
        )
        ..writeln(
          '[REJECT: PROPOSAL ${proposal.id}]',
        );
    }

    return buffer.toString().trimRight();
  }

  Future<Snapshot> _snapshot(String? marketSnapshot) async {
    final pubspec = await _read('pubspec.yaml');
    final manifest = await _read(
      'android/app/src/main/AndroidManifest.xml',
    );
    final worker = File(
      '${root.path}/lib/core/worker/'
      'persistent_cpu_worker.dart',
    );

    var marketFresh = false;
    if (marketSnapshot != null) {
      final market = File(marketSnapshot);
      if (!await market.exists()) {
        throw StateError(
          'market snapshot not found: $marketSnapshot',
        );
      }
      await market.readAsString();
      marketFresh = true;
    }

    return Snapshot(
      pubspec,
      manifest,
      await worker.exists(),
      marketFresh,
    );
  }

  Future<String> _read(String relative) async {
    final file = File('${root.path}/$relative');
    if (!await file.exists()) {
      throw StateError(
        'missing read-only input: $relative',
      );
    }
    return file.readAsString();
  }
}
