import 'package:deutsch_bilarabi/features/bewerbung_builder/application/bewerbung_notifier.dart';
import 'package:deutsch_bilarabi/features/bewerbung_builder/data/local_bewerbung_repository.dart';
import 'package:deutsch_bilarabi/features/bewerbung_builder/domain/bewerbung_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalBewerbungRepository repository;

  setUp(() {
    repository = LocalBewerbungRepository();
  });

  test('template bank covers resume and cover letter across professional tracks',
      () async {
    final templates = await repository.getTemplates();

    expect(
      templates.map((item) => item.documentType).toSet(),
      containsAll(<BewerbungDocumentType>{
        BewerbungDocumentType.lebenslauf,
        BewerbungDocumentType.anschreiben,
      }),
    );
    expect(
      templates.map((item) => item.careerTrack).toSet(),
      containsAll(<CareerTrack>{
        CareerTrack.medicine,
        CareerTrack.pharmacy,
        CareerTrack.it,
        CareerTrack.trades,
      }),
    );
  });

  test('Lebenslauf preview uses supplied facts and never invents credentials',
      () async {
    final template = (await repository.getTemplates(
      documentType: BewerbungDocumentType.lebenslauf,
      careerTrack: CareerTrack.pharmacy,
    )).first;

    const profile = BewerbungProfile(
      fullName: 'Mona Saleh',
      city: 'Amman',
      email: 'mona@example.com',
      phone: '+962700000000',
      targetRole: 'Apothekerin',
      employer: 'Muster Apotheke',
      professionalSummary:
          'Apothekerin mit Erfahrung in Beratung und Arzneimittelsicherheit.',
      education: <String>['B.Sc. Pharmazie'],
      experience: <String>['Beratung von Kundinnen und Kunden'],
      skills: <String>[
        'Arzneimittelberatung',
        'Dokumentation',
      ],
      languages: <String>['Arabisch', 'Deutsch B1'],
    );

    final preview = await repository.buildPreview(template.id, profile);
    final text = preview.blocks.map((block) => block.bodyDe).join('\n');

    expect(preview.documentType, BewerbungDocumentType.lebenslauf);
    expect(text, contains('Mona Saleh'));
    expect(text, contains('B.Sc. Pharmazie'));
    expect(text, contains('Arzneimittelberatung'));
    expect(text, isNot(contains('Promotion')));
    expect(text, isNot(contains('10 Jahre')));
  });

  test('Anschreiben preview keeps formal respectful German phrasing', () async {
    final template = (await repository.getTemplates(
      documentType: BewerbungDocumentType.anschreiben,
      careerTrack: CareerTrack.it,
    )).first;

    const profile = BewerbungProfile(
      fullName: 'Omar Haddad',
      city: 'Amman',
      email: 'omar@example.com',
      phone: '+962711111111',
      targetRole: 'Junior Softwareentwickler',
      employer: 'Beispiel GmbH',
      professionalSummary:
          'Sorgfältiger Entwickler mit Fokus auf wartbare Software.',
      education: <String>['B.Sc. Informatik'],
      experience: <String>['Flutter-Projekte im Team umgesetzt'],
      skills: <String>['Flutter', 'Git', 'Testing'],
      languages: <String>['Arabisch', 'Deutsch B2', 'Englisch'],
    );

    final preview = await repository.buildPreview(template.id, profile);
    final text = preview.blocks.map((block) => block.bodyDe).join('\n');

    expect(text, contains('Sehr geehrte Damen und Herren,'));
    expect(text, contains('Junior Softwareentwickler'));
    expect(text, contains('Beispiel GmbH'));
    expect(text, contains('Mit freundlichen Grüßen'));
    expect(text, isNot(contains('garantiere')));
  });

  test('profile validation flags missing factual fields without fabricating them',
      () async {
    const incomplete = BewerbungProfile(
      fullName: '',
      city: '',
      email: '',
      phone: '',
      targetRole: '',
      employer: '',
      professionalSummary: '',
      education: <String>[],
      experience: <String>[],
      skills: <String>[],
      languages: <String>[],
    );

    final issues = await repository.validateProfile(incomplete);

    expect(issues.length, greaterThanOrEqualTo(4));
    expect(issues.join(' '), contains('الاسم'));
    expect(issues.join(' '), contains('الوظيفة'));
    expect(issues.join(' '), contains('البريد'));
  });

  test('notifier filters templates and builds a preview deterministically',
      () async {
    final notifier = BewerbungNotifier(repository: repository);

    await notifier.selectDocumentType(BewerbungDocumentType.anschreiben);
    await notifier.selectCareerTrack(CareerTrack.medicine);

    expect(notifier.templates, isNotEmpty);
    expect(
      notifier.templates.every(
        (template) =>
            template.documentType == BewerbungDocumentType.anschreiben &&
            template.careerTrack == CareerTrack.medicine,
      ),
      isTrue,
    );

    notifier.updateProfile(
      const BewerbungProfile(
        fullName: 'Lina Ahmad',
        city: 'Amman',
        email: 'lina@example.com',
        phone: '+962722222222',
        targetRole: 'Assistenzärztin',
        employer: 'Klinikum Beispiel',
        professionalSummary:
            'Ärztin mit sorgfältiger Arbeitsweise und Teamorientierung.',
        education: <String>['Studium der Humanmedizin'],
        experience: <String>['Klinische Hospitation'],
        skills: <String>[
          'Patientenkommunikation',
          'Dokumentation',
        ],
        languages: <String>['Arabisch', 'Deutsch B2'],
      ),
    );

    await notifier.buildPreview();

    expect(notifier.preview, isNotNull);
    expect(notifier.validationIssues, isEmpty);
    expect(notifier.isBusy, isFalse);
  });
}
