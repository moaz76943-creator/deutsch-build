import 'dart:convert';
import 'dart:io';

const String _defaultRepository = 'sali97m-cpu/deutsch-bilarabi';
const String _outputDirectory = 'build/advisory_board';

enum EngineeringComplexity { low, medium, high }

final class AdvisoryEvidence {
  const AdvisoryEvidence({
    this.performance = const <String>[],
    this.uxRetention = const <String>[],
    this.techRadar = const <String>[],
  });

  final List<String> performance;
  final List<String> uxRetention;
  final List<String> techRadar;

  factory AdvisoryEvidence.fromJson(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('Advisory evidence must be a JSON object.');
    }
    return AdvisoryEvidence(
      performance: _stringList(raw['performance'], 'performance'),
      uxRetention: _stringList(raw['uxRetention'], 'uxRetention'),
      techRadar: _stringList(raw['techRadar'], 'techRadar'),
    );
  }
}

final class DependencySnapshot {
  const DependencySnapshot({
    required this.directDependencies,
    required this.lockfilePresent,
  });

  final List<String> directDependencies;
  final bool lockfilePresent;

  static DependencySnapshot readFromRepository() {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      return const DependencySnapshot(
        directDependencies: <String>[],
        lockfilePresent: false,
      );
    }

    final names = <String>[];
    var inDependencies = false;
    for (final line in pubspec.readAsLinesSync()) {
      if (line == 'dependencies:') {
        inDependencies = true;
        continue;
      }
      if (inDependencies && line.isNotEmpty && !line.startsWith(' ')) {
        break;
      }
      if (!inDependencies) continue;

      final match = RegExp(r'^  ([A-Za-z0-9_]+):').firstMatch(line);
      if (match != null) {
        names.add(match.group(1)!);
      }
    }

    return DependencySnapshot(
      directDependencies: List<String>.unmodifiable(names),
      lockfilePresent: File('pubspec.lock').existsSync(),
    );
  }
}

final class AdvisoryContext {
  const AdvisoryContext({
    required this.generatedAtUtc,
    required this.evidence,
    required this.dependencies,
  });

  final DateTime generatedAtUtc;
  final AdvisoryEvidence evidence;
  final DependencySnapshot dependencies;
}

final class AdvisoryProposal {
  const AdvisoryProposal({
    required this.advisor,
    required this.idea,
    required this.positives,
    required this.negatives,
    required this.complexity,
    required this.constitutionMatch,
    required this.evidence,
  });

  final String advisor;
  final String idea;
  final List<String> positives;
  final List<String> negatives;
  final EngineeringComplexity complexity;
  final List<String> constitutionMatch;
  final List<String> evidence;

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('## $advisor')
      ..writeln()
      ..writeln('**الفكرة**')
      ..writeln()
      ..writeln(idea)
      ..writeln()
      ..writeln('**الإيجابيات**')
      ..writeln();
    _writeList(buffer, positives);
    buffer
      ..writeln()
      ..writeln('**السلبيات**')
      ..writeln();
    _writeList(buffer, negatives);
    buffer
      ..writeln()
      ..writeln('**التعقيد الهندسي:** ${complexity.name.toUpperCase()}')
      ..writeln()
      ..writeln('**مطابقة الدستور**')
      ..writeln();
    _writeList(buffer, constitutionMatch);
    buffer
      ..writeln()
      ..writeln('**الأدلة/الملاحظات المتاحة**')
      ..writeln();
    _writeList(
      buffer,
      evidence.isEmpty
          ? const <String>[
              'لا يوجد دليل بحثي خارجي مرفق؛ الاقتراح استشاري فقط ولا يثبت حاجة تنفيذية.',
            ]
          : evidence,
    );
    buffer
      ..writeln()
      ..writeln('**Change Admission Gate:** `WAITING_FOR_HUMAN_DECISION`')
      ..writeln();
    return buffer.toString();
  }
}

abstract interface class AdvisoryAgent {
  String get name;

  AdvisoryProposal advise(AdvisoryContext context);
}

final class PerformanceAdvisor implements AdvisoryAgent {
  const PerformanceAdvisor();

  @override
  String get name => 'Performance Advisor';

  @override
  AdvisoryProposal advise(AdvisoryContext context) {
    return AdvisoryProposal(
      advisor: name,
      idea:
          'اعتماد حزمة أدلة أداء أسبوعية قبل قبول أي تحسين: قياس زمن البداية، '
          'حجم working set، عمق طابور Persistent CPU Worker، وحجم مرشحي البحث، '
          'مع الحفاظ على LanguageCatalog بنمو O(N) وزوج موجه نشط عند الطلب فقط.',
      positives: const <String>[
        'يمنع تحسينات تخمينية غير مرتبطة بقياس فعلي.',
        'يحافظ على مبدأ O(N) بدل إنشاء حالات أزواج O(N²) مقيمة في الذاكرة.',
        'يدعم عزل الأعمال الثقيلة عن UI isolate بدل نقل العبء إلى الإطار المرئي.',
        'يمكن تنفيذه محليًا ومن دون خدمة سحابية أو تكلفة إضافية.',
      ],
      negatives: const <String>[
        'إضافة القياسات نفسها تحتاج تصميمًا دقيقًا كي لا تصبح instrumentation مكلفة.',
        'الأرقام الأسبوعية لا تكفي وحدها لإثبات تحسن على جميع فئات الأجهزة.',
        'أي توصية تحسين لاحقة ستحتاج Change Admission منفصلًا وتحققًا محدد النطاق.',
      ],
      complexity: EngineeringComplexity.medium,
      constitutionMatch: const <String>[
        'متوافق مع Shared Core + Language Intelligence + Directed Pair Intelligence.',
        'يحافظ على O(N) resident language metadata وعدم materialization لكل الأزواج.',
        'يفضل Persistent CPU Worker للأعمال الثقيلة ولا يخلق main-isolate fallback.',
        'يحترم Offline-First وZero Additional Billing.',
        'Proposal فقط؛ لا تعديل تلقائي للكود.',
      ],
      evidence: context.evidence.performance,
    );
  }
}

final class UxRetentionAdvisor implements AdvisoryAgent {
  const UxRetentionAdvisor();

  @override
  String get name => 'UX & Retention Advisor';

  @override
  AdvisoryProposal advise(AdvisoryContext context) {
    return AdvisoryProposal(
      advisor: name,
      idea:
          'اقتراح طبقة Local Learning Recovery خفيفة تستخدم التقدم الزوجي وSRS المحلي '
          'لاقتراح جلسة قصيرة أو مراجعة أخطاء عند العودة، مع restrained celebration '
          'ودون إشعارات سحابية أو gamification قهري.',
      positives: const <String>[
        'يحسن الاستمرارية من خلال سياق تعلم محلي موجود أصلًا بدل تتبع سلوكي خارجي.',
        'يظل صالحًا دون إنترنت ولا يحتاج مزود AI أو backend.',
        'يمكن ربطه بأهداف mastery والاسترجاع بدل زيادة وقت الشاشة لذاته.',
        'يحافظ على خصوصية المتعلم لأن القرار يمكن أن يبقى محليًا.',
      ],
      negatives: const <String>[
        'قد تصبح التذكيرات مزعجة إذا لم تكن قابلة للتحكم أو محدودة التكرار.',
        'الاحتفاظ ليس دليل تعلم؛ يجب فصل retention metrics عن mastery evidence.',
        'يحتاج لاحقًا قواعد وصول واضحة وreduced-motion/accessibility للعرض التفاعلي.',
      ],
      complexity: EngineeringComplexity.medium,
      constitutionMatch: const <String>[
        'Offline-First: لا اعتماد على شبكة أو خدمة خارجية في قلب التجربة.',
        'Pair-scoped: لا خلط بين A→B وB→A في التقدم أو التوصيات.',
        'Learning-first: engagement يخدم mastery ولا يتحول إلى هدف مستقل.',
        'Minimum Necessary Privilege: لا صلاحيات جديدة لازمة لهذا المقترح.',
        'Proposal فقط حتى موافقة بشرية صريحة.',
      ],
      evidence: context.evidence.uxRetention,
    );
  }
}

final class TechRadarAdvisor implements AdvisoryAgent {
  const TechRadarAdvisor();

  @override
  String get name => 'Tech Radar Advisor';

  @override
  AdvisoryProposal advise(AdvisoryContext context) {
    final dependencies = context.dependencies.directDependencies;
    final dependencySummary = dependencies.isEmpty
        ? 'تعذر استخراج قائمة dependencies من pubspec.yaml.'
        : 'تم رصد ${dependencies.length} dependency مباشرة محليًا: '
            '${dependencies.take(8).join(', ')}'
            '${dependencies.length > 8 ? ', …' : ''}.';
    final lockSummary = context.dependencies.lockfilePresent
        ? 'pubspec.lock موجود؛ أي ترقية مستقبلية يجب أن تبقى evidence-bound.'
        : 'pubspec.lock غير موجود في لقطة التشغيل؛ لا يجوز ادعاء reproducible dependency state.';

    return AdvisoryProposal(
      advisor: name,
      idea:
          'إنشاء مسار Tech Radar استشاري evidence-only: يسجل dependency snapshot محليًا '
          'ويستقبل نتائج بحث خارجية اختيارية عن الإصدارات/CVEs، لكنه لا يحدث أي package '
          'ولا يعدل pubspec/lockfile. كل ترقية تتحول إلى Proposal منفصل فقط.',
      positives: const <String>[
        'يفصل مراقبة التقنية عن التنفيذ الفعلي للترقيات.',
        'يمنع silent upgrades أو تعديل lockfile دون قرار بشري.',
        'يسمح بربط كل اقتراح أمني بدليل محدد بدل الاعتماد على ذاكرة النموذج.',
        'يحافظ على reproducibility لأن التغيير لا يحدث داخل أداة الرصد.',
      ],
      negatives: const <String>[
        'الوضع الافتراضي غير شبكي؛ لذلك لا يستطيع إثبات أحدث إصدار أو CVE بمفرده.',
        'الأدلة الخارجية تحتاج مصدرًا موثوقًا وتاريخًا ونطاقًا قبل اعتمادها.',
        'بعض ترقيات الأمان قد تتطلب لاحقًا تغييرات متسلسلة واختبارات توافق منفصلة.',
      ],
      complexity: EngineeringComplexity.low,
      constitutionMatch: const <String>[
        'Research/Advisory منفصل عن التنفيذ ولا يغير dependencies.',
        'Zero Additional Billing افتراضيًا؛ لا API مدفوعة أو خدمة سحابية.',
        'لا ادعاء أمني بلا evidence مباشر وحديث.',
        'يحافظ على source-of-truth لأن GitHub main يبقى حقيقة التنفيذ.',
        'Change Admission Gate يفصل proposal عن mutation.',
      ],
      evidence: <String>[
        dependencySummary,
        lockSummary,
        ...context.evidence.techRadar,
      ],
    );
  }
}

final class InnovationBoard {
  const InnovationBoard({
    this.agents = const <AdvisoryAgent>[
      PerformanceAdvisor(),
      UxRetentionAdvisor(),
      TechRadarAdvisor(),
    ],
  });

  final List<AdvisoryAgent> agents;

  List<AdvisoryProposal> generate(AdvisoryContext context) {
    return List<AdvisoryProposal>.unmodifiable(
      agents.map((agent) => agent.advise(context)),
    );
  }
}

final class CliConfig {
  const CliConfig({
    required this.openIssue,
    required this.stdoutOnly,
    required this.selfTest,
    required this.repository,
    required this.evidencePath,
  });

  final bool openIssue;
  final bool stdoutOnly;
  final bool selfTest;
  final String repository;
  final String? evidencePath;

  factory CliConfig.parse(List<String> args) {
    var openIssue = false;
    var stdoutOnly = false;
    var selfTest = false;
    var repository = _defaultRepository;
    String? evidencePath;

    for (var index = 0; index < args.length; index += 1) {
      final argument = args[index];
      if (argument == '--issue') {
        openIssue = true;
      } else if (argument == '--stdout') {
        stdoutOnly = true;
      } else if (argument == '--self-test') {
        selfTest = true;
      } else if (argument == '--repo') {
        if (index + 1 >= args.length) {
          throw const FormatException('--repo requires owner/name.');
        }
        repository = args[++index].trim();
      } else if (argument == '--evidence') {
        if (index + 1 >= args.length) {
          throw const FormatException('--evidence requires a JSON file path.');
        }
        evidencePath = args[++index].trim();
      } else if (argument.startsWith('--repo=')) {
        repository = argument.substring('--repo='.length).trim();
      } else if (argument.startsWith('--evidence=')) {
        evidencePath = argument.substring('--evidence='.length).trim();
      } else {
        throw FormatException('Unknown argument: $argument');
      }
    }

    if (!_repositoryPattern.hasMatch(repository)) {
      throw const FormatException('--repo must use owner/name format.');
    }
    if (evidencePath != null && evidencePath.isEmpty) {
      throw const FormatException('--evidence path cannot be empty.');
    }

    return CliConfig(
      openIssue: openIssue,
      stdoutOnly: stdoutOnly,
      selfTest: selfTest,
      repository: repository,
      evidencePath: evidencePath,
    );
  }
}

Future<void> main(List<String> args) async {
  final config = CliConfig.parse(args);
  if (config.selfTest) {
    _runSelfTest();
    return;
  }

  final evidence = await _loadEvidence(config.evidencePath);
  final context = AdvisoryContext(
    generatedAtUtc: DateTime.now().toUtc(),
    evidence: evidence,
    dependencies: DependencySnapshot.readFromRepository(),
  );
  const board = InnovationBoard();
  final proposals = board.generate(context);
  final report = _renderReport(context, proposals);

  String? outputPath;
  if (!config.stdoutOnly || config.openIssue) {
    outputPath = _writeReport(report, context.generatedAtUtc);
  }
  if (config.stdoutOnly) {
    stdout.write(report);
  } else {
    stdout.writeln('Innovation Board report: $outputPath');
  }

  if (config.openIssue) {
    final issueUrl = await _openProposalIssue(
      repository: config.repository,
      reportPath: outputPath!,
      generatedAtUtc: context.generatedAtUtc,
    );
    stdout.writeln('Proposal issue: $issueUrl');
  }
}

Future<AdvisoryEvidence> _loadEvidence(String? path) async {
  if (path == null) return const AdvisoryEvidence();
  final file = File(path);
  if (!file.existsSync()) {
    throw FormatException('Evidence file does not exist: $path');
  }
  final decoded = jsonDecode(
    await file.readAsString(encoding: utf8),
  );
  return AdvisoryEvidence.fromJson(decoded);
}

String _renderReport(
  AdvisoryContext context,
  List<AdvisoryProposal> proposals,
) {
  final buffer = StringBuffer()
    ..writeln('# [Proposal] DEUTSCH بالعربي — Innovation Board')
    ..writeln()
    ..writeln('- Generated UTC: `${context.generatedAtUtc.toIso8601String()}`')
    ..writeln('- Mode: `READ_ONLY_ADVISORY`')
    ..writeln('- Cadence intent: `WEEKLY_OR_ON_DEMAND`')
    ..writeln('- Mutation authority: `NONE`')
    ..writeln('- Change Admission Gate: `WAITING_FOR_HUMAN_DECISION`')
    ..writeln()
    ..writeln(
      '> This report may recommend changes, but it cannot modify application code, '
      'dependencies, CI/CD, or runtime configuration.',
    )
    ..writeln();

  for (final proposal in proposals) {
    buffer.write(proposal.toMarkdown());
  }

  buffer
    ..writeln('---')
    ..writeln()
    ..writeln('## Board decision')
    ..writeln()
    ..writeln('`NO_AUTOMATIC_EXECUTION`')
    ..writeln()
    ..writeln(
      'أي اقتراح يحتاج قرارًا بشريًا منفصلًا، نطاقًا مصرحًا، base HEAD جديدًا، '
      'وخطة تحقق خاصة به قبل أي mutation.',
    );
  return buffer.toString();
}

String _writeReport(String report, DateTime generatedAtUtc) {
  final directory = Directory(_outputDirectory);
  directory.createSync(recursive: true);
  final stamp = generatedAtUtc
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final path = '$_outputDirectory/innovation_board_$stamp.md';
  File(path).writeAsStringSync(report, encoding: utf8, flush: true);
  return path;
}

Future<String> _openProposalIssue({
  required String repository,
  required String reportPath,
  required DateTime generatedAtUtc,
}) async {
  final title = '[Proposal] Innovation Board — '
      '${generatedAtUtc.toIso8601String().substring(0, 10)}';
  final result = await Process.run(
    'gh',
    <String>[
      'issue',
      'create',
      '--repo',
      repository,
      '--title',
      title,
      '--body-file',
      reportPath,
    ],
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'GitHub issue creation failed (${result.exitCode}): '
      '${result.stderr.toString().trim()}',
    );
  }
  final output = result.stdout.toString().trim();
  if (!output.startsWith('http')) {
    throw StateError('GitHub CLI returned no issue URL.');
  }
  return output.split(RegExp(r'\s+')).last;
}

void _runSelfTest() {
  final config = CliConfig.parse(
    const <String>[
      '--stdout',
      '--repo=sali97m-cpu/deutsch-bilarabi',
    ],
  );
  _expect(config.stdoutOnly, true, 'stdout flag');
  _expect(config.openIssue, false, 'issue is opt-in');

  final context = AdvisoryContext(
    generatedAtUtc: DateTime.utc(2026, 10, 4),
    evidence: const AdvisoryEvidence(
      performance: <String>['perf evidence'],
      uxRetention: <String>['ux evidence'],
      techRadar: <String>['security evidence'],
    ),
    dependencies: const DependencySnapshot(
      directDependencies: <String>['flutter', 'sqflite'],
      lockfilePresent: true,
    ),
  );
  const board = InnovationBoard();
  final proposals = board.generate(context);
  _expect(proposals.length, 3, 'exactly three logical advisors');
  _expect(
    proposals.map((item) => item.advisor).toSet().length,
    3,
    'advisor identities are distinct',
  );
  for (final proposal in proposals) {
    _expect(proposal.idea.trim().isNotEmpty, true, '${proposal.advisor} idea');
    _expect(proposal.positives.isNotEmpty, true, '${proposal.advisor} positives');
    _expect(proposal.negatives.isNotEmpty, true, '${proposal.advisor} negatives');
    _expect(
      proposal.constitutionMatch.isNotEmpty,
      true,
      '${proposal.advisor} constitution match',
    );
  }

  final report = _renderReport(context, proposals);
  for (final required in const <String>[
    '**الفكرة**',
    '**الإيجابيات**',
    '**السلبيات**',
    '**التعقيد الهندسي:**',
    '**مطابقة الدستور**',
    'WAITING_FOR_HUMAN_DECISION',
    'NO_AUTOMATIC_EXECUTION',
  ]) {
    _expect(report.contains(required), true, 'report contains $required');
  }

  stdout.writeln('advisory_board self-test: PASS');
}

List<String> _stringList(Object? raw, String field) {
  if (raw == null) return const <String>[];
  if (raw is! List) {
    throw FormatException('$field must be a JSON array of strings.');
  }
  final values = <String>[];
  for (final item in raw) {
    if (item is! String || item.trim().isEmpty) {
      throw FormatException('$field must contain non-empty strings only.');
    }
    values.add(item.trim());
  }
  return List<String>.unmodifiable(values);
}

void _writeList(StringBuffer buffer, List<String> values) {
  for (final value in values) {
    buffer.writeln('- $value');
  }
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Advisory Board contract failed: $contract. '
      'Expected <$expected>, got <$actual>.',
    );
  }
}

final RegExp _repositoryPattern = RegExp(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$');
