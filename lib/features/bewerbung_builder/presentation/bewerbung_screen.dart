import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/bewerbung_notifier.dart';
import '../domain/bewerbung_models.dart';

class BewerbungBuilderScreen extends StatefulWidget {
  const BewerbungBuilderScreen({
    required this.notifier,
    super.key,
  });

  final BewerbungNotifier notifier;

  @override
  State<BewerbungBuilderScreen> createState() =>
      _BewerbungBuilderScreenState();
}

class _BewerbungBuilderScreenState
    extends State<BewerbungBuilderScreen> {
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _role;
  late final TextEditingController _employer;
  late final TextEditingController _summary;
  late final TextEditingController _education;
  late final TextEditingController _experience;
  late final TextEditingController _skills;
  late final TextEditingController _languages;

  @override
  void initState() {
    super.initState();
    final profile = widget.notifier.profile;
    _name = TextEditingController(text: profile.fullName);
    _city = TextEditingController(text: profile.city);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone);
    _role = TextEditingController(text: profile.targetRole);
    _employer = TextEditingController(text: profile.employer);
    _summary =
        TextEditingController(text: profile.professionalSummary);
    _education = TextEditingController(
      text: profile.education.join('\n'),
    );
    _experience = TextEditingController(
      text: profile.experience.join('\n'),
    );
    _skills = TextEditingController(
      text: profile.skills.join(', '),
    );
    _languages = TextEditingController(
      text: profile.languages.join(', '),
    );
    Future<void>.microtask(widget.notifier.initialize);
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _email.dispose();
    _phone.dispose();
    _role.dispose();
    _employer.dispose();
    _summary.dispose();
    _education.dispose();
    _experience.dispose();
    _skills.dispose();
    _languages.dispose();
    super.dispose();
  }

  void _syncProfile() {
    widget.notifier.updateProfile(
      BewerbungProfile(
        fullName: _name.text.trim(),
        city: _city.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        targetRole: _role.text.trim(),
        employer: _employer.text.trim(),
        professionalSummary: _summary.text.trim(),
        education: _lines(_education.text),
        experience: _lines(_experience.text),
        skills: _csv(_skills.text),
        languages: _csv(_languages.text),
      ),
    );
  }

  List<String> _lines(String value) => value
      .split('\n')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  List<String> _csv(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  Future<void> _buildPreview() async {
    _syncProfile();
    await widget.notifier.buildPreview();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Bewerbung Builder',
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _EthicsCard(),
                  const SizedBox(height: 14),
                  _DocumentTypeCard(
                    selected: notifier.documentType,
                    busy: notifier.isBusy,
                    onSelected: notifier.selectDocumentType,
                  ),
                  const SizedBox(height: 14),
                  _CareerTrackCard(
                    selected: notifier.careerTrack,
                    busy: notifier.isBusy,
                    onSelected: notifier.selectCareerTrack,
                  ),
                  const SizedBox(height: 14),
                  _TemplateCard(
                    templates: notifier.templates,
                    selected: notifier.selectedTemplate,
                    busy: notifier.isBusy,
                    onSelected: notifier.chooseTemplate,
                  ),
                  const SizedBox(height: 14),
                  _ProfileForm(
                    name: _name,
                    city: _city,
                    email: _email,
                    phone: _phone,
                    role: _role,
                    employer: _employer,
                    summary: _summary,
                    education: _education,
                    experience: _experience,
                    skills: _skills,
                    languages: _languages,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed:
                        notifier.isBusy ? null : _buildPreview,
                    icon: const Icon(Icons.preview_outlined),
                    label: Text(
                      'إنشاء المعاينة',
                      textDirection: TextDirection.rtl,
                      style: AppTypography.label,
                    ),
                  ),
                  if (notifier.validationIssues.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    _ValidationCard(
                      issues: notifier.validationIssues,
                    ),
                  ],
                  if (notifier.preview != null) ...<Widget>[
                    const SizedBox(height: 14),
                    _PreviewCard(preview: notifier.preview!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EthicsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(72),
      glowColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تقديم مهني وأخلاقي',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title.copyWith(
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب فقط المؤهلات والخبرات والمهارات التي تستطيع إثباتها. القالب يحسّن الصياغة ولا يختلق شهادات أو سنوات خبرة.',
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class _DocumentTypeCard extends StatelessWidget {
  const _DocumentTypeCard({
    required this.selected,
    required this.busy,
    required this.onSelected,
  });

  final BewerbungDocumentType selected;
  final bool busy;
  final Future<void> Function(BewerbungDocumentType) onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'نوع المستند',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: BewerbungDocumentType.values
                .map(
                  (type) => ChoiceChip(
                    label: Text(
                      type.labelDe,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.label,
                    ),
                    selected: selected == type,
                    onSelected:
                        busy ? null : (_) => onSelected(type),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _CareerTrackCard extends StatelessWidget {
  const _CareerTrackCard({
    required this.selected,
    required this.busy,
    required this.onSelected,
  });

  final CareerTrack selected;
  final bool busy;
  final Future<void> Function(CareerTrack) onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'المسار المهني',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: CareerTrack.values
                .map(
                  (track) => ChoiceChip(
                    label: Text(
                      track.labelAr,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.label,
                    ),
                    selected: selected == track,
                    onSelected:
                        busy ? null : (_) => onSelected(track),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.templates,
    required this.selected,
    required this.busy,
    required this.onSelected,
  });

  final List<BewerbungTemplate> templates;
  final BewerbungTemplate? selected;
  final bool busy;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'القالب',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          if (templates.isEmpty)
            Text(
              busy ? 'جارٍ تحميل القوالب…' : 'لا يوجد قالب متاح.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.body,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: templates
                  .map(
                    (template) => ChoiceChip(
                      label: Text(
                        template.titleDe,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.label,
                      ),
                      selected: selected?.id == template.id,
                      onSelected: busy
                          ? null
                          : (_) => onSelected(template.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          if (selected != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              selected!.guidanceAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 8),
            Text(
              'Beispiele für relevante Kompetenzen: ${selected!.suggestedSkillsDe.join(', ')}',
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.name,
    required this.city,
    required this.email,
    required this.phone,
    required this.role,
    required this.employer,
    required this.summary,
    required this.education,
    required this.experience,
    required this.skills,
    required this.languages,
  });

  final TextEditingController name;
  final TextEditingController city;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController role;
  final TextEditingController employer;
  final TextEditingController summary;
  final TextEditingController education;
  final TextEditingController experience;
  final TextEditingController skills;
  final TextEditingController languages;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      blur: 22,
      opacity: .14,
      borderColor: AppColors.secondary.withAlpha(76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'بياناتك المهنية',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 12),
          _field(name, 'Vollständiger Name'),
          _field(city, 'Ort / Stadt'),
          _field(email, 'E-Mail'),
          _field(phone, 'Telefon', requiredField: false),
          _field(role, 'Zielposition'),
          _field(
            employer,
            'Arbeitgeber / Unternehmen',
            requiredField: false,
          ),
          _field(
            summary,
            'Berufliches Profil',
            maxLines: 3,
          ),
          _field(
            experience,
            'Berufserfahrung – eine Zeile pro Eintrag',
            maxLines: 4,
            requiredField: false,
          ),
          _field(
            education,
            'Ausbildung – eine Zeile pro Eintrag',
            maxLines: 4,
            requiredField: false,
          ),
          _field(
            skills,
            'Kenntnisse – mit Komma trennen',
            maxLines: 2,
          ),
          _field(
            languages,
            'Sprachen – mit Komma trennen',
            maxLines: 2,
            requiredField: false,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: requiredField ? '$label *' : label,
        ),
        style: AppTypography.body,
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(84),
      glowColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'أكمل البيانات التالية',
            textDirection: TextDirection.rtl,
            style: AppTypography.title.copyWith(
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          ...issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $issue',
                textDirection: TextDirection.rtl,
                style: AppTypography.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});

  final BewerbungPreview preview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppGlassCard(
          borderColor: AppColors.mastery.withAlpha(86),
          glowColor: AppColors.mastery,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Template Preview',
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(
                  color: AppColors.mastery,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                preview.titleDe,
                textDirection: TextDirection.ltr,
                style: AppTypography.title,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...preview.blocks.map(
          (block) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppGlassCard(
              borderColor: AppColors.primary.withAlpha(62),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    block.headingDe,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    block.bodyDe,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    block.guidanceAr,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
