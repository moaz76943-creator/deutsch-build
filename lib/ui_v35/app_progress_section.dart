part of 'app.dart';

extension _HomeStateProgressSection on _HomeState {
  Widget _progressTab(BuildContext c) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          this._sectionTitle(
            c,
            'تقدمك ومسارك',
            'التقدم ليس رقمًا واحدًا؛ نراقب الاستدعاء والاستماع والإنتاج والنقل.',
          ),
          this._featureCard(
            c,
            'لوحة المتعلم وخطة اليوم',
            'تحليلات دقيقة + مراجعة SRS تكيفية حسب العناصر المستحقة',
            Icons.psychology_outlined,
            () {
              final bundle = DashboardAnalyticsBuilder.build(
                state: widget.repo.load(),
                corpus: widget.dependencies.corpus,
                contentIntelligence:
                    widget.dependencies.languagePack.contentIntelligence,
                nowUtc: DateTime.now().toUtc(),
                timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
              );
              Navigator.push(
                c,
                MaterialPageRoute(
                  builder: (dashboardContext) => LearnerDashboardView(
                    analytics: bundle.analytics,
                    languageCode: widget.dependencies.languagePack.sourceLocale,
                    onStartQuickReview: (ids) {
                      final candidates = [
                        for (final id in ids)
                          if (bundle.mistakesByItem[id] != null)
                            bundle.mistakesByItem[id]!,
                      ];
                      if (candidates.isEmpty) return;
                      Navigator.push(
                        dashboardContext,
                        MaterialPageRoute(
                          builder: (_) => MistakeRepairPage(
                            repo: widget.repo,
                            mistake: candidates.first,
                            corpus: widget.dependencies.corpus,
                            exerciseStrategy:
                                widget.dependencies.languagePack.exerciseStrategy,
                            contentQuality:
                                widget.dependencies.languagePack.contentQuality,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            primary: true,
          ),
          this._featureCard(
            c,
            'تطوري ومستواي',
            'اعرض اتجاه تقدمك',
            Icons.trending_up_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => ProgressPage(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  presentation: widget.dependencies.languagePack.presentation,
                  contentQuality:
                      widget.dependencies.languagePack.contentQuality,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                  contentIntelligence:
                      widget.dependencies.languagePack.contentIntelligence,
                ),
              ),
            ),
          ),
          this._featureCard(
            c,
            'الإنجازات و XP',
            'السلسلة اليومية والشارات والمعلم التالي',
            Icons.workspace_premium_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => GamificationDashboardPage(
                  repository: widget.dependencies.gamificationRepository,
                ),
              ),
            ),
          ),
          this._featureCard(
            c,
            'تقرير الأسبوع',
            'محاولات ودقة ومراجعات',
            Icons.insights_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => WeeklyPage(state: state)),
            ),
          ),
          this._featureCard(
            c,
            'مساري الشخصي',
            'خطة تعلم تتكيف مع نقاط ضعفك',
            Icons.route_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => PersonalizedPathPage(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  searchIndex: widget.dependencies.searchIndex,
                  verbIndex: widget.dependencies.verbIndex,
                  onDone: refresh,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  presentation: widget.dependencies.languagePack.presentation,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                  contentQuality:
                      widget.dependencies.languagePack.contentQuality,
                  contentIntelligence:
                      widget.dependencies.languagePack.contentIntelligence,
                ),
              ),
            ),
          ),
          this._featureCard(
            c,
            'حالة أدوات التطبيق',
            'ما هو مفعّل وما يحتاج تطويرًا',
            Icons.verified_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => FeatureStatusPage()),
            ),
          ),
          this._featureCard(
            c,
            'الخصوصية والميزات المتصلة',
            'تحكم واضح في الميزات السحابية',
            Icons.privacy_tip_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => PrivacyCenterPage(
                  privacySettings: widget.dependencies.privacySettings,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _sectionTitle(BuildContext c, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(c)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(subtitle),
          ],
        ),
      );
  Widget _featureCard(
    BuildContext c,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool primary = false,
  }) =>
      FeatureNavigationCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onTap,
        primary: primary,
      );
}
