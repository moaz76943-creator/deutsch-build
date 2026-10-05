import 'package:flutter/material.dart';

import '../features/life_supermarket_groceries/supermarket_screen.dart';


import 'grammar/grammar_hub_page.dart';

import 'word_families/word_families_page.dart';

import 'pronunciation/offline_pronunciation_lab_page.dart';

import 'commute/hands_free_commute_page.dart';

import 'gamification/gamification_dashboard_page.dart';

import '../models/content.dart';

import '../models/learner.dart';

import '../features/gamification/domain/gamification_models.dart';

import '../features/dashboard/application/dashboard_analytics_builder.dart';

import '../features/dashboard/presentation/learner_dashboard_view.dart';

import '../features/error_pattern_agent/presentation/blind_spot_radar_screen.dart';

import '../features/app_settings/presentation/app_settings_screen.dart';


import '../features/life_doctor_appointment/presentation/doctor_appointment_master_hub.dart';

import '../features/life_furniture_home_setup/furniture_home_module.dart';

import '../features/life_furniture_home_setup/furniture_home_screen.dart';

import '../features/life_postal_delivery/postal_master_orchestrator.dart';

import '../features/life_postal_delivery/postal_screen.dart';

import '../features/verb_conjugation/data/local_verb_repository.dart';

import '../features/verb_conjugation/presentation/screens/verb_conjugation_screen.dart';

import '../features/life_haircut_barbershop/application/haircut_master_orchestrator.dart';

import '../features/life_haircut_barbershop/presentation/haircut_master_screen.dart';

import '../services/progress_snapshot_service.dart';

import '../services/repository.dart';

import '../services/auth_session_controller.dart';

import '../services/app_dependencies.dart';

import 'theme/app_design_system.dart';

import 'theme/neuro_accessibility_mode.dart';

import 'widgets/home_visuals.dart';

import 'pages/core_pages.dart';

import 'pages/offline_lexicon_hub.dart';

import 'learning_pages.dart';

import 'account_pages.dart';

import 'account_auth_page.dart';


import 'conversation_pages.dart';

import 'progress_pages.dart';


Widget rtlAppBuilder(BuildContext context, Widget? child) => Directionality(
      textDirection: TextDirection.rtl,
      child: child ?? const SizedBox.shrink(),
    );

final class _PreferenceTextScaler extends TextScaler {
  const _PreferenceTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PreferenceTextScaler &&
          other.base == base &&
          other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}

class DeutschAppV35 extends StatefulWidget {
  final LearnerRepository repo;
  final AuthSessionController auth;
  final AppDependencies<ContentItem> dependencies;
  const DeutschAppV35(
    this.repo, {
    required this.auth,
    required this.dependencies,
    super.key,
  });
  @override
  State<DeutschAppV35> createState() => _AppState();
}

class _AppState extends State<DeutschAppV35> {
  bool dark = false;

  @override
  void dispose() {
    widget.dependencies.audioRuntime.shutdown();
    widget.dependencies.sourceAudioRuntime.shutdown();
    widget.dependencies.gamificationRepository.close();
    widget.dependencies.errorPatternAgent?.dispose();
    widget.dependencies.settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: Listenable.merge(<Listenable>[
          widget.dependencies.neuroSettings,
          widget.dependencies.settingsController,
        ]),
        builder: (context, child) {
          final isNeuroMode = widget.dependencies.neuroSettings.isEnabled;

          ThemeData lightTheme = AppDesignSystem.light();
          ThemeData darkTheme = AppDesignSystem.dark();

          if (isNeuroMode) {
            lightTheme = lightTheme.applyNeuroAccessibility();
            darkTheme = darkTheme.applyNeuroAccessibility();
          }

          return NeuroAccessibilityMode(
            isEnabled: isNeuroMode,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Deutsch بالعربي',
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              theme: lightTheme,
              darkTheme: darkTheme,
              builder: (builderContext, child) {
                final media = MediaQuery.of(builderContext);
                final scale = widget
                    .dependencies.settingsController.preferences.textScaleFactor;
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: MediaQuery(
                    data: media.copyWith(
                      textScaler: _PreferenceTextScaler(media.textScaler, scale),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
              routes: <String, WidgetBuilder>{
                FurnitureHomeSetupModule.routeName: (_) =>
                    FurnitureHomeMasterScreen(
                  module: widget.dependencies.furnitureHomeSetupModule,
                ),
                PostalDeliveryModule.routeName: (_) => PostalDeliveryMasterHub(
                      orchestrator: widget.dependencies.postalDeliveryModule
                          .createOrchestrator(),
                    ),
                HaircutBarbershopModule.routeName: (_) =>
                    HaircutMasterScreen(
                  module: widget.dependencies.haircutBarbershopModule,
                ),
              },
              home: HomeV35(
                repo: widget.repo,
                auth: widget.auth,
                dependencies: widget.dependencies,
                onTheme: () => setState(() => dark = !dark),
              ),
            ),
          );
        },
      );
}

class HomeV35 extends StatefulWidget {
  final LearnerRepository repo;
  final AuthSessionController auth;
  final AppDependencies<ContentItem> dependencies;
  final VoidCallback onTheme;
  const HomeV35({
    super.key,
    required this.repo,
    required this.auth,
    required this.dependencies,
    required this.onTheme,
  });
  @override
  State<HomeV35> createState() => _HomeState();
}

class _HomeState extends State<HomeV35> {
  late LearnerState state;
  late Future<GamificationSnapshot> _homeGamification;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    state = widget.repo.load();
    _homeGamification =
        widget.dependencies.gamificationRepository.loadSnapshot();
  }

  void refresh() {
    if (!mounted) return;
    setState(() {
      state = widget.repo.load();
      _homeGamification =
          widget.dependencies.gamificationRepository.loadSnapshot();
    });
  }

  Widget _tabForIndex(BuildContext c, int index) {
    switch (index) {
      case 1:
        return _learnTab(c);
      case 2:
        return _practiceTab(c);
      case 3:
        return _progressTab(c);
      case 4:
        return _practiceTab(c);
      case 0:
      default:
        return _homeTab(c);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      extendBody: true,
      appBar: tab == 0
          ? null
          : AppBar(
              title: const Text('Deutsch بالعربي'),
              actions: [
                IconButton(
                  tooltip: 'تغيير المظهر',
                  onPressed: widget.onTheme,
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
                IconButton(
                  tooltip: 'الحساب',
                  onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => AccountPage(auth: widget.auth),
                    ),
                  ),
                  icon: const Icon(Icons.account_circle_outlined),
                ),
                IconButton(
                  tooltip: 'الاشتراك والباقات',
                  onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => SubscriptionPage(repo: widget.repo),
                    ),
                  ),
                  icon: const Icon(Icons.workspace_premium_outlined),
                ),
                IconButton(
                  tooltip: 'الإعدادات',
                  onPressed: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => AppSettingsScreen(
                        notifier: widget.dependencies.settingsController,
                        accessibilityListenable: widget.dependencies.neuroSettings,
                        cognitiveAccessibilityEnabled:
                            () => widget.dependencies.neuroSettings.isEnabled,
                        onCognitiveAccessibilityChanged:
                            widget.dependencies.neuroSettings.setEnabled,
                        onProgressReset: refresh,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
      body: Semantics(
        label: 'محتوى الصفحة الرئيسية',
        child: ColoredBox(
          color: Theme.of(c).scaffoldBackgroundColor,
          child: _tabForIndex(c, tab),
        ),
      ),
      bottomNavigationBar: ReferenceFloatingNavigationBar(
        selectedIndex: tab,
        onSelected: (i) {
          if (i == 2) {
            Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => ConversationPage(
                  repo: widget.repo,
                  onDone: refresh,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  presentation: widget.dependencies.languagePack.presentation,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                  aiGateway: widget.dependencies.aiGateway,
                  privacySettings: widget.dependencies.privacySettings,
                ),
              ),
            );
            return;
          }
          setState(() => tab = i);
        },
      ),
    );
  }

  Widget _homeTab(BuildContext c) {
    final progress = ProgressSnapshotService.build(
      state.attempts,
      state.assessmentHistory,
    );

    void openCoreSession() {
      Navigator.push(
        c,
        MaterialPageRoute(
          builder: (_) => CoreSession(
            repo: widget.repo,
            corpus: widget.dependencies.corpus,
            onDone: refresh,
            exerciseStrategy: widget.dependencies.languagePack.exerciseStrategy,
            presentation: widget.dependencies.languagePack.presentation,
            textNormalizer: widget.dependencies.languagePack.textNormalizer,
            contentQuality: widget.dependencies.languagePack.contentQuality,
            contentIntelligence:
                widget.dependencies.languagePack.contentIntelligence,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: FutureBuilder<GamificationSnapshot>(
        future: _homeGamification,
        builder: (context, snapshot) {
          final profile = snapshot.data?.profile;
          final streak = profile?.currentStreak ?? state.streak;
          final xp = profile?.totalXp ?? state.xp;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              HomeProgressHero(
                levelLabel: progress.levelLabel,
                overallProgress: progress.overall,
                streak: streak,
                masteredWords: state.learned.length,
                totalWords: widget.dependencies.corpus.length,
                xp: xp,
                onContinue: openCoreSession,
              ),
              const SizedBox(height: 28),
              ReferenceHomeActions(
                onDailyLessons: openCoreSession,
                onAiConversation: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (_) => AiConversationPage(
                      scenario: 'محادثة عامة',
                      aiGateway: widget.dependencies.aiGateway,
                      privacySettings: widget.dependencies.privacySettings,
                    ),
                  ),
                ),
                onQuickPractice: openCoreSession,
                onAssessment: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (_) => SmartAssessmentPage(
                      repo: widget.repo,
                      corpus: widget.dependencies.corpus,
                      exerciseStrategy:
                          widget.dependencies.languagePack.exerciseStrategy,
                      presentation:
                          widget.dependencies.languagePack.presentation,
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
            ],
          );
        },
      ),
    );
  }

  Widget _learnTab(BuildContext c) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          _sectionTitle(
            c,
            'تعلم بطريقة منظمة',
            'كل أداة هنا مرتبطة بمسار التعلم، وليست قائمة أدوات منفصلة.',
          ),
          _featureCard(
            c,
            'جلسة التعلم الأساسية',
            'تعرّف → فهم → استماع → إنتاج → نقل → احتفاظ',
            Icons.school_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => CoreSession(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
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
            primary: true,
          ),
          _featureCard(
            c,
            'المفردات',
            '${state.learned.length}/${widget.dependencies.corpus.length} مكتسبة',
            Icons.menu_book_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => VocabularyV35(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  onDone: refresh,
                  presentation: widget.dependencies.languagePack.presentation,
                  contentQuality:
                      widget.dependencies.languagePack.contentQuality,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                  dependencies: widget.dependencies,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'عائلات الكلمات',
            'اربط الكلمات الألمانية باشتقاقاتها الموثّقة دون تخمين',
            Icons.account_tree_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => WordFamiliesPage(
                  repository: widget.dependencies.wordFamilyRepository,
                  corpus: widget.dependencies.corpus,
                  learnedIds: state.learned.toSet(),
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'مكتبة المفردات',
            'بحث سريع في مفرداتك المكتسبة',
            Icons.library_books_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => OfflineLexiconHub(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  searchIndex: widget.dependencies.searchIndex,
                  verbIndex: widget.dependencies.verbIndex,
                  presentation: widget.dependencies.languagePack.presentation,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'السوبرماركت والمواد الغذائية',
            'المنتجات والمكونات والعروض وإيصالات الدفع في مواقف التسوق اليومية',
            Icons.shopping_cart_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => SupermarketGroceriesMasterHub(
                  module: widget.dependencies.supermarketGroceriesModule,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'الأقسام والفئات',
            'تعلم حسب الموضوع والمجال',
            Icons.category_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => CategoriesPage(
                  repo: widget.repo,
                  searchIndex: widget.dependencies.searchIndex,
                  presentation: widget.dependencies.languagePack.presentation,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'الأفعال والتصريف',
            'تدريب عملي على تصريف الأفعال',
            Icons.translate_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => VerbConjugationScreen(
                  repository: LocalVerbRepository(),
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'القراءة التفاعلية',
            'نصوص وأسئلة مرتبطة بالمفردات',
            Icons.menu_book_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => ReadingPracticePage(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  searchIndex: widget.dependencies.searchIndex,
                  verbIndex: widget.dependencies.verbIndex,
                  contentQuality:
                      widget.dependencies.languagePack.contentQuality,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'البحث والقاموس',
            'ابحث بالألمانية أو العربية',
            Icons.search,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => SearchDictionaryPage(
                  repo: widget.repo,
                  searchIndex: widget.dependencies.searchIndex,
                  verbIndex: widget.dependencies.verbIndex,
                  presentation: widget.dependencies.languagePack.presentation,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'الأثاث والمنزل',
            'شراء الأثاث والتوصيل والضمان وتجهيز المنزل',
            Icons.chair_outlined,
            () => Navigator.pushNamed(
              c,
              FurnitureHomeSetupModule.routeName,
            ),
          ),
          _featureCard(
            c,
            'الحلاقة والعناية',
            'المواعيد والقصة الكلاسيكية واللحية وغسل الشعر والدفع',
            Icons.content_cut_outlined,
            () => Navigator.pushNamed(
              c,
              HaircutBarbershopModule.routeName,
            ),
          ),
          _featureCard(
            c,
            'ألمانيا الحقيقية',
            'مواقف عملية خارج الكتاب',
            Icons.location_city_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => GermanyRealityPage(
                  repo: widget.repo,
                  onDone: refresh,
                  presentation: widget.dependencies.languagePack.presentation,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'زيارة عيادة الطبيب',
            'Hausarzt / Facharzt · Termin · Gesundheitskarte',
            Icons.local_hospital_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => DoctorAppointmentMasterHub(
                  orchestrator:
                      widget.dependencies.doctorAppointmentOrchestrator,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'الصيدلية والأدوية',
            'مواقف عملية للوصفات والاستشارة والجرعات داخل الصيدلية',
            Icons.local_pharmacy_outlined,
            () {},
          ),
          _featureCard(
            c,
            'مركز القواعد',
            'القواعد النحوية من A1 إلى C2',
            Icons.rule_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => GrammarHubPage(
                  dependencies: widget.dependencies,
                  learnerState: state,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _practiceTab(BuildContext c) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          _sectionTitle(
            c,
            'التدريب والتصحيح',
            'حوّل الأخطاء إلى تمارين علاجية بدل الاكتفاء بمعرفة النتيجة.',
          ),
          _featureCard(
            c,
            'اختبار تحديد المستوى',
            'ابدأ بخط أساس واضح',
            Icons.assessment_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => PlacementPage(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  onDone: refresh,
                  presentation: widget.dependencies.languagePack.presentation,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  contentQuality:
                      widget.dependencies.languagePack.contentQuality,
                  audioRuntime: widget.dependencies.audioRuntime,
                  languageCode: widget.dependencies.languagePack.languageCode,
                  sourceLanguageCode:
                      widget.dependencies.languagePack.sourceLocale,
                ),
              ),
            ),
            primary: true,
          ),
          _featureCard(
            c,
            'التقييم الذكي',
            'قياس تطورك عبر مهارات متعددة',
            Icons.quiz_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => SmartAssessmentPage(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
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
          _featureCard(
            c,
            'مدرب الأخطاء',
            'اكتشف سبب الخطأ وأعد التدريب',
            Icons.auto_fix_high_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => MistakeCoachPage(
                  repo: widget.repo,
                  corpus: widget.dependencies.corpus,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  contentQuality:
                      widget.dependencies.languagePack.contentQuality,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'تحليل الأخطاء',
            'خريطة لنقاط الضعف المتكررة',
            Icons.healing_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => MistakeDashboardPage(repo: widget.repo),
              ),
            ),
          ),
          if (widget.dependencies.errorPatternAgent != null)
            _featureCard(
              c,
              'رادار النقاط العمياء',
              'تشخيص لغوي لأكثر أنماط الخطأ تكراراً مع علاج مباشر',
              Icons.radar_rounded,
              () => Navigator.push(
                c,
                MaterialPageRoute(
                  builder: (_) => BlindSpotRadarScreen(
                    notifier: widget.dependencies.errorPatternAgent!,
                  ),
                ),
              ),
            ),
          _featureCard(
            c,
            'مختبر النطق والاستماع',
            'تمييز صوتي + فحص ميكروفون محلي بلا سحابة',
            Icons.mic_none_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => OfflinePronunciationLabPage(
                  repo: widget.repo,
                  dependencies: widget.dependencies,
                  onDone: refresh,
                ),
              ),
            ),
          ),
          _featureCard(
            c,
            'وضع التنقل',
            'مراجعة SRS صوتية: كلمة → معنى → مثال',
            Icons.directions_walk_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => HandsFreeCommutePage(
                  repo: widget.repo,
                  dependencies: widget.dependencies,
                  onDone: refresh,
                ),
              ),
            ),
          ),
          PremiumButton(
            repo: widget.repo,
            label: 'تصحيح الكتابة • Premium',
            icon: Icons.edit_note,
            onOpen: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => WritingCoachPage(
                  repo: widget.repo,
                  onDone: refresh,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                  aiGateway: widget.dependencies.aiGateway,
                  privacySettings: widget.dependencies.privacySettings,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PremiumButton(
            repo: widget.repo,
            label: 'المحادثة والمواقف • Premium',
            icon: Icons.forum_outlined,
            onOpen: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => ConversationPage(
                  repo: widget.repo,
                  onDone: refresh,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  presentation: widget.dependencies.languagePack.presentation,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                  aiGateway: widget.dependencies.aiGateway,
                  privacySettings: widget.dependencies.privacySettings,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _featureCard(
            c,
            'محادثة ألمانية بالصوت',
            'تحدث ثم راجع تقييمك',
            Icons.record_voice_over_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => VoiceConversationPage(
                  repo: widget.repo,
                  onDone: refresh,
                  exerciseStrategy:
                      widget.dependencies.languagePack.exerciseStrategy,
                  presentation: widget.dependencies.languagePack.presentation,
                  textNormalizer:
                      widget.dependencies.languagePack.textNormalizer,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _progressTab(BuildContext c) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          _sectionTitle(
            c,
            'تقدمك ومسارك',
            'التقدم ليس رقمًا واحدًا؛ نراقب الاستدعاء والاستماع والإنتاج والنقل.',
          ),
          _featureCard(
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
          _featureCard(
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
          _featureCard(
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
          _featureCard(
            c,
            'تقرير الأسبوع',
            'محاولات ودقة ومراجعات',
            Icons.insights_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => WeeklyPage(state: state)),
            ),
          ),
          _featureCard(
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
          _featureCard(
            c,
            'حالة أدوات التطبيق',
            'ما هو مفعّل وما يحتاج تطويرًا',
            Icons.verified_outlined,
            () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => FeatureStatusPage()),
            ),
          ),
          _featureCard(
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

class DynamicUiVariationHelpers {
  static List<Color> getGradientColors(int seed, bool isDark) => [];
  static Duration getMicroAnimationDuration(int seed) =>
      const Duration(milliseconds: 300);
}